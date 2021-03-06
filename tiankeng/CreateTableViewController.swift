//
//  CreateTableViewController.swift
//  tiankeng
//
//  Created by 李源 on 2017/3/19.
//  Copyright © 2017年 foxerlee. All rights reserved.
//

import UIKit
import os.log
//import LeanCloud
import AVOSCloud

class CreateTableViewController: UITableViewController {
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var message: Message!
    let pk = AVObject(className: "Packages")
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //let section = ["货物详情", "寄货人信息", "送货人信息"]
        let currentUser = AVUser.current()
        
        let founderPhone = currentUser?.mobilePhoneNumber
        
        
        let defaultPhoto = UIImage(named: "defaultImage")
        
        message = Message(package: "", describe: "", time: "", remark: "", name: "", phone: "", address: "", founderPhone: founderPhone!, founderAddress: "", courierPhone: "", courierAddress: "", photo: defaultPhoto, ID: "", state: "")
        
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    //取消按钮
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        //货物详情的cell
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCreateTableViewCell", for: indexPath) as! PackageCreateTableViewCell
            cell.packageLabel.text = message?.package
            cell.describeLabel.text = message?.describe
            cell.timeLabel.text = message?.time
            cell.photoImageView.image = message?.photo
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
        //寄货人的cell
        else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FounderTableViewCell", for: indexPath) as! FounderTableViewCell
            
            let currentUser = AVUser.current()
            
            cell.founderNameLabel.text = currentUser?.username
            cell.FounderPhoneLabel.text = currentUser?.mobilePhoneNumber
            cell.founderAddressLabel.text = currentUser?.object(forKey: "address") as? String
            
            return cell
        }
        //收货人的cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverTableViewCell", for: indexPath) as! ReceiverTableViewCell
            
            cell.ReceiverNameLabel.text = message?.name
            cell.ReceiverPhoneLabel.text = message?.phone
            cell.ReceiverAddressLabel.text = message?.address
            
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "货物信息"
        }
        
        else if (section == 1) {
            return "寄货人信息"
        }
        
        else {
            return "收货人信息"
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            os_log("The save button was not pressed, canceiling", log:OSLog.default, type: .debug)
            return
        }
        
        let data = UIImagePNGRepresentation(message.photo!)
        let photo = AVFile.init(data: data!)

        pk.setObject(message.package!, forKey: "package")
        pk.setObject(message.describe!, forKey: "describe")
        pk.setObject(message.time!, forKey: "time")
        pk.setObject(message.remark!, forKey: "remark")
        
        pk.setObject(message.state!, forKey: "state")
        
        pk.setObject(message.name!, forKey: "name")
        pk.setObject(message.phone!, forKey: "phone")
        pk.setObject(message.address!, forKey: "address")
        
        pk.setObject(message.founderPhone, forKey: "founderPhone")
        pk.setObject(photo, forKey: "photo")
                    
        pk.saveInBackground()

    }
    

    @IBAction func unwindToSaveButton(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateViewController, let message = sourceViewController.message {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                self.message.package = message.package
                self.message.describe = message.describe
                self.message.time = message.time
                self.message.remark = message.remark
                self.message.photo = message.photo
                
                self.message.state = message.state
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            
            updateSaveButtonState()
        }
    }
    
    @IBAction func unwindToSaveReceiverButton(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CreateReceiverViewController, let message = sourceViewController.message {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                self.message.name = message.name
                self.message.phone = message.phone
                self.message.address = message.address
            
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
        }
        
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
      
        saveButton.isEnabled = (!(message.package?.isEmpty)! && !(message.describe?.isEmpty)! && !(message.time?.isEmpty)! && !(message.remark?.isEmpty)! && !(message.name?.isEmpty)! && !(message.phone?.isEmpty)! && !(message.address?.isEmpty)!)

    }
}
