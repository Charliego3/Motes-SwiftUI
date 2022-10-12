//
//  Extensions.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa

extension NSImage {
    func image(withTintColor tintColor: NSColor?) -> NSImage {
        guard let tintColor = tintColor else { return self }
        guard isTemplate else { return self }
        guard let copiedImage = self.copy() as? NSImage else { return self }
        copiedImage.lockFocus()
        tintColor.set()
        let imageBounds = NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height)
        imageBounds.fill(using: .sourceAtop)
        copiedImage.unlockFocus()
        copiedImage.isTemplate = false
        return copiedImage
    }
    
    func weight(weight: NSFont.Weight) -> NSImage? {
        withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 0, weight: weight))
    }
    
    func scale(scale: SymbolScale) -> NSImage? {
        withSymbolConfiguration(NSImage.SymbolConfiguration(scale: scale))
    }
    
    static let docText = NSImage(systemSymbolName: "doc.text.image", accessibilityDescription: nil)
}
