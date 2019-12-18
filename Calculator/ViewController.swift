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
        ["AC", "(", ")", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "⌫", "="]
    ]
    
    var requestIsBeingMade = false
    var requestWasJustMade = false
    
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

// MARK: - Extension: UI Setup Functions

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
                    button.setTitleColor((inner == 0) ? .white : .black, for: .normal)
                    button.backgroundColor = (inner == 0) ? .blue : .white
                } else {
                    button.setTitleColor(.white, for: .normal)
                    if outer == 4 && inner == 2 {
                        // Handles the edge case for "⌫"
                        button.backgroundColor = .red
                    } else if outer == 4 && inner == 3 {
                        // Handles the edge case for "="
                        button.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
                    } else {
                        button.backgroundColor = (inner + 1 == buttonTitles[outer].count) ? .orange : .gray
                    }
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
            for button in buttons[index] {
                subStackView.addArrangedSubview(button)
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

// MARK: - Extension: Objective-C Exposed Functions

extension ViewController {
    
    @objc func buttonTapped(sender: UIButton!) {
        if requestIsBeingMade {
            return
        }
        
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }
        guard var currentExpression = resultLabel.text else {
            return
        }
        
        switch buttonTitle {
        case "=":
            if requestWasJustMade {
                return
            }
            getResult(of: currentExpression)
        case "AC":
            resultLabel.text = "0"
        case "⌫":
            let start = currentExpression.startIndex
            let end = currentExpression.endIndex
            let endMinusOne = currentExpression.index(end, offsetBy: -1)
            let trimmedString = String(currentExpression[start..<endMinusOne])
            resultLabel.text = (trimmedString.isEmpty) ? "0" : trimmedString
        default:
            if (currentExpression == "0" && buttonTitle != ".") || (requestWasJustMade && !isOperator(buttonTitle)) {
                currentExpression = ""
            }
            resultLabel.text = currentExpression + buttonTitle
        }
        
        requestWasJustMade = false
    }
    
}

// MARK: - Extension: Network Request Function

extension ViewController {
    
    func getResult(of expression: String) {
        requestIsBeingMade = true
        
        let methodParameters: [String: Any] = [
            "expr": expression.replacingOccurrences(of: "×", with: "*").replacingOccurrences(of: "÷", with: "/"),
            "precision": 10
        ]
        guard let requestURL = mathjsURL(from: methodParameters) else {
            displayErrorAlert(debugMessage: "The requestURL was not able to be generated.")
            return
        }
        
        // Make request to the math.js API (https://api.mathjs.org/)
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = error {
                self.displayErrorAlert(debugMessage: error.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                self.displayErrorAlert(debugMessage: "The request did not return a status code.")
                return
            }
            
            // The math.js API specifies that a status code of either 200 or 400 will always be returned.
            if statusCode == 400 {
                let invalidExpression = "The expression you entered is invalid."
                self.displayErrorAlert(debugMessage: invalidExpression, displayMessage: invalidExpression)
                return
            }
            
            guard let data = data else {
                self.displayErrorAlert(debugMessage: "No data was returned.")
                return
            }
            
            let result = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async {
                self.resultLabel.text = result
            }
            self.requestIsBeingMade = false
            self.requestWasJustMade = true
        }
        task.resume()
    }
    
}

// MARK: - Extension: Helper Functions

extension ViewController {
    
    func mathjsURL(from parameters: [String: Any]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.mathjs.org"
        components.path = "/v4"
        
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            queryItems.append(queryItem)
        }
        components.queryItems = queryItems
        
        return components.url
    }
    
    func displayErrorAlert(debugMessage: String, displayMessage: String = "There was a problem with retrieving the result.") {
        print(debugMessage)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: displayMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.requestIsBeingMade = false
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isOperator(_ str: String) -> Bool {
        return (str == "+" || str == "-" || str == "×" || str == "÷")
    }
    
}
