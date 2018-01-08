//
//  ContactTableViewController.swift
//  Demo
//
//  Created by Cura Admin on 26/12/17.
//  Copyright © 2017 Cura Admin. All rights reserved.
//

import UIKit

let mainScreenSize = UIScreen.main.bounds.size

class ContactTableViewController: UITableViewController {

    var expandIndex = NSIndexPath() // Variable to control reloading of section/rows
    var contactViewModel = [ContactViewModel]()
    var groupViewModel = [GroupViewModel]()

    var groupContactViewModelBase = GroupContactViewModelBase()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        expandIndex = NSIndexPath(item: -1, section: 2)
        
        groupContactViewModelBase.callContactToGetData { (response) in
            debugPrint(response)
            
            for item in response
            {
                self.contactViewModel.append(item)
            }
        }
        groupContactViewModelBase.callGroupToGetData { (response) in
            debugPrint(response)
            
            for item in response
            {
                self.groupViewModel.append(item)
            }
        }
        
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    // Method: To Modify Group Array to keep bool variables like isExpandable,isExpanded
    func modifyingGroupArray( arr : inout NSArray) -> NSArray
    {
        for var info in arr
        {
            if var arr1 : NSArray = (info as AnyObject).value(forKey: "contacts") as? NSArray, arr.count > 0
            {
                let tempDict = info as! NSDictionary
                tempDict.setValue("yes", forKey: "isExpandable")
                tempDict.setValue("no", forKey: "isExpanded")
                info = tempDict
                
                arr1 = self.modifyingGroupArray(arr: &arr1)
            }
        }
            
        return arr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source & delegate methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        if (contactViewModel.count > 0 && groupViewModel.count > 0)
        {
            return 2 + groupViewModel.count
        }
        else if contactViewModel.count > 0  {
            return 1
        }
        else if groupViewModel.count > 0  {
            return 1 + groupViewModel.count
        }
        else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView : UIView = UIView()
        headerView.frame = CGRect(x:0, y:0, width: mainScreenSize.width, height: 40)
        headerView.backgroundColor = UIColor.white
        
        let headerLabel : UILabel = UILabel()
        headerLabel.frame = CGRect(x:10, y:2, width:mainScreenSize.width - 10, height:35)
        headerLabel.textAlignment = NSTextAlignment.left
        headerLabel.backgroundColor = UIColor.white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        headerLabel.textColor = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
        
        switch section {
        case 0:
            headerLabel.text = "Contacts"
        case 1:
            headerLabel.text = "Groups"
        default:
            let groupInfoDict = groupViewModel[section - 2]
            headerLabel.text = groupInfoDict.name
            headerLabel.tag = section - 2
           
            headerLabel.frame = CGRect(x:30, y:5, width:mainScreenSize.width - 30, height:21)
            headerLabel.backgroundColor = UIColor.clear
            headerLabel.font = UIFont.systemFont(ofSize: 15.0)
            headerLabel.textColor = UIColor.black
            
            let tap: CustomTapGestureRecognizer = CustomTapGestureRecognizer(
                target: self,
                action: #selector(reloadRowsAtSection(tap:)))
            tap.tag = section - 2
            headerView.addGestureRecognizer(tap)
        }
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return  50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return contactViewModel.count
        case 1:
            return 0
        default:
            var rowCount = 0
            if (expandIndex.row != -1 && expandIndex.section == section)
            {
                let groupInfoDict = groupViewModel[expandIndex.row]
                rowCount = groupInfoDict.contact.count
            }
            return rowCount
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell :  ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: "contactReuseIdentifier", for: indexPath) as! ContactTableViewCell
            
            let contactInfo = contactViewModel[indexPath.row]
            
            cell.nameLabel.text = "\(contactInfo.name) \(contactInfo.lastName)"
            cell.phoneLabel.text = contactInfo.email
            
            return cell
        }
        else
        {
            let cell : GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "groupReuseIdentifier", for: indexPath) as! GroupTableViewCell
            
            if (expandIndex.row != -1)
            {
                let arr : Contact = groupViewModel[expandIndex.row].contact[indexPath.row] as! Contact
                cell.groupNameLabel.text = arr.name
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            self.performSegue(withIdentifier: "showContactDetail", sender: self)
        }
        else if (expandIndex.row != -1 && expandIndex.section == indexPath.section)
        {
            let groupInfoDict = groupViewModel[expandIndex.row]

            if let isExpandable :String = groupInfoDict.isExpandable ,isExpandable == "yes"
            {
                // Insert Further rows
                
                
            }
        }
    }
    
    // Method: Tap Gesture recogniser
    func reloadRowsAtSection(tap : CustomTapGestureRecognizer)  {
       
        if expandIndex.section - 2 == tap.tag && expandIndex.row != -1
        {
            expandIndex = NSIndexPath(item: -1, section: expandIndex.section)
            let groupInfoDict = groupViewModel[expandIndex.section - 2]
            groupInfoDict.isExpanded = "no"
           
            let indices: IndexSet = [expandIndex.section]
            self.tableView.reloadSections(indices, with: UITableViewRowAnimation.fade)
            
            return
        }
        
        if expandIndex.row != -1
        {
            expandIndex = NSIndexPath(item: -1, section: expandIndex.section)
            let groupInfoDict = groupViewModel[expandIndex.section - 2]
            groupInfoDict.isExpanded = "no"
            
            let indices: IndexSet = [expandIndex.section]
            self.tableView.reloadSections(indices, with: UITableViewRowAnimation.fade)
        }
        
        let groupInfoDict = groupViewModel[tap.tag]
        
        if groupInfoDict.isExpandable == "yes"
        {
            if groupInfoDict.isExpanded == "no"
            {
                expandIndex = NSIndexPath(item: tap.tag, section: tap.tag + 2)
                groupInfoDict.isExpanded = "yes"
            }
            else
            {
                expandIndex = NSIndexPath(item: -1, section: tap.tag + 2)
                groupInfoDict.isExpanded = "no"
            }
            let indices: IndexSet = [tap.tag + 2]
            self.tableView.reloadSections(indices, with: UITableViewRowAnimation.fade)
        }
    }
    
    // Storyboard Segue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showContactDetail" {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let vc = segue.destination as! ContactDetailViewController
                vc.contactInfoDict = contactViewModel[indexPath.row]
            }
        }
    }
}
