//
//  extensions.swift
//  Solution
//
//  Created by Karl Cridland on 14/12/2019.
//  Copyright © 2019 Karl Cridland. All rights reserved.
//

import Foundation
import UIKit

import var CommonCrypto.CC_SHA256_DIGEST_LENGTH
import func CommonCrypto.CC_SHA256
import typealias CommonCrypto.CC_LONG

extension String {
    
    func match( _ text: String) -> Double{
        var score = 0.0
        for a in text.split(separator: " "){
            for b in self.split(separator: " "){
                if b.lowercased().contains(a.lowercased()){
                    if a.first! == b.first!{
                        score += 100/Double(self.count)
                    }
                    score += Double((100/b.count)*a.count)
                }
            }
        }
        return score
    }
    
    func charIndex(index: Int) -> String?{
        var i = 0
        for char in self{
            if i == index{
                return String(char)
            }
            i += 1
        }
        return nil
    }
    
    func charCount(_ character: String) -> Int{
        var count = 0
        for c in self{
            if String(c) == character{
                count += 1
            }
        }
        return count
    }
    
    func width(font: UIFont) -> CGFloat {
        var tester = " "
        if self == " "{
            tester = "a"
        }
        let prefix = (self as NSString).substring(to: (self+tester).range(of: tester)!.lowerBound.utf16Offset(in: self)) as NSString
        let size = prefix.size(withAttributes: [NSAttributedString.Key.font: font])
        return size.width
    }
    
    func hasUpper() -> Bool{
        return self.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    func hasDigit() -> Bool{
        return self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
    
    func readFile(_ filename: String, _ type: String) -> String?{
        if let filepath = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        return nil
    }
    
    func isBadWord() -> Bool{
        for word in readFile("BadWords", "txt")!.split(separator: ","){
            print(1,word)
            if self.contains(String(word).replacingOccurrences(of: "\n", with: "")){
                return true
            }
        }
        print(2)
        return false
    }
    
    func normalise() -> String{
        var new = ""
        let split = self.lowercased().split(separator: " ")
        for part in split{
            new += part
        }
        return new
    }
    
    func startsWithTag() -> Bool{
        if self.characterAtIndex(index: 0) == "@"{
            return true
        }
        return false
    }
    
    func setw(_ character: Character, _ width: Int) -> String{
        var new = self
        while new.count < width{
            new = String(character)+new
        }
        return new
    }
    
    func characterPosition(character: Character, font_size: CGFloat, instance: Int) -> CGPoint? {
        
        var temp = self+" "
        var i = 0
        while i < instance{
            if temp.contains(character){
                temp.remove(at: temp.firstIndex(of: character)!)
            }
            i += 1
        }
        guard let range = temp.range(of: String(character)) else {
            return nil
        }
        
        let prefix = (self as NSString).substring(to: range.lowerBound.utf16Offset(in: self)+instance) as NSString
        let size = prefix.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font_size)])

        return CGPoint(x: size.width, y: 0)
    }
    
    func beyondScope(character: Character, font_size: CGFloat, distance: CGFloat) -> Bool {
        
        guard let range = self.range(of: String(character)) else {
            return false
        }
        
        let prefix = (self as NSString).substring(to: range.lowerBound.utf16Offset(in: self)) as NSString
        let size = prefix.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font_size)])
        return size.width > distance
    }
    
    func charCount(character: Character) -> Int{
        var count = 0
        for letter in self{
            if letter == character{
                count += 1
            }
        }
        return count
    }
    
    func CGWordWidth(font_size: CGFloat) -> CGFloat{
        var length = CGFloat(0)
        for character in self{
            length += String(character).CGWidth(font_size: font_size)
        }
        return length
    }
    
    func CGWidth(font_size: CGFloat) -> CGFloat {
        var tester = " "
        if self == " "{
            tester = "a"
        }
        let prefix = (self as NSString).substring(to: (self+tester).range(of: tester)!.lowerBound.utf16Offset(in: self)) as NSString
        let size = prefix.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font_size)])
        return size.width
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isLetter: Bool{
        let letters = NSCharacterSet.letters

        let range = self.rangeOfCharacter(from: letters)

        // range will be nil if no letters is found
        if let _ = range {
            return true
        }
        else{
            return false
        }
    }
    
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur += 1
        }
        return nil
    }
    
    private func SHA256(string: String) -> Data {
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_SHA256(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    func encrypt() -> String{
        var myPassword = ""
        myPassword += SHA256(string: self).map { String(format: "%02hhx", $0) }.joined()
        let thePassword = myPassword
        return thePassword
    }
}
