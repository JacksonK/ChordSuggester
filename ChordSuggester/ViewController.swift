//
//  ViewController.swift
//  ChordSuggester
//
//  Created by Jackson Kurtz on 5/8/18.
//  Copyright © 2018 Jackson Kurtz. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var stockImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var savedProgressions: [Progression] = []
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("savedProgressions")
    var ourDefaults = UserDefaults.standard
    var dateFormatter = DateFormatter()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedProgressions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.nameLabel.text = savedProgressions[indexPath.row].name
        cell.dateLabel.text = "Date created: " + savedProgressions[indexPath.row].date_created
        cell.keyLabel.text = "Key: " + savedProgressions[indexPath.row].key
        cell.lengthLabel.text = "Number of chords: " + savedProgressions[indexPath.row].length

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showProgression", sender: self )
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirmationAlert  = UIAlertController( title: "Are you sure you want to delete this progression?" , message: nil, preferredStyle: .alert)
            let deleteAction = UIAlertAction( title: "Delete", style: .default, handler:{ action in
                self.savedProgressions.remove(at: indexPath.row )
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.updatePersistentStorage()
            } )
            let cancelAction = UIAlertAction( title: "Cancel", style: .cancel, handler: nil)
            confirmationAlert.addAction( deleteAction )
            confirmationAlert.addAction( cancelAction )
            
            self.present( confirmationAlert, animated: true)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        FirebaseApp.configure()
        
        if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: ViewController.archiveURL.path) as? [Progression] {
            savedProgressions = tempArr
        }
        
    }
    
    func updatePersistentStorage() {
        NSKeyedArchiver.archiveRootObject(savedProgressions, toFile: ViewController.archiveURL.path)
            ourDefaults.set(Date(), forKey: "lastUpdate")
    }

    @IBAction func unwindSegue(_ sender: UIStoryboardSegue ) {
        if sender.source is ProgressionViewController {
            if let senderVC = sender.source as? ProgressionViewController {
                if( senderVC.isNew )! {
                    savedProgressions.append(senderVC.progression)
                }
                else {
                    savedProgressions[senderVC.progressionIndex!] = senderVC.progression
                }
            }
            tableView.reloadData()
            updatePersistentStorage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProgressionViewController {
            destination.progression = savedProgressions[(tableView.indexPathForSelectedRow?.row)!]
            destination.isNew = false
            destination.progressionIndex = (tableView.indexPathForSelectedRow?.row)!
            if(Int(destination.progression.length)! == destination.progression.chords.count) {
                destination.currentChordIndex = destination.progression.chords.count - 1
            }
            else {
                destination.currentChordIndex = destination.progression.chords.count
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

