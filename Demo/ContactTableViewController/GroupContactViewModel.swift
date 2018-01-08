//
//  GroupContactViewModel.swift
//  Demo
//
//  Created by Sakshi Jain on 03/01/18.
//  Copyright © 2018 Cura Admin. All rights reserved.
//

import UIKit

class ContactViewModel: NSObject {
    private var contact : Contacts
   
    init(_ contact : Contacts) {
        self.contact = contact
    }
    
    var email: String {
        return contact.email
    }
    
    var name: String {
        return contact.name
    }
    
    var lastName: String {
        return contact.lastName
    }
    
    var type: String {
        return contact.type
    }
}

class GroupViewModel: NSObject {
    private var group : Groups
    
    init(_ group : Groups) {
        self.group = group
    }
    
    var isExpandable: String {
        set { group.isExpandable = isExpandable }
        get { return group.isExpandable }
    }
    
    var name: String {
        return group.name
    }
    
    var isExpanded: String {
        set { group.isExpanded = isExpanded }
        get { return group.isExpanded }
    }
    
    var type: String {
        return group.type
    }
    
    var contact: Array<Any> {
        return group.contact
    }
}   


class GroupContactViewModelBase: NSObject {
    var conatctModel : Contacts?
    var contactViewModel = [ContactViewModel]()
    var groupViewModel = [GroupViewModel]()

    var contacts = [Contacts]()
    var groups = [Groups]()
    
    func callContactToGetData(completion: @escaping (_ result: [ContactViewModel]) -> Void) {
        
        contacts = Contacts.GetAllContactGroups()
        for item in contacts
        {
            let contact = ContactViewModel( item )
            
            contactViewModel.append(contact)
        }
        
        debugPrint(contactViewModel)
        completion(contactViewModel)
    }
    
    func callGroupToGetData(completion: @escaping (_ result: [GroupViewModel]) -> Void) {
        groups = Groups.getGroup()
        
        for item in groups
        {
            let group = GroupViewModel( item )
            
            groupViewModel.append(group)
        }
        
        debugPrint(groupViewModel)
        completion(groupViewModel)
    }
}
