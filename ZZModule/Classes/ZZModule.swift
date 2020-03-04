//
//  ZZModule.swift
//  Nimble
//
//  Created by Chuan on 2020/3/3.
//

import Foundation

public typealias ZZModuleParams = [String: Any]?
public typealias ZZModuleAction = (ZZModuleParams) -> ()

public protocol ZZModuleProtocol: NSObject {
    static var scheme: String { get }
    func fillParams(_ params: ZZModuleParams)
}

public extension ZZModuleProtocol {
    func fillParams(_ params: ZZModuleParams) { }
}

public class ZZModule {
    
    public static let shared = ZZModule()
    
    private let queue = DispatchQueue(label: "ZZModule")
    
    private var schemeDic = [String: ZZModuleProtocol.Type]()
    
    public static func register(_ cls: ZZModuleProtocol.Type) {
        shared.queue.async {
            if let (schemeString, _) = cls.scheme.asScheme() {
                shared.schemeDic[schemeString] = cls
            }
        }
    }
    
    public static func deregister(_ scheme: SchemeConvertible) {
        shared.queue.async {
            if let (schemeString, _) = scheme.asScheme() {
                shared.schemeDic[schemeString] = nil
            }
        }
    }
    
    public static func object(_ scheme: SchemeConvertible) -> NSObject? {
        if let (schemeString, params) = scheme.asScheme(), let cls = shared.schemeDic[schemeString] {
            let obj = cls.init()
            obj.fillParams(params)
            return obj
        }
        return nil
    }
}

public protocol SchemeConvertible {
    /// Returns a (String, ZZModuleParams) if `self` represents a valid URL string or return `nil`.
    /// - returns: A (String, ZZModuleParams) or `nil`.
    func asScheme() -> (String, ZZModuleParams)?
}

extension String: SchemeConvertible {
    public func asScheme() -> (String, ZZModuleParams)? {
        guard let url = URLComponents(string: self),
            let scheme = url.scheme,
            let host = url.host
            else { return nil }
        let params: [String: Any] = (url.queryItems ?? []).reduce(into: [:]) {
            query, queryItem in
            query[queryItem.name] = queryItem.value
        }
        return (scheme + host + url.path, params)
    }
}
