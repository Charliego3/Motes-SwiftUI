//
//  DetailViewController.swift
//  MarkdownNotes
//
//  Created by Charlie on 2022/5/19.
//

import Cocoa
import SwiftUI
import Markdown

struct DetailView: View {
    
    @Binding var source: String
    
    var body: some View {
        VStack(spacing: 0) {
            Markdown(content: $source)
                .padding(.top, -8)
        }
        .safeAreaInset(edge: .top) { Divider() }
    }
}

class DetailViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
