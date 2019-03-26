//
//  ViewController.swift
//  macOSApp
//
//  Created by Mike on 2/1/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Cocoa
import Talon

class ViewController: NSViewController {

    static var connection = Connection(host: "192.168.0.2", port: 9851)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scan = Command.ObjectList.Scan(key: "fleet")
        ViewController.connection.perform(command: scan, success: { (response: ListObjectsResponse) in
            print("Response: \(response)")
        }, failure: { (error) in
            print("Error: \(error)")
        })
    }

}

