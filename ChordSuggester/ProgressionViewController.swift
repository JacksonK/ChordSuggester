//
//  ProgressionViewController.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/23/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseDatabase



class ProgressionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var suggestedChordCollectionView: UICollectionView!
    @IBOutlet weak var chordCollectionView: UICollectionView!
    @IBOutlet weak var chordPicker: UIPickerView!
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var player1:AVAudioPlayer = AVAudioPlayer()
    var player2:AVAudioPlayer = AVAudioPlayer()
    var player3:AVAudioPlayer = AVAudioPlayer()
    var playerTimer = Timer()

    var databaseRef: DatabaseReference?
    
    var suggestedOccurrences = [String: Int]()
    var suggestedChords = [String: Chord]()
    var suggestedChordKeys = [String]()
    var knownProgression: Bool?
    var progression: Progression!
    var progressionIndex: Int?
    var progressionNameField: UITextField?
    var isNew: Bool?
    var matchingProgFound: Bool? = false
    var currentChordIndex: Int = 0
    var progressionLength: Int = 0
    var audioCell: Int = -1
    var suggestedAudioCell: Int = -1
    //var currentChord: Chord?
    //let chordLetters = ["-","A","A#/Bb","B","C","C#/Db","D","D#/Eb","E","F","F#/Gb","G","G#/Ab"]
    //let chordLetters = ["-","A","Bb","B","C","Db","D","Eb","E","F","Gb","G","Ab"]
    let chordLetters = ["-","A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]

    let qualities = ["-","major","minor","diminished","augmented"]
    
    let alert = UIAlertController(title: "", message: "Please input something", preferredStyle: UIAlertControllerStyle.alert)
    
    let dispatchGroup = DispatchGroup()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return chordLetters.count
        }
        else {
            return qualities.count
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if (sender == nextButton ) {
            selectNext()
        }
        else if( sender == previousButton ) {
            selectPrev()
        }
        
    }
    
    func selectNext() {
        if( currentChordIndex < progression.chords.count  && currentChordIndex < Int(progression.length)!-1) {
            currentChordIndex += 1
            chordCollectionView.reloadData()
            updatePicker()
        }
    }
    
    func selectPrev() {
        if( currentChordIndex != 0) {
            currentChordIndex -= 1
            chordCollectionView.reloadData()
            updatePicker()
        }
    }
    @IBAction func swipeRight(_ sender: Any) {
        selectPrev()
        
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        selectNext()
    }
    
    @IBAction func longPress( gesture: UILongPressGestureRecognizer) {
        print("long press")
        if gesture.state != .ended {
            return
        }
        
        let p = gesture.location(in: self.suggestedChordCollectionView)
        
        if let indexPath = self.suggestedChordCollectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            //let cell = self.suggestedChordCollectionView.cellForItem(at: indexPath)
            let key = suggestedChordKeys[indexPath.row]
            addChord( chord: suggestedChords[key]! )
            
        } else {
            print("couldn't find index path")
        }
    }
    
    /*@IBAction func swipeDownCell(_ sender: Any) {
        let location = (sender as AnyObject).locationInView(chordCollectionView.view)
        deleteChord(location )
    }
    
    func deleteChord(Int: index) {
        
    }*/
    func updatePicker()  {
        if(currentChordIndex < progression.chords.count ) {
            let current_letter = progression.chords[currentChordIndex].letter
            let current_quality = progression.chords[currentChordIndex].quality

            chordPicker.selectRow(chordLetters.index( of: current_letter )!, inComponent: 0, animated: true)
            chordPicker.selectRow(qualities.index( of: current_quality )!, inComponent: 1, animated: true)
        }
        else {
            chordPicker.selectRow(0, inComponent: 0, animated: true)
            chordPicker.selectRow(0, inComponent: 1, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return chordLetters[row]
        }
        else {
            return qualities[row]
        }
    }
    
    @objc func saveButton()  {
        //print("save was pressed" )
        if( isNew )! {
            let alertController  = UIAlertController( title: "Name your progression:" , message: nil, preferredStyle: .alert)
            alertController.addTextField(configurationHandler: progressionNameField)
            let saveAction = UIAlertAction( title: "Save", style: .default, handler: self.saveHandler)
            let cancelAction = UIAlertAction( title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction( saveAction )
            alertController.addAction( cancelAction )
            
            self.present( alertController, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "unwindHome", sender: self)
        }
        
    }
    
    func saveHandler( alert: UIAlertAction!) {
        //let simpleViewController = SimpleVC()
        //simpleViewController
        if let newProgressionName = progressionNameField?.text {
            progression.save(name: newProgressionName )
        }
        self.performSegue(withIdentifier: "unwindHome", sender: self)

    }
    
    func progressionNameField( textField: UITextField! ) {
        progressionNameField = textField
        progressionNameField?.placeholder = "My progression"
    }
    
    @objc func renameButton()  {
        //print("save was pressed" )
        let alertController  = UIAlertController( title: "New progression name:" , message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: newProgressionNameField)
        let renameAction = UIAlertAction( title: "Rename", style: .default, handler: self.renameHandler)
        let cancelAction = UIAlertAction( title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction( renameAction )
        alertController.addAction( cancelAction )
        
        self.present( alertController, animated: true)
    }
    
    func renameHandler( alert: UIAlertAction!) {
    //let simpleViewController = SimpleVC()
    //simpleViewController
        if let newProgressionName = progressionNameField?.text {
            progression.save(name: newProgressionName )
            self.navigationItem.title = progression.name
        }
    }
    
    func newProgressionNameField( textField: UITextField! ) {
        progressionNameField = textField
        progressionNameField?.placeholder = progression.name
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( collectionView == chordCollectionView ) {
            return Int(progression.length )!
        }
        else {
            //let currentProgLength = Int( progression.length)!
            //print( currentProgLength )
            //( progression.chords.count  )
            
            if( progressionLength == progression.chords.count ) {
                matchingProgFound = false

                suggestedChordCollectionView.setEmptyMessage(message: "Complete progression")
                return 0
            }
            else if( suggestedOccurrences.count == 0 ) {
                matchingProgFound = false
                suggestedChordCollectionView.setEmptyMessage(message: "No matching progressions!")
                return 0
            }
            else {
                suggestedChordCollectionView.reset()
                matchingProgFound = true
                let indexCell = IndexPath( item: progression.chords.count, section: 0)
                let cell = chordCollectionView.cellForItem(at: indexCell )
                cell?.contentView.layer.borderWidth = 4
                let blueColor = UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
                cell?.contentView.layer.borderColor = blueColor.cgColor
            }
            return suggestedOccurrences.count
        }
    }
    
    func getSuggestions() {
        //dispatchGroup.enter()
        //knownProgression = true
        // iterate database reference down tree structure to relevant chord dictionary
        databaseRef = Database.database().reference().child("NewTestPatch")
        for chord in progression.chords {
            self.databaseRef = self.databaseRef?.child("chordDict").child( chord.numeral )
        }
        
        //updateRefrence()
        //self.dispatchGroup.leave()
        //dispatchGroup.notify( queue: .main) {
        getSuggestedChords()
        //}
        //print( "suggested next chord count: " + String( suggestedChords.count ) )


    }
    
    func getSuggestedChords() {
        dispatchGroup.enter()
        databaseRef?.child("chordCounts").observeSingleEvent( of: .value, with: { ( snapshot ) in
            if( snapshot.exists() ) {
                self.suggestedOccurrences = [String:Int]()
                let enumerator = snapshot.children
                while let chord = enumerator.nextObject() as? DataSnapshot {
                    //print( "chord keys: " + chord.key )
                    let numeral = chord.key
                    let count = chord.value as! Int
                    self.suggestedOccurrences[numeral] = count
                    self.suggestedChords[numeral] = Chord(letter: "", quality: "", numeral: numeral )
                    self.suggestedChords[numeral]?.getLetterFromKey(key: self.progression.key)
                }
                //print( "suggested chord count" + String( self.suggestedChords.count ) )
                
            }
            else {
                print( "snapshot doesn't exist!")
                self.suggestedOccurrences = [String:Int]()
            }
            self.dispatchGroup.leave()
        })

        dispatchGroup.notify( queue: .main) {
            self.printSuggestedChords()
            self.suggestedChordCollectionView.reloadData()
        }
    }
    
    func printSuggestedChords() {
        //print( "suggested chords count: " + String( suggestedOccurrences.count) )
        for chord in suggestedOccurrences {
            print( chord.key )
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if( collectionView == chordCollectionView ) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chordCell", for: indexPath) as! CustomChordCell
        
            cell.contentView.layer.backgroundColor =  UIColor.white.cgColor
            
            if( indexPath.row > progression.chords.count-1 ) {
                cell.contentView.layer.backgroundColor =  UIColor.lightGray.cgColor
            }
            if( indexPath.row == currentChordIndex) {
                cell.contentView.layer.backgroundColor = UIColor.red.cgColor//( red: 102, green: 178, blue: 255, alpha: 0.5)
            }
            
            if( matchingProgFound! && indexPath.row == progression.chords.count ) {
                cell.contentView.layer.borderWidth = 4
                let blueColor = UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
                cell.contentView.layer.borderColor = blueColor.cgColor
            }
            else if( audioCell == indexPath.row ) {
                cell.contentView.layer.borderWidth = 4
                let greenColor = UIColor.green
                cell.contentView.layer.borderColor = greenColor.cgColor
            }
            else {
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
            }
 
            if progression.chords.indices.contains( indexPath.row ) {
                cell.chordLabel.text! = progression.chords[indexPath.row].letter + "-" + progression.chords[indexPath.row].quality
                cell.numeralLabel.text! = progression.chords[indexPath.row].numeral
            }
            else {
                cell.chordLabel.text! = "-"
                cell.numeralLabel.text! = "-"
            }
            return cell
        }
        // else is suggested collection cell
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedChordCell", for: indexPath) as! CustomSuggestedChordCell
            let sortedDict = suggestedOccurrences.sorted(by: { $0.value > $1.value })
            suggestedChordKeys = Array(sortedDict.map{ $0.0 })
            let key = suggestedChordKeys[indexPath.row]
            cell.numeralLabel.text = key
            cell.letterLabel.text = (suggestedChords[key]?.letter)! + "-" + (suggestedChords[key]?.quality)!
            var sum = 0
            for value in Array(suggestedOccurrences.values) {
                sum += value
            }

            let percentage = Double(suggestedOccurrences[key]!) / Double(sum) * 100
            //print( percentage )
            cell.percentageLabel.text = String( Double( round( percentage*10 )/10 ) ) + "%"
            
            cell.contentView.layer.borderWidth = 2
            let blueColor = UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1)
            cell.contentView.layer.backgroundColor = blueColor.cgColor
            
            if( suggestedAudioCell == indexPath.row ) {
                cell.contentView.layer.borderWidth = 2
                let greenColor = UIColor.green
                cell.contentView.layer.borderColor = greenColor.cgColor
            }
            else {
                cell.contentView.layer.borderColor = UIColor.clear.cgColor
            }
            
            /*cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 2
            cell.layer.shadowOpacity = 1.0
            cell.layer.shadowOffset = CGSize( width:0, height:2)
            cell.layer.masksToBounds = false*/

            cell.tag = indexPath.row
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if( collectionView == suggestedChordCollectionView) {
            currentChordIndex = progression.chords.count
            let key = suggestedChordKeys[indexPath.row]
            //addChord( chord: suggestedChords[key]! )
            //playChord( chord: progression.chords[progression.chords.count-1])
            suggestedAudioCell = indexPath.row
            playChord( chord: suggestedChords[key]!, suggested: true)
            
            //selectNext()
        }
        else {
            if indexPath.row < progression.chords.count {
                playChord( chord: progression.chords[indexPath.row], suggested: false)
                currentChordIndex = indexPath.row
                chordCollectionView.reloadData()
                updatePicker()
            }
            else if indexPath.row == progression.chords.count {
                currentChordIndex = indexPath.row
                chordCollectionView.reloadData()
                updatePicker()
            }
        }
    }
    
    @IBAction func clearChords(_ sender: Any) {
        let confirmationAlert  = UIAlertController( title: "Are you sure you want to delete all chords in the progression?" , message: nil, preferredStyle: .alert)
        let deleteAction = UIAlertAction( title: "Clear", style: .default, handler:{ action in
            self.currentChordIndex = 0
            self.progression.chords = []
            self.chordCollectionView.reloadData()
            self.getSuggestions()

        } )
        let cancelAction = UIAlertAction( title: "Cancel", style: .cancel, handler: nil)
        confirmationAlert.addAction( deleteAction )
        confirmationAlert.addAction( cancelAction )
        
        self.present( confirmationAlert, animated: true)
    }
    
    @IBAction func deleteSelected(_ sender: Any) {
        if( currentChordIndex == progression.chords.count-1 ) {
            progression.chords.removeLast()
            self.chordCollectionView.reloadData()
            self.getSuggestions()
        }
    }
    
    @IBAction func playProgression(_ sender: Any) {
        for (i,chord) in progression.chords.enumerated() {
            let offsetTime = i * 1500
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds( offsetTime) ) {
                self.playChord( chord: chord, suggested: false)
            }
       
        }
        
    }
    func playChord( chord: Chord, suggested: Bool ) {
        let pianoKeyNames = ["C3", "C#3", "D3", "D#3","E3", "F3", "F#3", "G3", "G#3","A3", "A#3", "B3", "C4", "C#4", "D4", "D#4","E4", "F4", "F#4", "G4", "G#4","A4", "A#4", "B4", "C5", "C#5", "D5", "D#5","E5", "F5", "F#5", "G5" ]
        let startingFile = chord.letter + "4"
        let startingIndex = pianoKeyNames.index( of: startingFile )!
        let firstInterval:Int?
        let secondInterval:Int?
        if chord.quality == "major" {
            firstInterval = 4
            secondInterval = 7
        }
        else if chord.quality == "minor" {
            firstInterval = 3
            secondInterval = 7
        }
        else if chord.quality == "diminished" {
            firstInterval = 3
            secondInterval = 6
        }
        else {
            firstInterval = 4
            secondInterval = 8
        }
        let secondFile = pianoKeyNames[startingIndex+firstInterval!]
        let thirdFile = pianoKeyNames[startingIndex+secondInterval!]

        do {
            let audioPath1 = Bundle.main.path( forResource: startingFile, ofType:"mp3")
            let audioPath2 = Bundle.main.path( forResource: secondFile, ofType:"mp3")
            let audioPath3 = Bundle.main.path( forResource: thirdFile, ofType:"mp3")
            
            try player1 = AVAudioPlayer( contentsOf: NSURL (fileURLWithPath: audioPath1!) as URL)
            try player2 = AVAudioPlayer( contentsOf: NSURL (fileURLWithPath: audioPath2!) as URL)
            try player3 = AVAudioPlayer( contentsOf: NSURL (fileURLWithPath: audioPath3!) as URL)
        }
        catch {
        }
        if( suggested ) {
            //let key = suggestedChordKeys[indexPath.row]
            //addChord( chord: suggestedChords[key]! )
            //suggestedAudioCell = Array(suggestedChords.values).index( of: chord )!
            //print( suggestedAudioCell)
            suggestedChordCollectionView.reloadData()
            player1.play()
            player2.play()
            player3.play()
            let offset = 800
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds( offset) ) {
                self.suggestedAudioCell = -1
                self.suggestedChordCollectionView.reloadData()
            }
        }
        else {
            audioCell = progression.chords.index( of: chord )!
            chordCollectionView.reloadData()
            player1.play()
            player2.play()
            player3.play()
            let offset = 800
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds( offset) ) {
                self.audioCell = -1
                self.chordCollectionView.reloadData()
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLetter = pickerView.selectedRow( inComponent: 0)
        let selectedQuality = pickerView.selectedRow(inComponent: 1)
        
        if( selectedLetter != 0 && selectedQuality != 0) {
            let newChord = Chord(letter: chordLetters[selectedLetter], quality: qualities[selectedQuality] )
            addChord(chord: newChord)
        }
    }
    
    func addChord(chord: Chord) {
        matchingProgFound = false
        if( currentChordIndex == progression.chords.count) {
            progression.addChord( chord: chord )
            getSuggestions()
            //print( "after get suggestions 1")
        }
        else {
            progression.replaceChord(chord: chord, index: currentChordIndex)
            getSuggestions()
            //print( "after get suggestions 2")
        }
        //progression.chords[currentChordIndex].numeral = chordLetters[selectedLetter] + "" + qualities[selectedQuality]
        chordCollectionView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyLabel.text = "Key: " + progression.key
        lengthLabel.text = "Length: " + progression.length
        self.navigationItem.title = progression.name
        chordPicker.delegate = self
        chordPicker.dataSource = self
        databaseRef = Database.database().reference().child("NewTestPatch")
        //matchingProgFound = true
        progressionLength = Int( progression.length )!
        getSuggestions()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))


        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.suggestedChordCollectionView?.addGestureRecognizer(lpgr)
        
        if( isNew )! {
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveButton) )
            navigationItem.leftBarButtonItem = saveButton
        
        }
        else {
            let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveButton) )
            navigationItem.leftBarButtonItem = saveButton
            
            let renameButton = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(self.renameButton) )
            navigationItem.rightBarButtonItem = renameButton
        }
    }
    
}

extension UICollectionView {
    func reset() {
        self.backgroundView = nil
    }
    func setEmptyMessage( message: String ) {
        let emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height) )
        emptyMessageLabel.text = message
        emptyMessageLabel.textColor = .black
        emptyMessageLabel.numberOfLines = 0;
        emptyMessageLabel.textAlignment = .center;
        emptyMessageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        emptyMessageLabel.sizeToFit()
        
        self.backgroundView = emptyMessageLabel;
    }
}
