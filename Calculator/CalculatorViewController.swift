//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Luca Pesavento on 13/02/2015.
//  Copyright (c) 2015 Luca Pesavento. All rights reserved.
//

import Foundation
import UIKit

class CalculatorViewController : UIViewController, CalculatorObserver {
    
    @IBOutlet weak var calculatorDisplay: UILabel!
    @IBOutlet weak var formulaDisplay: UILabel!
    
    
    private var calculator = RPNCalculator()
    
    private var isEnteringANumber : Bool = false
    
    private var numberIsDecimal: Bool {
        return self.currentValue!.rangeOfString(".") != nil
    }
    
    private var currentValue: String? {
        didSet {
            if currentValue == "" {
                calculatorDisplay.text = " "
            } else {
                calculatorDisplay.text = currentValue ?? calculator.reportErrors() ?? " "
            }
        }
    }
    
    private var doubleValue: Double? {
        get {
            return (self.currentValue as NSString?)?.doubleValue
        }
    }
    
    override func viewDidLoad() {
         self.reset()
        calculator.observers.append(self)
    }
    
    @IBAction func addDigit(sender: UIButton) {
        if let digit = sender.titleLabel?.text? {
            if isEnteringANumber {
                currentValue? += digit
            } else {
                isEnteringANumber = true
                currentValue = digit
            }
        }
    }
    
    @IBAction func pushCurrentValue() {
        if isEnteringANumber {
            isEnteringANumber = false
            if let value = doubleValue {
                if let result = calculator.pushOperand(value) {
                    currentValue = "\(result)"
                    return
                }
            }
            currentValue = nil
        }
    }
    
    @IBAction func performSpecialOperation(sender: UIButton){
        if let action = sender.titleLabel?.text? {
            switch action {
            case ".":
                self.addDecimalSeparator()
            case "ᐩ/-":
                if isEnteringANumber {
                    self.reverseSign()
                } else {
                    self.pushOperator(sender)
                }
            case "π":
                if isEnteringANumber {
                    pushCurrentValue()
                }
                currentValue = calculator.pushConstant("π")?.description
            case "⌫":
                if isEnteringANumber {
                    if let value = currentValue {
                        if countElements(value) != 0 {
                            currentValue = dropLast(value)
                        }
                    }
                } else {
                    currentValue = calculator.removeLastElement()?.description
                }
            case "→M":
                if isEnteringANumber {
                    calculator.variableValues["M"] = doubleValue
                    isEnteringANumber = false
                    currentValue = calculator.evaluate()?.description
                }
            case "M":
                if isEnteringANumber {
                    pushCurrentValue()
                }
                currentValue = calculator.pushVariable("M")?.description
            default:
                currentValue = nil
            }
        }
    }
    
    @IBAction func pushOperator(sender: UIButton){
        if isEnteringANumber {
            pushCurrentValue()
        }
        
        if let operation = sender.titleLabel?.text? {
            self.currentValue = calculator.pushOperation(operation)?.description
            if self.currentValue != nil { self.currentValue! = " = " + self.currentValue! }
        }
    }
    
    @IBAction func reset() {
        calculator.clear()
        self.calculatorDisplay.text? = "0"
        self.formulaDisplay.text = " "
    }
    
    func addDecimalSeparator() {
        if isEnteringANumber {
            currentValue? += numberIsDecimal ? "" : "."
        } else {
            isEnteringANumber = true
            currentValue = "0."
        }
    }
    
    func reverseSign() {
        if let index = currentValue?.startIndex {
            if let char = currentValue?[index] {
                if char == "-" {
                    currentValue?.removeAtIndex(index)
                } else {
                    currentValue = "-" + currentValue!
                }
            }
        }
    }
    
    func formulaChanged(formula: String?) {
        self.formulaDisplay.text? = formula ?? " "
    }
    
}












































