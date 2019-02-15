//
//  SetupViewController.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/11/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var lengthField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    var keyPickerView = UIPickerView()
    var lengthPickerView = UIPickerView()
    var typePickerView = UIPickerView()
    
    let tonal_center = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B"]
    let progression_length = ["2","3","4","5","6","7","8"]
    let progression_type = [ "All", "Pop", "Rock", "Soul", "Hip-hop", "Funk", "Jazz"]
    //var pickerView = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Setup Progression"
        
        keyField.inputView = keyPickerView
        lengthField.inputView = lengthPickerView
        typeField.inputView = typePickerView
        keyPickerView.delegate = self
        lengthPickerView.delegate = self
        typePickerView.delegate = self
        keyField.text = tonal_center[0]
        lengthField.text = progression_length[6]
        typeField.text = progression_type[0]
        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProgressionViewController {
            destination.progression = Progression(key: keyField.text!, length: lengthField.text!)
            destination.isNew = true
        }
    }
    
    @IBAction func createPressed(_ sender: Any) {
        if( keyField.text == "" || lengthField.text == "" ) {
            let errorAlert  = UIAlertController( title: "You must input key and length of progression!" , message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction( title: "Ok", style: .cancel, handler: nil)
            errorAlert.addAction( okAction )
            self.present( errorAlert, animated: true)
        }
        else {
            performSegue(withIdentifier: "createProgression", sender: sender)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if( pickerView == keyPickerView ) {
            return tonal_center.count
        }
        else if ( pickerView == typePickerView ) {
            return progression_type.count
        }
        else {
            return progression_length.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if( pickerView == keyPickerView ) {
            return tonal_center[row]
        }
        else if( pickerView == typePickerView  ) {
            return progression_type[row]
        }
        else {
            return progression_length[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if( pickerView == keyPickerView ) {
            /*
            if( row == 0 ) {
                keyField.text = ""
            }
            else {
                keyField.text = tonal_center[row]
            }
            */
            keyField.text = tonal_center[row]
        }
        else if( pickerView == typePickerView ) {
            /*
            if( row == 0 ) {
                typeField.text = ""
            }
            else {
                typeField.text = progression_type[row]
            }
            */
            typeField.text = progression_type[row]
        }
        else {
            /*
            if( row == 0 ) {
                lengthField.text = ""
            }
            else {
                lengthField.text = progression_length[row]
            }
            */
            lengthField.text = progression_length[row]
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
