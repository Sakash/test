//
//  Contact.swift
//  Demo
//
//  Created by Sakshi Jain on 02/01/18.
//  Copyright © 2018 Cura Admin. All rights reserved.
//

import UIKit

struct Contacts {
    let email: String
    let name: String
    let lastName: String
    let type: String
}

extension Contacts{
    static func GetAllContactGroups() -> [Contacts] {
        return loadContactsGroupsFromLocalFile("contact")
    }
    
    fileprivate static func loadContactsGroupsFromLocalFile(_ fileName : String) -> [Contacts]  {
        var contactGroup = [Contacts]()

        if let path = Bundle.main.path(forResource: fileName, ofType: "json")
        {
            if let jsonData = NSData(contentsOfFile: path)
            {
                do{
                    if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        let resContactDict = jsonResult.value(forKey: "Contacts") as! NSArray
                        print(resContactDict)

                        for dict in resContactDict  {
                            debugPrint(dict)
                            guard let email = (dict as AnyObject).value(forKey: "email") as? String,
                                let name = (dict as AnyObject).value(forKey: "name") as? String,
                                let lastName = (dict as AnyObject).value(forKey:"lastName")  as? String,
                                let type = (dict as AnyObject).value(forKey:"type") as? String
                            else {
                                    fatalError("Error parsing dict \(dict)")
                            }
                            
                            let contact = Contacts(email: email, name: name, lastName: lastName, type: type)
                            contactGroup.append(contact)
                        }
                    }
                }
                catch
                {
                    print(error)
                }
            }
        }
        
        return contactGroup
    }
}
