//
//  MessageCompositionViewController.swift
//  Multitext0.2
//
//  Created by Carlos Rossi on 7/29/20.
//  Copyright © 2020 Carlos Rossi. All rights reserved.
//

import UIKit
import MessageUI

protocol MessageCompositionDelegate {
    func receiveMessage(message:String)
}

class MessageCompositionViewController: UIViewController, UINavigationControllerDelegate {
    
    var selectedContacts = [SelectableContact]()

    @IBOutlet var messageInput:UITextView!
    @IBOutlet weak var selectedCountLabel: UILabel!
    
    
    @IBAction func firstNamePressed(_ sender: UIButton) {
        messageInput.text.append(contentsOf: "{firstName}")
    }
    
    @IBAction func lastNamePressed(_ sender: UIButton) {
        messageInput.text.append(contentsOf: "{lastName}")
    }
    
    //sets up VC intitially by setting the number of contacts selected in the label
    func setUp(){
        if selectedContacts.count == 1{
            selectedCountLabel.text = "1 contact selected"
        }
        else{
            selectedCountLabel.text = String(selectedContacts.count) + " contacts selected"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageInput.layer.cornerRadius = 10
        
        setUp()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        sendMessage(contact: selectedContacts.removeFirst())
    }
}

extension MessageCompositionViewController: MFMessageComposeViewControllerDelegate{
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
        if(!selectedContacts.isEmpty){
            sendMessage(contact: selectedContacts.removeFirst())
        }
    }
    
    func sendMessage(contact:SelectableContact){
        
        let sendMessageViewController = MFMessageComposeViewController()
        sendMessageViewController.messageComposeDelegate = self

        //set recepient as the contact phone number
        var recepient = [String]()
        recepient.append((contact.PhoneNumbers.first?.value.stringValue)!)
        
        //replace occurences of {firstName} and {lastName} with the respective recepient's
        //first and last name
        var message = messageInput.text.replacingOccurrences(of: "{firstName}", with: contact.firstName)
        message = message.replacingOccurrences(of: "{lastName}", with: contact.lastName)
        
        //set recepient and body of the message
        sendMessageViewController.recipients = recepient
        sendMessageViewController.body = message
        
        if MFMessageComposeViewController.canSendText() {
            //present the messageVC modally
            self.present(sendMessageViewController, animated: false, completion: .none)
        }
    }
}
