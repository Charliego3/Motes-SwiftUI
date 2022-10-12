//
//  MainWindowController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import SwiftUI

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    static var shared: MainWindowController?
    
    convenience init() {
        Defaults.registerDefaults()
        
        self.init(windowNibName: NSNib.Name(String(describing: Self.self)))
        MainWindowController.shared = self
    }
    
    @State var source: String = ""
    
    lazy var splitviewController = NSSplitViewController()
    lazy var sidebarViewController = NSHostingController(rootView: SidebarViewController())
//    lazy var editorViewController = EditorViewController()
//    lazy var detailViewController = DetailViewController()
    lazy var editorViewController = NSHostingController(rootView: EditorView(source: $source))
//    lazy var editorViewController = EditorViewController()
    lazy var detailViewController = NSHostingController(rootView: DetailView(source: $source))
    
    static var toolbar: Toolbar?
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.splitviewController.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebarViewController))
        self.splitviewController.addSplitViewItem(NSSplitViewItem(viewController: editorViewController))
        self.splitviewController.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: detailViewController))
        self.splitviewController.splitViewItems.last?.isCollapsed = true
        self.contentViewController = self.splitviewController
        
        self.window?.delegate = self
        MainWindowController.toolbar = Toolbar(identifier: .init("toolbar"), splitViewController: splitviewController)
        self.window?.toolbar = MainWindowController.toolbar
    }
    
    public func showWindow(force: Bool = false) {
        if force || Defaults.showOnLaunch {
            super.showWindow(nil)
        }
    }
    
    @available(*, unavailable)
    override func showWindow(_ sender: Any?) {}
}

extension NSToolbarItem.Identifier {
    static let leftSidebarIdentifier = NSToolbarItem.Identifier.init("sidebar.left")
    static let expandedIdentifier = NSToolbarItem.Identifier.init("rectangle.expand.vertical")
    static let rightSidebarIdentifier = NSToolbarItem.Identifier.init("sidebar.right")
    static let trackingSeparator = NSToolbarItem.Identifier.init("trackingSeparator")
    static let titleBar = NSToolbarItem.Identifier.init("titleBar")
}

class Toolbar: NSToolbar {
    var splitViewController: NSSplitViewController!
    
    let itemsIdentifieies: [NSToolbarItem.Identifier] = [
        .leftSidebarIdentifier,
        .flexibleSpace,
        .expandedIdentifier,
        .sidebarTrackingSeparator,
        .showFonts,
        .showColors,
        .flexibleSpace,
        .rightSidebarIdentifier
    ]

    public init(identifier: NSToolbar.Identifier, splitViewController: NSSplitViewController) {
        super.init(identifier: identifier)
        self.allowsUserCustomization = false
        self.autosavesConfiguration = true
        self.showsBaselineSeparator = false
        self.delegate = self
        self.displayMode = .iconOnly
        self.splitViewController = splitViewController
    }
    
    func customToolbarItem(identifier: NSToolbarItem.Identifier, label: String, toolTip: String, image: NSImage? = nil, view: NSView? = nil, action: Selector, bordered: Bool = true) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: identifier)
        item.label = label
        item.paletteLabel = label
        item.toolTip = toolTip
        item.autovalidates = true
        item.isBordered = bordered
        item.target = self
        
        if image != nil {
            item.image = image
        } else if view != nil {
            item.view = view
        } else {
            assertionFailure("Invalid item content: object")
        }
            
        item.action = action
        
        let menuItem = NSMenuItem()
        menuItem.submenu = nil
        menuItem.title = label
        item.menuFormRepresentation = menuItem
        return item
    }
    
    func itemImage(_ itemIdentifier: NSToolbarItem.Identifier) -> NSImage? {
        return NSImage(systemSymbolName: itemIdentifier.rawValue, accessibilityDescription: itemIdentifier.rawValue)?
            .scale(scale: itemIdentifier == .expandedIdentifier ? .medium : .large)
    }
    
    func toggleExpanded(_ expanded: Bool, item sender: NSToolbarItem? = nil) {
        var item: NSToolbarItem? = sender
        if sender == nil {
            item = items.first(where: { $0.itemIdentifier == .expandedIdentifier })
        }
        
        var symobl = "rectangle.expand.vertical"
        if expanded {
            symobl = "rectangle.compress.vertical"
        }
        
        if item?.image?.accessibilityDescription == symobl {
            return
        }
        item?.image = NSImage(systemSymbolName: symobl, accessibilityDescription: symobl)
    }
    
    @objc func expanded(_ sender: NSToolbarItem) {
        guard let hosting = splitViewController.splitViewItems.first?.viewController as? NSHostingController<SidebarViewController> else { return }
        guard let outlineView = hosting.rootView.contentViewController.tabsViewController.notesViewController.outlineView else { return }
        let expaned = sender.image?.accessibilityDescription == "rectangle.compress.vertical"
        if expaned {
            outlineView.animator().collapseItem(nil, collapseChildren: true)
        } else {
            outlineView.animator().expandItem(nil, expandChildren: true)
        }
        sender.toolTip = NSLocalizedString(!expaned ? "Expand files" : "Collapse files", comment: "")
        toggleExpanded(!expaned, item: sender)
    }
    
    @objc func toggleDetail(_ sender: NSToolbarItem) {
        guard let view = splitViewController.splitViewItems.last else { return }
        resizeDetail(collapsed: view.isCollapsed)
        
        view.animator().isCollapsed.toggle()
        sender.toolTip = NSLocalizedString(view.isCollapsed ? "Show preview" : "Hidden preview", comment: "")
    }
    
    func resizeDetail(collapsed: Bool) {
        guard let sidebarFrame = MainWindowController.shared?.splitviewController.splitViewItems.first?.viewController.view.frame,
            let contentWidth = MainWindowController.shared?.window?.frame.width,
            let detailWidth = MainWindowController.shared?.splitviewController.splitViewItems.last?.viewController.view.frame.width else { return }
        
        let sidebarWidth = sidebarFrame.width
        let newSize = NSSize(width: (contentWidth - sidebarWidth) / 2, height: sidebarFrame.height)
        if detailWidth == newSize.width || !collapsed {
            return
        }
        
        MainWindowController.shared?.splitviewController.splitViewItems.last?.viewController.view.setFrameSize(newSize)
    }
    
    @objc func toggleSidebar(_ sender: NSToolbarItem) {
        splitViewController.toggleSidebar(sender)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let collapsed = self.splitViewController.splitViewItems.first?.isCollapsed else { return }
            if collapsed {
                self.removeItem(at: 2)
            } else {
                self.insertItem(withItemIdentifier: .expandedIdentifier, at: 2)
                guard let hostingController = self.splitViewController.splitViewItems.first?.viewController as? NSHostingController<SidebarViewController> else { return }
                let contentViewController = hostingController.rootView.contentViewController
                self.toggleExpanded(FileItemModel.fileHasExpanded(contentViewController.tabsViewController.notesViewController.outlineView))
            }
        }
    }
}

extension Toolbar: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var item: NSToolbarItem?
        if itemIdentifier == .leftSidebarIdentifier {
            item = customToolbarItem(identifier: itemIdentifier, label: "Sidebar", toolTip: "Toggle Sidebar", image: itemImage(itemIdentifier), action: #selector(toggleSidebar(_:)))
        } else if itemIdentifier == .rightSidebarIdentifier {
            item = customToolbarItem(identifier: itemIdentifier, label: "Preview", toolTip: "Hidden preview", image: itemImage(itemIdentifier), action: #selector(toggleDetail(_:)))
        } else if itemIdentifier == .expandedIdentifier {
            item = customToolbarItem(identifier: itemIdentifier, label: "Expand", toolTip: "Expand files", image: itemImage(itemIdentifier), action: #selector(expanded(_:)))
        } else if itemIdentifier == .trackingSeparator {
            item = NSTrackingSeparatorToolbarItem(identifier: itemIdentifier, splitView: splitViewController.splitView, dividerIndex: 1)
            item?.isBordered = false
        } else if itemIdentifier == .titleBar {
            
        }
        return item
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        itemsIdentifieies
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        itemsIdentifieies
    }
}

