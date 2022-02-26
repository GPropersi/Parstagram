//
//  ViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/25/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(ProcessInfo.processInfo.environment["APP_ID"]!)
    }


}

