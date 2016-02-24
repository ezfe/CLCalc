//
//  main.swift
//  CLCalc
//
//  Created by Ezekiel Elin on 2/22/16.
//  Copyright © 2016 Ezekiel Elin. All rights reserved.
//

import Foundation

//http://stackoverflow.com/a/28341290/2059595
func iterateEnum<T: Hashable>(_: T.Type) -> AnyGenerator<T> {
    var i = 0
    return AnyGenerator {
        let next = withUnsafePointer(&i) { UnsafePointer<T>($0).memory }
        i += 1
        return next.hashValue == i - 1 ? next : nil
    }
}

//http://stackoverflow.com/a/30231578/2059595
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

enum Operator: String {
    case Add = "+"
    case Subtract = "-"
    case Divide = "/"
    case Multiply = "*"
    
    func eval(l: Double, _ r: Double) -> Double {
        switch self {
        case .Add:
            return l + r
        case .Subtract:
            return l - r
        case .Divide:
            return l / r
        case .Multiply:
            return l * r
        }
    }
}

enum ProblemItems: Equatable, CustomStringConvertible {
    case Number(Double)
    case Op(Operator)
    
    var description: String {
        get {
            switch self {
            case Number(let n):
                return "`\(n)`"
            case Op(let o):
                return "`\(o.rawValue)`"
            }
        }
    }
}

func ==(lhs: ProblemItems, rhs: ProblemItems) -> Bool {
    switch(lhs, rhs) {
    case (.Number(_), .Number(_)):
        return true
    case (.Op(_), .Op(_)):
        return true
    default:
        return false
    }
}

func ===(lhs: ProblemItems, rhs: ProblemItems) -> Bool {
    switch(lhs, rhs) {
    case (.Number(let n1), .Number(let n2)) where n1 == n2:
        return true
    case (.Op(let o1), .Op(let o2)) where o1 == o2:
        return true
    default:
        return false
    }
}


class UserInputObject {
    let originalInput: String
    var rawItems = [ProblemItems]()
    
    init?(_ input: String) {
        self.originalInput = input.removeWhitespace()
        
        var operations = [Operator]()
        
        var lastWasOperator = true //true so that first item is not caught
        let inptArray = originalInput.characters.split { char in
            for e in iterateEnum(Operator) {
                if e.rawValue == String(char) && !lastWasOperator {
                    operations.append(e)
                    lastWasOperator = true
                    return true
                }
            }
            lastWasOperator = false
            return false
            }.map(String.init)
        
        for (i, n) in inptArray.enumerate() {
            guard let number = Double(n) else {
                print("! Unexpected number: \(n)")
                return nil
            }
            
            self.rawItems.append(ProblemItems.Number(number))
            
            if i < operations.count {
                self.rawItems.append(ProblemItems.Op(operations[i]))
            }
        }
        
        guard let l = self.rawItems.last where l == .Number(0) else {
            return nil
        }
    }
    
    func eval() -> Double {
        return eval(self.rawItems)
    }
    
    func eval(input: [ProblemItems]) -> Double {
        if input.count == 1 {
            switch input[0] {
            case .Number(let n):
                print("Reached single-number, \(n)")
                return n
            case .Op(_):
                print("A critical error occured, the input was an operator")
                return 0
            }
        }
        
        var lastPrimary: Int? = nil
        var lastSecondary: Int? = nil
        
        for (i,item) in input.enumerate() {
            switch item {
            case .Number(_):
                continue
            case .Op(let oper):
                if (oper == .Multiply || oper == .Divide) {
                    lastPrimary = i
                } else if (oper == . Add || oper == .Subtract) {
                    lastSecondary = i
                }
            }
        }
        
        guard let evalAround = lastSecondary ?? lastPrimary else {
            print("A critical error occurred finding the evalulation point (no operators most likely issue)")
            return 0
        }
        
        let finalOper: Operator
        
        switch input[evalAround] {
        case .Number(_):
            print("A critical error occured, the evaluation point is a number")
            return 0
        case .Op(let o):
            finalOper = o
        }
        
        let left = self.eval(Array(input.prefixUpTo(evalAround)))
        let right = self.eval(Array(input.suffixFrom(evalAround + 1)))

        let res = finalOper.eval(left, right)
        
        print("Calculated \(res) from \(left) and \(right) from \(input) around \(evalAround)")
        
        return res
    }
}

while true {
    print("> ", terminator: "")
    guard let input = readLine(stripNewline: true) where input != "" else {
        print("! No input was provided")
        continue
    }
    
    guard let uip = UserInputObject(input) else {
        print("! Unable to parse input")
        continue
    }
    
//    print(uip.rawItems)
    print(uip.eval())
}