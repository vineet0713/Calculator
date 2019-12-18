//
//  ViewController.swift
//  Calculator
//
//  Created by Vineet Joshi on 12/17/19.
//  Copyright © 2019 Vineet Joshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    let resultLabel = UILabel()
    let mainStackView = UIStackView()
    let numSubStackViews = 5
    
    var buttons = [[UIButton]]()
    let buttonTitles = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]
    
    // MARK: - UIViewController Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .black
        
        setupResultLabel()
        setupMainStackView()
        
        setupButtons()
        setupSubStackViews()
    }
    
}

// MARK: - Extension: Setup Functions

extension ViewController {
    
    func setupResultLabel() {
        resultLabel.text = "0"
        resultLabel.textAlignment = .right
        resultLabel.textColor = .white
        resultLabel.font = UIFont.systemFont(ofSize: 48)
        resultLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(resultLabel)
        addConstraintsToResultLabel()
    }
    
    func setupMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 10
        view.addSubview(mainStackView)
        addConstraintsToMainStackView()
    }
    
    func setupButtons() {
        for outer in 0..<buttonTitles.count {
            buttons.append([UIButton]())
            for inner in 0..<buttonTitles[outer].count {
                let button = UIButton()
                button.setTitle(buttonTitles[outer][inner], for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                if outer == 0 && inner < 3 {
                    // Handles the edge case for the 3 top left buttons ("AC", "+/-", "%")
                    button.setTitleColor(.black, for: .normal)
                    button.backgroundColor = .white
                } else {
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = (inner + 1 == buttonTitles[outer].count) ? .orange : .gray
                }
                button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
                buttons[outer].append(button)
            }
        }
    }
    
    func setupSubStackViews() {
        for index in 0..<numSubStackViews {
            let subStackView = UIStackView()
            subStackView.axis = .horizontal
            subStackView.distribution = .fillEqually
            subStackView.spacing = 10
            if index < 4 {
                for button in buttons[index] {
                    subStackView.addArrangedSubview(button)
                }
            } else {
                // Handles the edge case for the last row ("0", ".", "="), since it only has 3 buttons
                subStackView.addArrangedSubview(buttons[index][0])
                let subsubStackView = UIStackView(arrangedSubviews: [buttons[index][1], buttons[index][2]])
                subsubStackView.axis = .horizontal
                subsubStackView.distribution = .fillEqually
                subsubStackView.spacing = 10
                subStackView.addArrangedSubview(subsubStackView)
            }
            mainStackView.addArrangedSubview(subStackView)
        }
    }
    
}

// MARK: - Extension: Constraint Functions

extension ViewController {
    
    func addConstraintsToResultLabel() {
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.1)
        ])
    }
    
    func addConstraintsToMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
        ])
    }
    
}

// MARK: - Objective-C Exposed Functions

extension ViewController {
    
    @objc func buttonTapped(sender: UIButton!) {
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }
        if buttonTitle == "AC" {
            resultLabel.text = "0"
            return
        }
        let previousText = (resultLabel.text == "0") ? "" : (resultLabel.text ?? "")
        resultLabel.text = previousText + buttonTitle
    }
    
}
