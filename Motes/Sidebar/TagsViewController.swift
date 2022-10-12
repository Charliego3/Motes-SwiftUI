//
//  TagsViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa

class TagsViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.allowsExpansionToolTips = true
    }
    
}

extension TagsViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let tag = item as? TagItem {
            return tag.children.count
        }
        return FileItemModel.tags.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let tag = item as? TagItem {
            return tag.children[index]
        }
        return FileItemModel.tags[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is TagItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cell: NSTableCellView?
        if let tag = item as? TagItem {
            let cell1 = outlineView.makeView(withIdentifier: .tagsCell, owner: self) as? NSTextField
            cell1?.stringValue = tag.name.uppercased()
//            let btn = outlineView.makeView(withIdentifier: NSOutlineView.showHideButtonIdentifier, owner: self)
//            print("ShowHide: \(String(describing: btn))")
            
            return cell1
        } else if let file = item as? FileItem {
            cell = outlineView.makeView(withIdentifier: .tagsItemCell, owner: self) as? NSTableCellView
            cell?.textField?.stringValue = file.name
            cell?.imageView?.image = .docText
            cell?.textField?.toolTip = file.tooltip()
        }
        return cell
    }
}

extension TagsViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        item is FileItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        item is TagItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }
}
