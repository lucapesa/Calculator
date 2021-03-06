//
//  RPNCalculator.swift
//  Calculator
//
//  Created by Luca Pesavento on 03/02/15.
//  Copyright (c) 2015 Luca Pesavento. All rights reserved.
//

import Foundation

class RPNCalculator: Printable {
    
    private enum Op: Printable  {
        case operand(Double)
        case variable(String)
        case constant(String, Double)
        case unaryOperation(String, Double -> Double, String -> String)
        case binaryOperation(String, (Double, Double) -> Double, (String, String) -> String)
        
        var description: String {
            switch self {
            case .operand(let value):
                return ("\(value)")
            case .unaryOperation(let name, _, _):
                return name
            case .binaryOperation(let name, _, _):
                return name
            case .variable(let name):
                return name
            case .constant(let name, _):
                return name
            }
        }
        
        
        
    }
    
    var variableValues: [String: Double] = [String: Double]() {
        didSet {
            descriptionChanged()
        }
    }
    
    var observers: [CalculatorObserver] = []
    
    private var ops = [String: Op]()
    private let consts : [String: Op] = ["π": .constant("π",M_PI)]
    private var stack: [Op] = [Op]() {
        didSet {
            descriptionChanged()
        }
    }
    
    init() {
        initOperations()
    }
    
    private func initOperations(){
        self.learnOperation("+", {$0 + $1}, { "\($0) + \($1)" })
        self.learnOperation("-", { $1 - $0 }, { "\($1) - \($0)" })
        self.learnOperation("*", *, { "(\($0) * \($1))" })
        self.learnOperation("/", { $1 / $0 }, { "(\($1)) / (\($0))" })
        self.learnOperation("√", sqrt, { "√(\($0))" })
        self.learnOperation("²", { pow($0, 2) }, { "\($0)²" })
        self.learnOperation("sin", sin, { "sin(\($0))" })
        self.learnOperation("cos", cos, { "cos(\($0))" })
        self.learnOperation("ᐩ/-", { -$0 }, { "- \($0)" })
    }
    
    func learnOperation(symbol: String, operation: Double -> Double, printFormat: String -> String) {
        ops[symbol] = .unaryOperation(symbol, operation, printFormat)
    }
    
    func learnOperation(symbol: String, operation: (Double, Double) -> Double, printFormat: (String, String) -> String) {
        ops[symbol] = .binaryOperation(symbol, operation, printFormat)
    }
    
    
    private func evaluate(var stack: [Op]) -> (Double, [Op])? {
        if stack.isEmpty {
            return nil
        }
        
        switch stack.removeLast() {
        case .operand(let value):
            return (value, stack)
        case .binaryOperation(_, let operation, _):
            if let (op1, rest1) = evaluate(stack) {
                if let (op2, rest2) = evaluate(rest1) {
                    return (operation(op1, op2), rest2)
                }
            }
            return nil
        case .unaryOperation(_, let operation, _):
            if let (op, rest) = evaluate(stack) {
                return (operation(op), rest)
            }
            return nil
        case .variable(let name):
            if let value = variableValues[name]{
                return (value, stack)
            } else {
                return nil
            }
        case .constant(_, let value):
            return (value, stack)
        }
    }
    
    private func description(var stack: [Op]) -> (String, [Op])?{
        if stack.isEmpty {
            return nil
        }
        
        switch stack.removeLast() {
        case .operand(let value):
            return ("\(value)", stack)
        case .constant(let name, _):
            return (name, stack)
        case .variable(let name):
            return (name, stack)
        case .unaryOperation(_, _, let format):
            if let (result, rest) = description(stack) {
                return (format(result), rest)
            }
            return nil
        case .binaryOperation(_, _, let format):
            if let (result1, rest1) = description(stack){
                if let (result2, rest2) = description(rest1){
                    return (format(result1, result2), rest2)
                }
            }
            return nil
        }
    }
    
    var description: String {
        
        var currentDescription = description(stack)
        var resultDescriptions = [String]()
        
        while currentDescription != nil {
            let (current, rest) = currentDescription!
            resultDescriptions.append(current)
            resultDescriptions.append(", ")
            
            currentDescription = description(rest)
        }
        if !resultDescriptions.isEmpty {
            resultDescriptions.removeLast()
        }
        return resultDescriptions.reverse().reduce(" ", combine: { "\($1)\($0)" })
        
    }
    
    func evaluate() -> Double? {
        
        if let (result, rest) = evaluate(stack) {
            println("Evaluated. Result: \(result), remaining stack: \(rest)")
            return result
        }
        return nil
    }
    
    
    private func reportErrors(var stack: [Op]) -> (String?, [Op])  {
        if stack.isEmpty {
            return ("Error, expected value in stack",[])
        }
        
        switch stack.removeLast(){
        case .operand(let value):
            return (nil, stack)
        case .variable(let name):
            if variableValues[name] == nil {
                return ("Error: expected variable value for \(name)", stack)
            }
        case .constant(let name, let value):
            return (nil, stack)
        case .unaryOperation(_, let funcion, _):
            let (error, remaining) = reportErrors(stack)
            return (error, remaining)
        case .binaryOperation(_, let function, _):
            let (error1, remainder1) = reportErrors(stack)
            let (error2, remainder2) = reportErrors(remainder1)
            if error1 != nil {
                return (error1, remainder2)
            } else if error2 != nil {
                return (error2, remainder2)
            } else {
                return (nil, remainder2)
            }
        }
        
        assert(true, "failed to interpret calculator error")
        return (nil, [])
    }

    func reportErrors() -> String? {
        return reportErrors(stack).0
    }
    
    func pushOperation(operation: String) -> Double? {
        if let op = ops[operation] {
            stack.append(op)
        }
        return evaluate()
    }
    
    func pushOperand(operand: Double) -> Double? {
        stack.append(.operand(operand))
        return evaluate()
    }
    
    func pushVariable(variable: String) -> Double? {
        stack.append(.variable(variable))
        return evaluate()
    }
    
    func pushConstant(constant: String) -> Double?{
        if let value = consts[constant] {
            stack.append(value)
        }
        return evaluate()
    }
    
    func clear(){
        clearStack()
        clearVariables()
    }
    
    func clearStack(){
        self.stack = [Op]()
    }
    
    func clearVariables(){
        self.variableValues = [String: Double]()
    }
    
    func descriptionChanged(){
        for observer in observers{
            observer.formulaChanged(self.description)
        }
    }
    
    func removeLastElement() -> Double? {
        if !stack.isEmpty {
            stack.removeLast()
            return self.evaluate()
        }
        return nil
    }
}

protocol CalculatorObserver {
    func formulaChanged(formula: String?)
}