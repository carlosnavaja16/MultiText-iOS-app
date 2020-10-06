//
//  ViewController.swift
//  Multitext0.2
//
//  Created by Carlos Rossi on 7/3/20.
//  Copyright © 2020 Carlos Rossi. All rights reserved.
//

import UIKit
import Contacts

//MARK: Selectable contacts struct
struct SelectableContact{
    
    var firstName:String = ""
    var lastName:String = ""
    var PhoneNumbers = [CNLabeledValue<CNPhoneNumber>]()
    var selected:Bool = false
    var visible:Bool = true
}

//MARK: Main viewController set up and functions
class ContactSelectionViewController: UIViewController{

    //declaration of outlet for the tableView in the storyboard
    @IBOutlet var contactsTable: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var SelectAllButton: UIButton!
    
    //main contact array declaration
    var allContacts = [SelectableContact]()

    //function for returing the users contacts
    func returnContacts(){
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            
            if let err = err{
                print("Encountered an error while requesting contacts access: ", err)
            }
            
            if granted{
                print("Access to contacts granted")
                
                //describes which information will be returned from each contact
                //in this case only first and last name, and the phone numbers
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                //returns contacts sorted by firstName
                request.sortOrder = CNContactSortOrder.givenName
                
                do {
                    try store.enumerateContacts(with: request) { (contact, stopPointer) in
                            
                        var tempContact:SelectableContact = SelectableContact()
                        tempContact.firstName = contact.givenName
                        tempContact.lastName = contact.familyName
                        tempContact.PhoneNumbers = contact.phoneNumbers
                        
                        self.allContacts.append(tempContact)
                    }
                } catch let err {
                    print("Encountered an error while enumerating contacts: ", err)
                }
                
            }
            
            else{
                print("Access to contacts not granted")
            }
        }
    }
    
    //prepare for seque
    override func prepare(for segue: UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "contactsToComposition" {
            let destVC = segue.destination as! MessageCompositionViewController
            destVC.selectedContacts = sender as! [SelectableContact]
        }
    }
    
    //function to send selected contacts to the message composition VC
    @IBAction func didPressCompose(_ sender: Any) {
        
        var selectedContacts = [SelectableContact]()
        //put the selected contacts in a separate array and send it to the message
        //composition view controller
        for i in 0 ..< allContacts.count{
            if allContacts[i].selected {
                selectedContacts.append(allContacts[i])
            }
        }
        
        performSegue(withIdentifier: "contactsToComposition", sender:selectedContacts)
        
    }

    
    //function to determine the status of the select all button
    //when it says "select all" or "unselect all"
    func determineSelectAllMode(){
        var allChecked:Bool = true
        
        for i in 0 ..< allContacts.count{
            if(allContacts[i].visible){
                if(allContacts[i].selected == false){
                    allChecked = false
                }
            }
        }
        
        if allChecked{
            SelectAllButton.setTitle(" Unselect all", for: .normal)
            SelectAllButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        }
        
        else{
            SelectAllButton.setTitle(" Select all", for: .normal)
            SelectAllButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up button
        SelectAllButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        
        //set up to use custom cell
        let nib = UINib(nibName: "ContactSelectionTableViewCell", bundle: nil)
        contactsTable.register(nib, forCellReuseIdentifier: "ContactSelectionTableViewCell")
        
        //set viewController as delegate
        contactsTable.delegate = self
        contactsTable.dataSource = self
        searchBar.delegate = self
        returnContacts()

    }
    
    //MARK: SelectAll button tapped
    @IBAction func SelectAllTapped(_ sender: UIButton) {
        
        var allChecked:Bool = true
        //
        for i in 0..<allContacts.count{
            if(allContacts[i].visible == true){
                if(allContacts[i].selected == false){
                    allChecked = false;
                }
                allContacts[i].selected = true
            }
        }
        
        //if all contacts are already checked then unckeck them all instead
        if(allChecked){
            
            for i in 0..<allContacts.count{
                if(allContacts[i].visible){
                    allContacts[i].selected = false
                }
            }
        }
        contactsTable.reloadData()
        determineSelectAllMode()
    }
}

// MARK: Search bar functions
extension ContactSelectionViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText == ""{

            for i in 0..<allContacts.count{
                allContacts[i].visible = true
            }
        }
        
        else{
            for i in 0..<allContacts.count{
                if (allContacts[i].firstName.lowercased() + " " + allContacts[i].lastName.lowercased()).contains(searchText.lowercased()){
                    allContacts[i].visible = true
                }
                
                else{
                    allContacts[i].visible = false
                }

            }
        }
        contactsTable.reloadData()
        determineSelectAllMode()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        
        if SelectAllButton.title(for: .normal) == " Unselect all"{
            SelectAllButton.setTitle(" Select all", for: .normal)
            SelectAllButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        }
        
        for i in 0..<allContacts.count{
            allContacts[i].visible = true
        }
        
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        
        
        contactsTable.reloadData()
        determineSelectAllMode()
    }
}

// MARK: Table view functions
extension ContactSelectionViewController: UITableViewDataSource, UITableViewDelegate{
    
    //required tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactSelectionTableViewCell", for: indexPath) as! CustomContactCell
        
        cell.index = indexPath
        cell.title?.text = allContacts[indexPath.row].firstName + " " + allContacts[indexPath.row].lastName
        cell.subtitle?.text = allContacts[indexPath.row].PhoneNumbers.first?.value.stringValue
        
        cell.delegate = self
        if allContacts[indexPath.row].selected{
            cell.check()
        }
        else{
            cell.uncheck()
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if allContacts[indexPath.row].visible{
            return 60.0
            
        }
            
        else{
            return 0.0
        }
    }
    
}

// MARK: CustomContactCell functions
extension ContactSelectionViewController: customContactCellDelegate{
    
    func didPressCheck(index: Int) {
        
        if(allContacts[index].selected){
            allContacts[index].selected = false
        }
        
        else{
            allContacts[index].selected = true
        }
        
    }
}

