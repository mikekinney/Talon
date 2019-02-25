//
//  ViewController.swift
//  iOSApp
//
//  Created by Mike on 2/1/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import UIKit
import Talon

class ViewController: UIViewController {

    static var connection = Connection(host: "192.168.0.2", port: 9851)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scan = Command.Scan(key: "fleet")
        ViewController.connection.list(command: scan, success: { (response, objects) in
            print("Objects: \(objects)")
        }, failure: { (error) in
            print("Error: \(error)")
        })
    }

}

