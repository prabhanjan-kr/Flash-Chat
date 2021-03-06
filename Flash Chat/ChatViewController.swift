//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    //user defaults
    let defaults = UserDefaults.standard
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //message textfield responder
        messageTextfield.becomeFirstResponder()
        
        
        //tableview delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //hiding back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        
        //textfield delegate
        messageTextfield.delegate = self
        
        //registering  tableview cell nib
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        //tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutSideOfTextField))
        messageTableView.addGestureRecognizer(tapGestureRecognizer)
        
        //cofiguring tableview
        configureTableView()
        //looking for new msgs in db
        retrieveMessagesFromDB()
        
 
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.avatarImageView.image = UIImage(named: "egg")
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        
        //sent message and recieved message differentiation
        if messageArray[indexPath.row].sender == Auth.auth().currentUser?.email as! String {
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        else  {
            cell.messageBackground.backgroundColor = UIColor.flatMint()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tappedOutSideOfTextField() {
        print("tap detected")
        messageTextfield.endEditing(true)
    }
    
    
    // for message cell Automatic height based on message size
    func configureTableView() {
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
        messageTableView.separatorStyle = .none
    }
    
    //MARK:- TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 320
            self.view.layoutIfNeeded()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        //messageTextfield.endEditing(true)
        //messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        let messageDB =
            Database.database().reference().child("Messages")
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email, "messageBody" : messageTextfield.text]
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print("error: message not sent")
              
            } else {
                print("message saved in db")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        //retrieveMessagesFromDB()
        self.messageTextfield.isEnabled = true
        self.sendButton.isEnabled = true
        
        configureTableView()
        self.messageTableView.reloadData()
        
    }
    
   
    //looking for new msgs in DB
    func retrieveMessagesFromDB() {
        
        let database = Database.database().reference().child("Messages")
        database.observe(.childAdded)
        { (snapshot) in
            
            
            let newMessage = Message()
            let snapShotDict = snapshot.value as! [String : String]
            newMessage.sender = snapShotDict["sender"]!
            newMessage.messageBody = snapShotDict["messageBody"]!
            self.messageArray.append(newMessage)
            self.configureTableView()
            self.messageTableView.reloadData()
            self.scrollToBottom()
            
        }
        
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            SVProgressHUD.show()
            try Auth.auth().signOut()
            SVProgressHUD.dismiss()
            _ = navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Sign out error")
            SVProgressHUD.dismiss()
        }
        
    }
    
    
    
}
