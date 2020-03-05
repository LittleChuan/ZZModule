//
//  ViewController.swift
//  ZZModule
//
//  Created by ZackXXC on 03/03/2020.
//  Copyright (c) 2020 ZackXXC. All rights reserved.
//

import UIKit
import ZZModule

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ZZModule.register(AViewController.self)
//        ZZModule.register(NSClassFromString("ZZModule_Example.BViewController") as! ZZModuleProtocol.Type)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func pushA(_ sender: Any) {
        jump("zz://test/a?msg=AAA")
    }
    
    @IBAction func pushB(_ sender: Any) {
        jump("zz://test/b")
    }
    
    @IBAction func pushC(_ sender: Any) {
        // TODO: not work for OC
        jump("zz://test/c")
    }
}

