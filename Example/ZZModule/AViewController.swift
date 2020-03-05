//
//  AViewController.swift
//  ZZModule_Example
//
//  Created by Chuan on 2020/3/4.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ZZModule

class AViewController: UIViewController {
    
    var msg = "ddd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "A"
        view.backgroundColor = .white
        
        print(msg)
    }

}

extension AViewController: ZZModuleViewControllerProtocol {
    func fillParams(_ params: ZZModuleParams) {
        if let params = params, let newMsg = params["msg"] as? String {
            msg = newMsg
        }
    }
    
    static var scheme: String {
        "zz://test/a?hhh=aaa"
    }
}
