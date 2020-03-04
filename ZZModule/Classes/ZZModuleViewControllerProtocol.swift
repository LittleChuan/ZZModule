//
//  ZZModuleViewControllerProtocol.swift
//  Nimble
//
//  Created by Chuan on 2020/3/3.
//

import UIKit

public protocol ZZModuleViewControllerProtocol: UIViewController, ZZModuleProtocol {
    static var navigationControllerForPresented: UINavigationController? { get }
}

public extension ZZModuleViewControllerProtocol {
    static var navigationControllerForPresented: UINavigationController? { nil }
}
