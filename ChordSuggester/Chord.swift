//
//  Chord.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/26/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import Foundation

class Chord: NSObject, NSCoding {
    var numeral : String
    var letter : String
    var quality : String
    var additions : String
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(numeral, forKey: "numeral")
        aCoder.encode(letter, forKey: "letter")
        aCoder.encode(quality, forKey: "quality")
        aCoder.encode(additions, forKey: "additions")
    }
    
    required init?(coder aDecoder: NSCoder) {
        numeral = aDecoder.decodeObject(forKey: "numeral") as! String
        letter = aDecoder.decodeObject(forKey: "letter") as! String
        quality = aDecoder.decodeObject(forKey: "quality") as! String
        additions = aDecoder.decodeObject(forKey: "additions") as! String
    }
    
    init(letter: String, quality: String, additions: String = "", numeral: String = "" ) {
        self.letter = letter
        self.quality = quality
        self.additions = additions
        self.numeral = numeral
    }
    
    func getQualityFromNumeral( numeral: String ) -> (String) {
        let numerals = ["I", "bII", "II", "bIII", "III", "IV", "bV", "V", "bVI", "VI", "bVII", "VII"]
        let tempNumeral = numeral
        if( numeral.last == "-" ) {
            self.quality = "diminished"
            let removedLastTemp =  String( tempNumeral.dropLast(  ) )
            if(removedLastTemp[removedLastTemp.startIndex] == "b") {
                var newTempNum = removedLastTemp
                newTempNum.remove(at: removedLastTemp.startIndex)
                return String( "b" + (newTempNum.uppercased()) )
            }
            else {
                print( "no found flat: " + removedLastTemp )
                
                return removedLastTemp.uppercased()
            }
        }
        else if( numeral.last == "+" ) {
            self.quality = "augmented"
            return String( tempNumeral.dropLast(  ) )
        }
        else if( numerals.contains(numeral) ) {
            self.quality = "major"
            return tempNumeral
        }
        else {
            self.quality = "minor"
            if(tempNumeral[tempNumeral.startIndex] == "b") {
                print( "found flat: " + tempNumeral )
                var newTempNum = tempNumeral
                newTempNum.remove(at: tempNumeral.startIndex)
                return String( "b" + (newTempNum.uppercased()) )
            }
            else {
                print( "no found flat: " + tempNumeral )

               return tempNumeral.uppercased()
            }
        }
    }
    
    func getLetterFromKey( key: String ) {
        let numerals = ["I", "bII", "II", "bIII", "III", "IV", "bV", "V", "bVI", "VI", "bVII", "VII"]
        let pitchesSharp = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        
        let strippedNumeral = self.getQualityFromNumeral( numeral: self.numeral )
        print( "stripped numeral " + strippedNumeral)
        let numIndex = numerals.index( of: strippedNumeral )
        let keyIndex = pitchesSharp.index( of: key)

        print( numIndex )
        print( keyIndex )
        
        let letterIndex = (keyIndex! + numIndex!) % 12
        self.letter = pitchesSharp[letterIndex]
        
    }
}
