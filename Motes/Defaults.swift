//
//  Defaults.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa

class Defaults: NSObject {
    private static let projectPathKey = "projectPath"
    private static let urlBookmark = "projectURLBookmark"
    private static let showOnLaunchKey = "showOnLaunch"
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            showOnLaunchKey: true
        ])
    }
    
    static var showOnLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: showOnLaunchKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: showOnLaunchKey)
        }
    }
    
    static var projectURL: URL? {
        get {
            UserDefaults.standard.url(forKey: projectPathKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: projectPathKey)
        }
    }
    
    static var bookmark: Data? {
        get {
            UserDefaults.standard.data(forKey: urlBookmark)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: urlBookmark)
        }
    }
}
