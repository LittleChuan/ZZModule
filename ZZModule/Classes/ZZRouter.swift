//
//  ZZRouter.swift
//  Nimble
//
//  Created by Chuan on 2020/3/3.
//

import UIKit

public enum JumpStyle {
    case Push
    case Present
}

public func jump(_ scheme: SchemeConvertible, style: JumpStyle = .Push, params: ZZModuleParams = nil) {
    guard let visible = UIWindow.visibleViewController, let viewController = ZZModule.object(scheme) as? ZZModuleViewControllerProtocol else { return }
    
    viewController.fillParams(params)
    
    visible.navigationController?.pushViewController(viewController, animated: true)
    
}


private extension UIWindow {
    static var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(UIApplication.shared.keyWindow?.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
