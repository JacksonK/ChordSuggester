//
//  Progression.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/26/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import Foundation

class Progression: NSObject, NSCoding {
    
    var name: String
    var key: String
    var length: String
    var date_created: String
    var chords = [Chord]()
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(key, forKey: "key")
        aCoder.encode(length, forKey: "length")
        aCoder.encode(date_created, forKey: "date_created")
        aCoder.encode(chords, forKey: "chords")

    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        key = aDecoder.decodeObject(forKey: "key") as! String
        length = aDecoder.decodeObject(forKey: "length") as! String
        date_created = aDecoder.decodeObject(forKey: "date_created") as! String
        chords = aDecoder.decodeObject(forKey: "chords") as! [Chord]
    }
    
    init( key:String, length:String ) {
        name = "New Progression"
        self.key = key
        self.length = length
        date_created = "No date"
    }
    
    func save( name: String) {
        self.name = name
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        self.date_created = formatter.string(from:Date())
    }
    
    func addChord( chord: Chord ) {
        getNumeral( chord: chord )
        chords.append( chord )
    }
    func replaceChord( chord: Chord, index: Int) {
        getNumeral( chord: chord )
        chords[index] = chord
    }
    
    func getNumeral( chord: Chord ) {
        let pitchesSharp = [ "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        let pitchesFlat = [ "A", "B-", "B", "C", "D-", "D", "E-", "E", "F", "G-", "G", "A-"]
        let numerals = ["I", "bII", "II", "bIII", "III", "IV", "bV", "V", "bVI", "VI", "bVII", "VII"]
        var letter = chord.letter
        if ( letter.last == "b" ) {
            letter.removeLast()
            letter = letter + "-"
        }
        var chordIndex : Int
        var keyIndex : Int
        if( key.contains( "#" )) {
            keyIndex = pitchesSharp.index( of: key )!
        }
        else {
            keyIndex = pitchesFlat.index( of: key )!
        }
        if( letter.contains( "#" )) {
            chordIndex = pitchesSharp.index( of: letter )!
        }
        else {
            chordIndex = pitchesFlat.index( of: letter )!
        }
        var interval : Int
        if( keyIndex > chordIndex ) {
            interval = (chordIndex - keyIndex) + 12
        }
        else {
            interval = chordIndex - keyIndex
        }
        var numeral = numerals[interval]
        if( chord.quality.prefix(3) == "min") {
            numeral = numeral.lowercased()
        }
        else if( chord.quality.prefix(3) == "dim") {
            numeral = numeral.lowercased() + "º"
        }
        else if( chord.quality.prefix(3) == "aug") {
            numeral = numeral.lowercased() + "+"
        }
        chord.numeral = numeral
    }
    
}

// extension from https://stackoverflow.com/questions/24034043/how-do-i-check-if-a-string-contains-another-string-in-swift
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
