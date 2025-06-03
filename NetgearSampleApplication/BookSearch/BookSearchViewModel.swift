//
//  BookSearchViewModel.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 01/06/2025.
//

import Foundation

@Observable
@MainActor
class BookSearchViewModel {
    private let service: BookSearchService
    let onBookSelected: (String) -> Void
    
    private(set) var state: State = .waitingForQuery(message: "Please enter a query into the search bar above to receive book results.")
    
    init(service: BookSearchService, onBookSelected: @escaping (String) -> Void = { _ in }) {
        self.service = service
        self.onBookSelected = onBookSelected
    }
    
    func searchBooks(query: String) async {
        guard !query.isEmpty else {
            state = .waitingForQuery(message: "Please enter a query into the search bar above to receive book results.")
            return
        }
        
        state = .loading(message: "Loading...")
        
        do {
            let results = try await service.searchBooks(query: query)
            
            if !results.isEmpty {
                state = .success(results: results.map(BookSearchResultModel.init))
            } else {
                state = .noResultsFound(message: "No results were found for your query - please try again.")
            }
            
        } catch {
            state = .error(message: "Something went wrong. Please try again.")
        }
    }
    
    enum State: Equatable {
        case waitingForQuery(message: String)
        case loading(message: String)
        case noResultsFound(message: String)
        case success(results: [BookSearchResultModel])
        case error(message: String)
    }
}

fileprivate extension BookSearchResultModel {
    init(book: Book) {
        let url = URL(string: book.imageURL ?? "")
        self.init(id: book.id, name: book.title, imageURL: url)
    }
}

struct BookSearchResultModel: Identifiable, Equatable {
    let id: String
    let name: String
    let imageURL: URL?
}
