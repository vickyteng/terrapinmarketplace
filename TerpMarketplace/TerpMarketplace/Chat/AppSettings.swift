//
//  AppSettings.swift
//  TerpMarketplace
//
//  Created by Kyle Lam on 4/28/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

//import Foundation
//
//final class AppSettings {
//
//    private enum SettingKey: String {
//        case displayName
//    }
//
//    static var displayName: String! {
//        get {
//            return UserDefaults.standard.string(forKey: SettingKey.displayName.rawValue)
//        }
//        set {
//            let defaults = UserDefaults.standard
//            let key = SettingKey.displayName.rawValue
//
//            if let name = newValue {
//                defaults.set(name, forKey: key)
//            } else {
//                defaults.removeObject(forKey: key)
//            }
//        }
//    }
//
//}
