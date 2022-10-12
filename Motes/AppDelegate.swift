//
//  AppDelegate.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: MainWindowController? = nil
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let _ = Defaults.projectURL else {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = true
            panel.canDownloadUbiquitousContents = true
            panel.allowsMultipleSelection = false
            panel.allowsOtherFileTypes = false
            panel.allowedContentTypes = [.init(filenameExtension: "md")!, .init(filenameExtension: "markdown")!]

            mainWindowController = MainWindowController()
            let window = mainWindowController?.window
            panel.beginSheetModal(for: window!) { resp in
                if resp == .OK {
                    guard let bookmark = try? panel.url?.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) else {
                        print("授权失败")
                        return
                    }
                    Defaults.projectURL = panel.url
                    Defaults.bookmark = bookmark
                    _ = FileItemModel.loadFiles(windowController: self.mainWindowController, needReload: true)
                }
            }
            return
        }

        mainWindowController = FileItemModel.loadFiles(windowController: nil)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            mainWindowController?.showWindow(force: true)
        }
        return true
    }
}
