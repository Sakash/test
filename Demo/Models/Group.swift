//
//  Group.swift
//  Demo
//
//  Created by Sakshi Jain on 02/01/18.
//  Copyright © 2018 Cura Admin. All rights reserved.
//

import UIKit

struct Groups {
    let name: String
    let type: String
    var isExpandable : String
    var isExpanded: String
    let contact: Array<Any>
}

struct Contact {
    //let email: String
    let name: String
    let number: String
    let type: String
}

extension Groups{
    static func getGroup() -> [Groups] {
        return loadGroupsFromLocal("contact")
    }
    
    fileprivate static func loadGroupsFromLocal(_ fileName : String) -> [Groups] {
        var groups = [Groups]()
        if let path = Bundle.main.path(forResource: fileName, ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                do{
                    if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        let groupDict = jsonResult.value(forKey: "groups") as! NSArray
                        print(groupDict)
                        
                        groups = scanGroup(groupDict)
                    }
                }
                catch
                {
                    print(error)
                }
            }
        }
        
        return groups
    }
    
    @discardableResult
    fileprivate static func scanGroup(_ groupsArr: NSArray) -> [Groups] {
        var groups = [Groups]()
        
        for dict in groupsArr  {
            
            guard
                let name = (dict as AnyObject).value(forKey: "name") as? String,
                let type = (dict as AnyObject).value(forKey: "type") as? String,
                let contacts = (dict as AnyObject).value(forKey: "contacts") as? NSArray
                else {
                    fatalError("Error parsing dict \(dict)")
            }
            var groupsContacts = [Contact]()
            var isExpandable = "no"
            let isExpanded = "no"
            if (contacts.count > 0)
            {
                isExpandable = "yes"
                groupsContacts = scanGroupConacts(contacts)
            }
            let group = Groups(name: name, type: type , isExpandable: isExpandable, isExpanded: isExpanded, contact: groupsContacts)
            groups.append(group)
        }
        
        return groups
    }
    
    @discardableResult
    fileprivate static func scanGroupConacts(_ contacts: NSArray) -> [Contact] {
        var groupsContacts = [Contact]()
        
        for contact in contacts{
            
            if let type = (contact as AnyObject).value(forKey: "type") as? String, type == "Contact"
            {
                guard
                    let name = (contact as AnyObject).value(forKey: "name") as? String,
                    let number = (contact as AnyObject).value(forKey: "number") as? String,
                    let type = (contact as AnyObject).value(forKey: "type") as? String
                    else {
                        fatalError("Error parsing dict \(contact)")
                }
                
                let contact = Contact(name: name, number: number, type: type)
                groupsContacts.append(contact)
            }else
            {
                scanGroup([contact] as NSArray)
            }
        }
        return groupsContacts
    }
}
