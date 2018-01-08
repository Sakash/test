//
//  ContactDetailViewController.swift
//  Demo
//
//  Created by Sakshi Jain on 26/12/17.
//  Copyright © 2017 Cura Admin. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    var contactInfoDict : ContactViewModel!

    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var phoneLabel : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = "\(contactInfoDict.name) \(contactInfoDict.lastName)"
        phoneLabel.text = "\(contactInfoDict.email)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
