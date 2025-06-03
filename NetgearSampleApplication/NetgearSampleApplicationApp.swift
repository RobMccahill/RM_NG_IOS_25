//
//  NetgearSampleApplicationApp.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 01/06/2025.
//

import SwiftUI

@main
struct NetgearSampleApplicationApp: App {
    let session = AppSession()
    @State var selectedBookId: [String] = []
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $selectedBookId) {
                BookSearchView(model: BookSearchViewModel(service: session.bookSearchService, onBookSelected: { volumeId in
                    self.selectedBookId = [volumeId]
                }))
                .navigationDestination(for: String.self) { volumeId in
                    BookDetailView(viewModel: BookDetailViewModel(volumeId: volumeId, service: session.bookDetailService))
                }
            }
        }
    }
}
