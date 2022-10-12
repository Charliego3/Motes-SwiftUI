//
//  EditorViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa
import SwiftUI
import STTextView

struct EditorView: View {
    
    @Binding var source: String
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    @State var text = ""
    @State var font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    @State var tabWidth = 4
    @State var lineHeight = 1.2
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding(.top, -8)
        }
        .safeAreaInset(edge: .top) { Divider() }
        .frame(minWidth: 100, minHeight: 400)
    }
    
}

//struct EditorViewControllerRepresentable: NSViewControllerRepresentable {
    
//    let editorViewController = EditorViewController()
    
//    func makeNSViewController(context: Context) -> some NSViewController {
//        return editorViewController
//    }
    
//    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {}
//}

//var source: String = ""

//class EditorViewController: NSViewController {
//
////    private var highlighter: Highlighter!
//
//    @IBOutlet var textView: EditorTextView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        textView.delegate = self
//        textView.drawsBackground = false
//        textView.backgroundColor = .clear
//        textView.isAutomaticTextCompletionEnabled = true
//        textView.usesFindPanel = true
//        textView.font = NSFont.systemFont(ofSize: 16)
////        textView.lnv_setUpLineNumberView()
//
////        let language = Language(language: tree_sitter_markdown())
//
//        guard let textContainer = textView.textContainer, let textStorage = textView.textStorage else { return }
//        print("textContainer: \(textContainer) -- textStorage: \(textStorage)")
//        let textInterface = TextContainerSystemInterface(textContainer: textContainer, attributeProvider: self.attributeProvider)
////        self.highlighter = Highlighter(textInterface: textInterface, tokenProvider: self.tokenProvider)
//        textStorage.delegate = self
////        self.highlighter.invalidate()
//
//        textView.string = source
//    }
//
//    let paintItBlackTokenName = "paintItBlack"
//
//    func tokenProvider(_ range: NSRange, completionHandler: @escaping (Result<TokenApplication, Error>) -> Void) {
//       var tokens: [Token] = []
//       guard let searchString = self.textView.textStorage?.string else {
//          // Could also complete with .failure(...) here
//          completionHandler(.success(TokenApplication(tokens: tokens, action: .replace)))
//          return
//       }
//
//       if let regex = try? NSRegularExpression(pattern: "[^\\s]+\\s{0,1}") {
//          regex.enumerateMatches(in: searchString, range: range) { regexResult, _, _ in
//             guard let result = regexResult else { return }
//             for rangeIndex in 0..<result.numberOfRanges {
//                let tokenRange = result.range(at: rangeIndex)
//                tokens.append(Token(name: paintItBlackTokenName, range: tokenRange))
//             }
//          }
//       }
//
//       completionHandler(.success(TokenApplication(tokens: tokens, action: .replace)))
//    }
//
//    func attributeProvider(_ token: Token) -> [NSAttributedString.Key: Any]? {
//       if token.name == paintItBlackTokenName {
//          return [.foregroundColor: NSColor.red]
//       }
//       return nil
//    }
//
//}
//
//extension EditorViewController: NSTextStorageDelegate {
//    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        let adjustedRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
//        self.highlighter.didChangeContent(in: adjustedRange, delta: delta)
//
//        DispatchQueue.main.async {
//            self.highlighter.invalidate()
//        }
//    }
//}
//
//class EditorTextView: NSTextView {
//    override func insertText(_ string: Any, replacementRange: NSRange) {
//        print("insert text: \(string) -- \(replacementRange)")
//        super.insertText(string, replacementRange: replacementRange)
//    }
//
//    override func insertNewline(_ sender: Any?) {
//        super.insertText("\n", replacementRange: selectedRange())
//    }
//
//    override func performFindPanelAction(_ sender: Any?) {
//        print("find action triggered: \(String(describing: sender))")
//    }
//}
//
//class LineNumberRulerView: NSRulerView {
//
//    var font: NSFont! {
//        didSet {
//            self.needsDisplay = true
//        }
//    }
//
//    init(textView: NSTextView) {
//        super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerView.Orientation.verticalRuler)
//        self.font = textView.font ?? NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
//        self.clientView = textView
//
//        self.ruleThickness = 40
//    }
//
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    override func drawHashMarksAndLabels(in rect: NSRect) {
//
//        if let textView = self.clientView as? NSTextView {
//            if let layoutManager = textView.layoutManager {
//
//                let relativePoint = self.convert(NSZeroPoint, from: textView)
//                let lineNumberAttributes = [.font: textView.font!, .foregroundColor: NSColor.gray] as [NSAttributedString.Key: Any]
//
//                let drawLineNumber = { (lineNumberString:String, y:CGFloat) -> Void in
//                    let attString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
//                    let x = 35 - attString.size().width
//                    attString.draw(at: NSPoint(x: x, y: relativePoint.y + y))
//                }
//
//                let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
//                let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
//
//                let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
//                // The line number for the first visible line
//                var lineNumber = newLineRegex.numberOfMatches(in: textView.string, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1
//
//                var glyphIndexForStringLine = visibleGlyphRange.location
//
//                // Go through each line in the string.
//                while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {
//
//                    // Range of current line in the string.
//                    let characterRangeForStringLine = (textView.string as NSString).lineRange(
//                        for: NSMakeRange( layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), 0 )
//                    )
//                    let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)
//
//                    var glyphIndexForGlyphLine = glyphIndexForStringLine
//                    var glyphLineCount = 0
//
//                    while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {
//
//                        // See if the current line in the string spread across
//                        // several lines of glyphs
//                        var effectiveRange = NSMakeRange(0, 0)
//
//                        // Range of current "line of glyphs". If a line is wrapped,
//                        // then it will have more than one "line of glyphs"
//                        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
//
//                        if glyphLineCount > 0 {
////                            drawLineNumber("", lineRect.minY)
//                        } else {
//                            drawLineNumber("\(lineNumber)", lineRect.minY)
//                        }
//
//                        // Move to next glyph line
//                        glyphLineCount += 1
//                        glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
//                    }
//
//                    glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
//                    lineNumber += 1
//                }
//
//                // Draw line number for the extra line at the end of the text
//                if layoutManager.extraLineFragmentTextContainer != nil {
//                    drawLineNumber("\(lineNumber)", layoutManager.extraLineFragmentRect.minY)
//                }
//            }
//        }
//    }
//}
//
//var LineNumberViewAssocObjKey: UInt8 = 0
//
//extension NSTextView {
//    var lineNumberView: LineNumberRulerView {
//        get {
//            return objc_getAssociatedObject(self, &LineNumberViewAssocObjKey) as! LineNumberRulerView
//        }
//        set {
//            objc_setAssociatedObject(self, &LineNumberViewAssocObjKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//    func lnv_setUpLineNumberView() {
//            if font == nil {
//                font = NSFont.systemFont(ofSize: 20)
//            }
//
//            if let scrollView = enclosingScrollView {
//                lineNumberView = LineNumberRulerView(textView: self)
//
//                scrollView.verticalRulerView = lineNumberView
//                scrollView.hasVerticalRuler = true
//                scrollView.rulersVisible = true
//            }
//
//            postsFrameChangedNotifications = true
//            NotificationCenter.default.addObserver(self, selector: #selector(lnv_framDidChange), name: NSView.frameDidChangeNotification, object: self)
//
//            NotificationCenter.default.addObserver(self, selector: #selector(lnv_textDidChange), name: NSText.didChangeNotification, object: self)
//        }
//
//        @objc func lnv_framDidChange(notification: NSNotification) {
//
//            lineNumberView.needsDisplay = true
//        }
//
//        @objc func lnv_textDidChange(notification: NSNotification) {
//
//            lineNumberView.needsDisplay = true
//        }
//}
//
//extension EditorViewController: NSTextViewDelegate {
//    // MARK: Comoletion
//    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
//        return ["first", "second"]
//    }
//}
