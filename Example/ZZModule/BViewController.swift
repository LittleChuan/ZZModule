//
//  BViewController.swift
//  ZZModule_Example
//
//  Created by Chuan on 2020/3/4.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZZModule

class BViewController: UIViewController, ZZModuleViewControllerProtocol {
    static var scheme: String {
        "zz://test/b"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "B"
        view.backgroundColor = .white
    }
    
}
