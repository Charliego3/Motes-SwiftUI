//
//  SidebarViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa
import SwiftUI

struct SidebarContentViewController: NSViewControllerRepresentable {
    
    let tabsViewController = SidebarContentViewControllerRepresentable()
    
    func makeNSViewController(context: Context) -> some NSViewController {
        return tabsViewController
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {}
    
    func toggleView(at index: Int) {
        self.tabsViewController.tabViewController.selectedTabViewItemIndex = index
    }
}

class SidebarContentViewControllerRepresentable: NSViewController {
    lazy var tabViewController = NSTabViewController()
    lazy var notesViewController = NotesViewController()
    lazy var tagsViewController = TagsViewController()
    lazy var allNoteViewController = AllNotesViewController()
    lazy var favoriteViewController = FavoriteViewController()
    lazy var recentsViewController = RecentsViewController()
    lazy var trashViewController = TrashViewContrller()
    
    override func loadView() {
        self.view = tabViewController.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: notesViewController))
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: tagsViewController))
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: allNoteViewController))
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: favoriteViewController))
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: recentsViewController))
        self.tabViewController.addTabViewItem(NSTabViewItem(viewController: trashViewController))
        self.tabViewController.tabStyle = .unspecified
        self.tabViewController.view.autoresizesSubviews = true
        self.tabViewController.selectedTabViewItemIndex = 0
    }
}

struct SidebarViewController: View {
    
    let contentViewController = SidebarContentViewController()
    var window = NSScreen.main?.visibleFrame
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                contentViewController
                    .padding(.bottom, 28)
            }
            .frame(height: proxy.size.height)
            .safeAreaInset(edge: .top) {
                SidebarToolbar() { index in
                    contentViewController.toggleView(at: index)
                    
                    guard let toolbar = MainWindowController.toolbar else { return }
                    let hasExpanded = toolbar.items.contains(where: { $0.itemIdentifier == .expandedIdentifier })
                    if index > 0 {
                        if hasExpanded {
                            toolbar.removeItem(at: 2)
                        }
                    } else {
                        toolbar.insertItem(withItemIdentifier: .expandedIdentifier, at: 2)
                        toolbar.toggleExpanded(FileItemModel.fileHasExpanded(contentViewController.tabsViewController.notesViewController.outlineView))
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 200, maxWidth: window!.height / 2)
    }
}

struct SidebarToolbar: View {
    private var icons: [SidebarToolbarIcon] = [
        SidebarToolbarIcon(image: "folder", title: "Notes", id: 0),
        SidebarToolbarIcon(image: "tag", title: "Tags", id: 1),
        SidebarToolbarIcon(image: "shippingbox", title: "All Notes", id: 2),
        SidebarToolbarIcon(image: "star", title: "Favitors", id: 3),
        SidebarToolbarIcon(image: "clock", title: "Recents", id: 4),
        SidebarToolbarIcon(image: "trash", title: "Trash", id: 5),
    ]
    
    @State private var selectionId: Int = 0
    @Environment(\.controlActiveState) private var activeState
    private var action: (_ at: Int) -> Void
    
    init(action: @escaping(_ at: Int) -> Void) {
        self.action = action
    }
    
    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(icons, id: \.image) { icon in
                    Button {
                        self.selectionId = icon.id
                        self.action(self.selectionId)
                    } label: {
                        Image(systemName: icon.image)
                            .help(icon.title)
                    }
                    .padding(.vertical, 2)
                    .padding(.horizontal, proxy.size.width > 300 ? 10 : 3)
                    .buttonStyle(ToolbarButtonStyle(id: icon.id, selection: selectionId, activeState: activeState))
                }
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) { Divider() }
            .overlay(alignment: .bottom) { Divider() }
            .animation(.default, value: icons)
        }
    }
}

struct SidebarToolbarIcon: Identifiable, Equatable {
    let image: String
    let title: String
    var id: Int
}

struct ToolbarButtonStyle: ButtonStyle {
    var id: Int
    var selection: Int
    var activeState: ControlActiveState
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: id == selection ? .semibold : .regular))
            .symbolVariant(id == selection ? .fill : .none)
            .foregroundColor(id == selection ? .accentColor : configuration.isPressed ? .primary : .secondary)
            .frame(width: 25, height: 25, alignment: .center)
            .contentShape(Rectangle())
            .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
