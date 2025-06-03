//
//  BookSearchService.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 01/06/2025.
//

import Foundation

protocol BookSearchService {
    func searchBooks(query: String) async throws -> [Book]
}

struct Book {
    let id: String
    let title: String
    let imageURL: String?
}


class NetworkBookSearchService: BookSearchService {
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        let response = try await self.client.sendGetRequest(
            toPath: "volumes",
            queryItems: [URLQueryItem(name: "q", value: query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))],
            responseType: Response.self
        )
        
        return response.items.map(Book.init)
    }
}

extension NetworkBookSearchService {
    struct Response: Decodable {
        let items: [BookResponse]
        
        struct BookResponse: Decodable {
            let id: String
            let volumeInfo: VolumeInfo
            
            struct VolumeInfo: Decodable {
                let title: String
                let imageLinks: ImageLinks?
                
                struct ImageLinks: Decodable {
                    let thumbnail: String?
                }
            }
        }
    }
}

extension Book {
    init(from bookResponse: NetworkBookSearchService.Response.BookResponse) {
        self.id = bookResponse.id
        self.title = bookResponse.volumeInfo.title
        self.imageURL = bookResponse.volumeInfo.imageLinks?.thumbnail
    }
}
