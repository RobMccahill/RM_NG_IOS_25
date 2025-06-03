//
//  BookDetailViewModel.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 02/06/2025.
//

import Foundation

@Observable
@MainActor
class BookDetailViewModel {
    private let volumeId: String
    private let service: BookDetailService
    private(set) var state: State = .loading(message: "Loading...")
    
    init(volumeId: String, service: BookDetailService) {
        self.volumeId = volumeId
        self.service = service
    }
    
    func loadBookDetails() async {
        state = .loading(message: "Loading...")
        
        do {
            let book = try await service.getBookDetails(volumeId: volumeId)
            state = .success(result: BookDetailModel(book: book))
        } catch {
            state = .error(message: "Something went wrong. Please try again.")
        }
    }
    
    enum State: Equatable {
        case loading(message: String)
        case success(result: BookDetailModel)
        case error(message: String)
    }
}

fileprivate extension BookDetailModel {
    init(book: BookDetail) {
        let url = URL(string: book.imageURL ?? "")
        self.init(
            id: book.id,
            name: book.title,
            description: (book.description ?? "No description available").removingHTMLTags(),
            authorDescription: book.authors.isEmpty ? "No authors available" : book.authors.joined(separator: ", "),
            publisher: book.publisher ?? "No publisher available",
            imageURL: url
        )
    }
}

fileprivate extension String {
    //this is a very bare-bones approach to remove html tags from the description for appearance purposes
    //the syntax is essentially:
    // - '<\\?' checks for an open bracket with or without a /
    // - '[a-zA-Z0-9]+' checks for one or more alphanumeric characters, eg: p, h1, br, etc.
    // - '>\\s' checks for the closing bracket, plus any trailing whitespace
    func removingHTMLTags() -> String {
        let regex = "<\\/?[a-zA-Z0-9]+>\\s?"
        return self.replacingOccurrences(of: regex, with: "", options: .regularExpression)
    }
}

struct BookDetailModel: Equatable {
    let id: String
    let name: String
    let description: String
    let authorDescription: String?
    let publisher: String?
    let imageURL: URL?
}
