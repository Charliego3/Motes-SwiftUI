//
//  FileItem.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Swift
import Foundation
import AppKit

class FileItemModel: ObservableObject {
    static let allowedExt = ["md", "markdown"]
    static let shared = FileItemModel()
    static let tags: [TagItem] = [
        TagItem("database", children: [shared.files[0], shared.files[1], shared.files[3]]),
        TagItem("java", children: [shared.files[0], shared.files[1], shared.files[3]]),
        TagItem("golang", children: [shared.files[0], shared.files[1], shared.files[3]]),
    ]
    @Published var files: [FileItem]
    
    init(_ files: [FileItem] = []) {
        self.files = files
    }
    
    static func fileHasExpanded(_ outlineView: NSOutlineView) -> Bool {
        return shared.files.first(where: { outlineView.isItemExpanded($0) }) != nil
    }
    
    static func loadFiles(windowController: MainWindowController?, needReload reload: Bool = false) -> MainWindowController? {
        guard let bookmark = Defaults.bookmark else {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Load directory bookmark error"
            alert.informativeText = "this is informativeText"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return windowController
        }
        
        var bookmarkDataIsStale: Bool = false
        let pathURL = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
        guard let pathURL = pathURL else {
            return windowController
        }
        
        if !pathURL.startAccessingSecurityScopedResource() {
            print("授权失败")
            return windowController
        }
        
        defer {
            pathURL.stopAccessingSecurityScopedResource()
        }
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: pathURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return windowController
        }
        guard let items = FileItemModel.resolvingFiles(files: files) else {
            return windowController
        }
        
        shared.files.append(contentsOf: items)
        
        var windowController = windowController
        if windowController == nil {
            windowController = MainWindowController()
        }
        if reload {
//            windowController?.sidebarViewController.reloadData()
            
            windowController?.sidebarViewController.rootView.contentViewController.tabsViewController.notesViewController.outlineView.reloadData()
        }
//        if let toolbar = windowController?.window?.toolbar as? Toolbar {
//            toolbar.toggleDetail(nil)
//            toolbar.toggleDetail(nil)
//        }
        windowController?.showWindow()
        return windowController
    }
    
    static func resolvingFiles(files: [URL]) -> [FileItem]? {
        var items: [FileItem]?
        for fileURL in files {
            guard let attr = try? FileManager.default.attributesOfItem(atPath: fileURL.path) else {
                print("read file attr error")
                continue
            }
            
            let name = fileURL.deletingPathExtension().lastPathComponent
            let ext = fileURL.pathExtension
            let directory = attr[.type] as? String == "NSFileTypeDirectory"
            let createAt = attr[.creationDate] as? Date
            let updateAt = attr[.modificationDate] as? Date
            var children: [FileItem]?
            
            if !directory && !allowedExt.contains(ext) {
                continue
            }
            
            if directory {
                if let subFiles = try? FileManager.default.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                    if let subItems = resolvingFiles(files: subFiles) {
                        children = subItems
                    }
                }
            }
            
            if items == nil {
                items = []
            }
            items?.append(FileItem(fileURL, name: name, directory: directory, createAt: createAt, updateAt: updateAt, children: children))
        }
        return sortItems(items)
    }
    
    static func sortItems(_ items: [FileItem]?) -> [FileItem]? {
        return items?.sorted {
            if ($0.directory && $1.directory) ||
                (!$0.directory && !$1.directory) {
                return $0.name < $1.name
            }
            return $0.directory || !$1.directory
        }
    }
}

struct TagItem: Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var children: [FileItem]
    
    init(_ name: String, children: [FileItem]? = nil) {
        self.name = name
        self.children = children ?? []
    }
}

struct FileItem: Identifiable, Hashable {
    var id: UUID = UUID()
    var url: URL
    var name: String
    var directory: Bool
    var createAt: Date? = nil
    var updateAt: Date? = nil
    var children: [FileItem]?
    
    init(_ url: URL, name: String, directory: Bool = false, createAt: Date? = nil, updateAt: Date? = nil, children: [FileItem]? = nil) {
        self.url = url
        self.name = name
        self.directory = directory
        self.createAt = createAt
        self.updateAt = updateAt
        self.children = children
    }
    
    static func isInstance(any: Any) -> Bool {
        if let _ = any as? FileItem {
            return true
        }
        return false
    }
    
    static func isDirectory(_ any: Any) -> Bool {
        if let group = any as? FileItem {
            return group.directory
        }
        return false
    }
    
    static func expandable(_ any: Any) -> Bool {
        if let group = any as? FileItem {
            return group.numberOfItems > 0 && isDirectory(group)
        }
        return false
    }
    
    var numberOfItems: Int {
        get {
            return self.children?.count ?? 0
        }
    }
    
    mutating func addChild(_ item: FileItem) {
        self.children?.append(item)
    }
    
    func childAt(index: Int) -> FileItem {
        if index >= 0 && index < numberOfItems {
            return self.children![index]
        }

        fatalError("No child at: \(index)")
    }
    
    func tooltip() -> String {
        var tooltip = ""
        if let projectURL = Defaults.projectURL {
            let dir = url.deletingLastPathComponent().path.replacingOccurrences(of: projectURL.path, with: "")
            if !dir.isEmpty && name != dir {
                tooltip += " — \(dir.dropFirst())"
            }
        }
        return "\(name)\(tooltip)"
    }
}
