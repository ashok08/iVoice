//
//  LeaveViewController.swift
//  iVoice
//
//  Created by Ashok on 31/05/21.
//

import UIKit

class LeaveViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func leaveBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
