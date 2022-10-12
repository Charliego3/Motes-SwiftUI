//
//  FileTableCellView.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/20.
//

import Cocoa

class FileTableCellView: NSTableCellView {
    
    static let cellNib = NSNib(nibNamed: "FileTableCellView", bundle: nil)
    
    /// Both imageView and textField are linked
    @IBOutlet private weak var subtitleLabel: NSTextField!

    func configure(with item: FileItem) {
        imageView?.image = NSImage(systemSymbolName: "doc.text.image", accessibilityDescription: nil)?.scale(scale: .large)
        textField?.stringValue = item.name
        subtitleLabel.stringValue = item.url.path.replacingOccurrences(of: Defaults.projectURL!.path + "/" , with: "")
    }
    
}
