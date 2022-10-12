//
//  AllNotesViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/20.
//

import Cocoa

class AllNotesViewController: NSViewController {

    var notes: [FileItem] = [
        FileItemModel.shared.files[0],
        FileItemModel.shared.files[1],
        FileItemModel.shared.files[2],
        FileItemModel.shared.files[3],
        FileItemModel.shared.files[4],
        FileItemModel.shared.files[5],
        FileItemModel.shared.files[6],
    ]
    @IBOutlet weak var tableView: NSTableView!
    private static let mainSection = "MainSection"
    private lazy var dataSource = createDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        notes.append(contentsOf: FileItemModel.shared.files[0].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[1].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[2].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[3].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[4].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[5].children ?? [])
        notes.append(contentsOf: FileItemModel.shared.files[6].children ?? [])
        
        tableView.dataSource = dataSource
                
        var snapshot = NSDiffableDataSourceSnapshot<String, FileItem>()
        snapshot.appendSections([Self.mainSection])
        snapshot.appendItems(notes, toSection: Self.mainSection)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createDataSource() -> NSTableViewDiffableDataSource<String, FileItem> {
        let dataSource = NSTableViewDiffableDataSource<String, FileItem>(tableView: tableView) { (tableView, column, row, item) -> NSView in
            guard let cell = tableView.makeView(withIdentifier: .allNotesDataCell, owner: self) as? NSTableCellView else { return NSView() }
            cell.textField?.stringValue = item.name
            cell.imageView?.image = .docText
            cell.textField?.toolTip = item.tooltip()
            return cell
        }
        return dataSource
    }
    
}

//extension AllNotesViewController: NSTableViewDataSource {
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return notes.count
//    }
//
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        guard let cell = tableView.makeView(withIdentifier: .allNotesDataCell, owner: self) as? NSTableCellView else { return nil }
//        let note = self.notes[row]
//        cell.textField?.stringValue = note.name
//        return cell
//    }
//}
