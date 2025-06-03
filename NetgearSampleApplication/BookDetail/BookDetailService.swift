//
//  BookDetailService.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 02/06/2025.
//

protocol BookDetailService {
    func getBookDetails(volumeId: String) async throws -> BookDetail
}

struct BookDetail {
    let id: String
    let title: String
    let description: String?
    let authors: [String]
    let publisher: String?
    let imageURL: String?
}

class NetworkBookDetailService: BookDetailService {
    let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func getBookDetails(volumeId: String) async throws -> BookDetail {
        return try await BookDetail(from: self.client.sendGetRequest(
            toPath: "volumes/\(volumeId)",
            responseType: BookDetailResponse.self
        ))
    }
}

extension NetworkBookDetailService {
    struct BookDetailResponse: Decodable {
        let id: String
        let volumeInfo: VolumeInfo
        
        struct VolumeInfo: Decodable {
            let title: String
            let description: String?
            let authors: [String]?
            let publisher: String?
            let imageLinks: ImageLinks?
            
            struct ImageLinks: Decodable {
                let thumbnail: String?
                let small: String?
            }
        }
    }
}

extension BookDetail {
    init(from book: NetworkBookDetailService.BookDetailResponse) {
        let imageLinks = book.volumeInfo.imageLinks
        self.init(
            id: book.id,
            title: book.volumeInfo.title,
            description: book.volumeInfo.description,
            authors: book.volumeInfo.authors ?? [],
            publisher: book.volumeInfo.publisher,
            imageURL: [imageLinks?.small, imageLinks?.thumbnail].compactMap { $0 }.first
        )
    }
}
