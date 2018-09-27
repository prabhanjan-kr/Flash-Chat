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


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    
    
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableview delegate and datasource
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //hiding back button
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //cofiguring tableview
        configureTableView()
        
        //textfield delegate
        messageTextfield.delegate = self
        
        //registering  tableview cell nib
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        //tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOutSideOfTextField))
        messageTableView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.avatarImageView.image = UIImage(named: "egg")
        cell.messageBody.text = "Hello there"
        cell.senderUsername.text = "John Doe"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        
        //messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["sender" : Auth.auth().currentUser?.email, "messageBody" : messageTextfield.text]
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print("error: message not sent")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                
                
            } else {
                print("message saved in db")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
        
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    
    
    
    
    
    
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
