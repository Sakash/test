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

    var contactArray : NSMutableArray = NSMutableArray()
    var groupArray : NSMutableArray = NSMutableArray()
    var expandIndex = NSIndexPath() // Variable to control reloading of section/rows
    
    override func viewDidLoad() {
        super.viewDidLoad()

        expandIndex = NSIndexPath(item: -1, section: 2)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let path = Bundle.main.path(forResource: "contact", ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                do{
                    if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        contactArray.addObjects(from: jsonResult.value(forKey: "Contacts") as! [Any])
                        
                        groupArray.addObjects(from: jsonResult.value(forKey: "groups") as! [Any])
                        
                        for var groupInfo in groupArray {
                            if var arr : NSArray = (groupInfo as AnyObject).value(forKey: "contacts") as? NSArray, arr.count > 0
                            {
                                let tempDict = groupInfo as! NSDictionary
                                tempDict.setValue("yes", forKey: "isExpandable")
                                tempDict.setValue("no", forKey: "isExpanded")
                                groupInfo = tempDict
                                
                                arr = self.modifyingGroupArray(arr: &arr)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
                catch
                {
                    print(error)
                }
            }
        }
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
        if (contactArray.count > 0 && groupArray.count > 0)
        {
            return 2 + groupArray.count
        }
        else if contactArray.count > 0  {
            return 1
        }
        else if groupArray.count > 0  {
            return 1 + groupArray.count
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
            let groupInfoDict = groupArray[section - 2] as! NSDictionary
            let name = groupInfoDict.value(forKey: "name")
            headerLabel.text = name as? String
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
            return contactArray.count
        case 1:
            return 0
        default:
            var rowCount = 0
            if (expandIndex.row != -1 && expandIndex.section == section)
            {
                let groupInfoDict = groupArray[expandIndex.row] as! NSDictionary
                rowCount = ((groupInfoDict.value(forKey: "contacts") as? NSArray)?.count)!
            }
            return rowCount
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0
        {
            let cell :  ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: "contactReuseIdentifier", for: indexPath) as! ContactTableViewCell
            
            let contactInfoDict = contactArray[indexPath.row] as! NSDictionary
            
            if let name = contactInfoDict.value(forKey: "name"), let lastName = contactInfoDict.value(forKey: "lastName")
            {
                cell.nameLabel.text = "\(name) \(lastName)"
            }
            
            if let email = contactInfoDict.value(forKey: "email")
            {
                cell.phoneLabel.text = "\(email)"
            }
            
            return cell
        }
        else
        {
            let cell : GroupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "groupReuseIdentifier", for: indexPath) as! GroupTableViewCell
            
            if (expandIndex.row != -1)
            {
                if let arr : NSArray = (groupArray[expandIndex.row] as AnyObject).value(forKey: "contacts") as? NSArray, arr.count > 0
                {
                    if let name = (arr[indexPath.row] as AnyObject).value(forKey: "name")
                    {
                        cell.groupNameLabel.text = "\(name)"
                    }
                }
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
            let groupInfoDict = groupArray[expandIndex.row] as! NSDictionary

            if let isExpandable :String = groupInfoDict.value(forKey: "isExpandable") as? String ,isExpandable == "yes"
            {
                // Insert Further rows
                
                
            }
        }
    }
    
    // Method: Tap Gesture recogniser
    func reloadRowsAtSection(tap : CustomTapGestureRecognizer)  {
        
        if expandIndex.section != tap.tag && expandIndex.row != -1
        {
            expandIndex = NSIndexPath(item: -1, section: expandIndex.section)
            let groupInfoDict = groupArray[expandIndex.section - 2] as! NSDictionary
            groupInfoDict.setValue("no", forKey: "isExpanded")
           
            let indices: IndexSet = [expandIndex.section]
            self.tableView.reloadSections(indices, with: UITableViewRowAnimation.fade)
        }
        
        let groupInfoDict = groupArray[tap.tag] as! NSDictionary
        
        if let isExpandable :String = groupInfoDict.value(forKey: "isExpandable") as? String ,isExpandable == "yes"
        {
            if let isExpanded :String = groupInfoDict.value(forKey: "isExpanded") as? String ,isExpanded == "no"
            {
                expandIndex = NSIndexPath(item: tap.tag, section: tap.tag + 2)
                groupInfoDict.setValue("yes", forKey: "isExpanded")
            }
            else
            {
                expandIndex = NSIndexPath(item: -1, section: tap.tag + 2)
                groupInfoDict.setValue("no", forKey: "isExpanded")
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
                vc.contactInfoDict = contactArray[indexPath.row] as! [String: String]
            }
        }
    }
}
