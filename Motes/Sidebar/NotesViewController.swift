//
//  NotesViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa
import SwiftUI

class NotesOutlineView: EditableOutlineView {
    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        var rect = super.frameOfOutlineCell(atRow: row)
        rect.size.height = 27
        return rect
    }
}

class NotesViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    private let contextMenu = NSMenu(title: UUID().uuidString)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineView.usesAutomaticRowHeights = false
        outlineView.doubleAction = #selector(doubleAction)
        
        contextMenu.delegate = self
        outlineView.menu = contextMenu
    }
    
    @objc func doubleAction(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        guard let fileItem = item as? FileItem else { return }
        if fileItem.directory {
            if fileItem.numberOfItems <= 0 {
                return
            }
            
            if outlineView.isItemExpanded(item) {
                outlineView.animator().collapseItem(item)
            } else {
                outlineView.animator().expandItem(item)
            }
        }
        
        guard let toolbar = MainWindowController.toolbar else { return }
        toolbar.toggleExpanded(FileItemModel.fileHasExpanded(outlineView))
    }
}

extension NotesViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        guard outlineView.clickedRow >= 0 else { return }
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? FileItem else { return }
        print("Clicked FileItem: \(item.name)")
      
        let openInWindowItem = NSMenuItem(title: "Open in window", action: #selector(menuOpenInWindowButtonPressed), keyEquivalent: "")
        openInWindowItem.target = self
        openInWindowItem.representedObject = item
        menu.addItem(openInWindowItem)

        let showInFinderItem = NSMenuItem(title: "Show in finder", action: #selector(menuShowInFinder), keyEquivalent: "")
        showInFinderItem.target = self
        showInFinderItem.representedObject = item
        menu.addItem(showInFinderItem)
    }
    
    @objc func menuOpenInWindowButtonPressed(_ item: NSMenuItem) {
        print("menuOpenInWindowButtonPressed is triggered.... \(item)")
    }
    
    @objc func menuShowInFinder(_ item: NSMenuItem) {
        print("menuShowInFinder is triggered.... \(item) -- \(String(describing: item.representedObject))")
    }
}

extension NotesViewController: NSOutlineViewDelegate {}

extension NotesViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let fileItem = item as? FileItem {
            return fileItem.numberOfItems
        }
        return FileItemModel.shared.files.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let fileItem = item as? FileItem {
            return fileItem.childAt(index: index)
        }
        return FileItemModel.shared.files[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        FileItem.expandable(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let fileItem = item as? FileItem else { return nil }
        guard let cell = outlineView.makeView(withIdentifier: .notesDataCell, owner: self) as? NSTableCellView else { return nil }
        cell.textField?.stringValue = fileItem.name
        cell.imageView?.image = NSImage(systemSymbolName: fileItem.directory ? "folder.fill" : "doc.text.image", accessibilityDescription: nil)
        return cell
    }
}
