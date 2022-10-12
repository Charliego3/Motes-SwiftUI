//
//  EditableOutlineView.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/20.
//

import SwiftUI

class EditableOutlineView: NSOutlineView {
    var prevSelectedCell: NSTableCellView? = nil
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if event.clickCount > 1 {
            return
        }
        
        let localPoint = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: localPoint)
        if row < 0 {
            return
        }
        
        guard let cell = self.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView else { return }
        cell.textField?.isEditable = true
        if prevSelectedCell == cell {
            return
        }
        
        prevSelectedCell?.textField?.isEditable = false
        prevSelectedCell = cell
    }
}
