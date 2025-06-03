//
//  BookDetailViewModelTests.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 03/06/2025.
//

import Foundation
import Combine
import Testing
@testable import NetgearSampleApplication

@Suite
struct BookDetailViewModelTests {
    
    @Test("Check book service throwing error returns error state")
    func testServiceThrowingErrorReturnsErrorState() async throws {
        let spy = SpyBookDetailService(throwError: true)
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        
        #expect(await sut.state.isLoading)
        #expect(spy.bookDetailCallCount == 0)
        
        await sut.loadBookDetails()
        
        #expect(await sut.state.isError)
        #expect(spy.bookDetailCallCount == 1)
    }
    
    @Test("Check book service returning valid book details returns success state")
    func testServiceReturningValidBookReturnsSuccessState() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook()
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        
        #expect(await sut.state.isLoading)
        #expect(spy.bookDetailCallCount == 0)
        
        await sut.loadBookDetails()
        
        #expect(await sut.state.isSuccess)
        #expect(spy.bookDetailCallCount == 1)
    }
    
    //MARK: - Detail mapping tests
    
    @Test("Check book with empty description returns a default message")
    func testEmptyDescriptionReturnsDefaultMessage() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                description: nil
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.description == "No description available")
    }
    
    @Test("Check book with no authors returns a default message")
    func testNoEmptyAuthorsReturnsDefaultMessage() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                authors: []
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.authorDescription == "No authors available")
    }
    
    @Test("Check one author available returns name")
    func testOneAuthorReturnsAuthorName() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                authors: ["Jonathan Swift"]
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.authorDescription == "Jonathan Swift")
    }
    
    @Test("Check multiple authors returns joined list")
    func testMultipleAuthorsReturnsJoinedList() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                authors: [
                    "Jonathan Swift",
                    "James Joyce",
                    "Oscar Wilde"
                ]
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.authorDescription == "Jonathan Swift, James Joyce, Oscar Wilde")
    }
    
    @Test("Check empty publisher returns default message")
    func testEmptyPublisherReturnsDefaultMessage() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                publisher: nil
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.publisher == "No publisher available")
    }
    
    @Test("Check present details are mapped to model")
    func testDetailsAreMappedToModel() async throws {
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                id: "1",
                title: "Title",
                description: "Description",
                publisher: "Publisher",
                imageURL: "https://www.googleapis.com"
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.id == "1")
        #expect(book.name == "Title")
        #expect(book.description == "Description")
        #expect(book.publisher == "Publisher")
        #expect(book.imageURL == URL(string: "https://www.googleapis.com"))
    }
    
    @Test("Check HTML tags are stripped from book description")
    func testDescriptionDoesNotHaveHTMLTags() async throws {
        //as stated in the implementation, this is a very basic approach, so the test is just a simple case to catch common tags
        let spy = SpyBookDetailService(
            response: Self.makeBook(
                description: "<h1><h2><p><br>Description</br></p></h2></h1>"
            )
        )
        
        let sut = await BookDetailViewModel(volumeId: "1", service: spy)
        await sut.loadBookDetails()
        
        guard case .success(let book) = await sut.state else {
            Issue.record("Expected successful response from service, received: \(await sut.state)")
            return
        }
        
        #expect(book.description == "Description")
    }
    
}

fileprivate extension BookDetailViewModelTests {
    static func makeBook(
        id: String = "1",
        title: String = "Title",
        description: String? = nil,
        authors: [String] = [],
        publisher: String? = nil,
        imageURL: String? = nil
    ) -> BookDetail {
        BookDetail(
            id: id,
            title: title,
            description: description,
            authors: authors,
            publisher: publisher,
            imageURL: imageURL
        )
    }
}

fileprivate extension BookDetailViewModel.State {
    var isLoading: Bool {
        switch self {
        case .loading(_):
            return true
        default:
            return false
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        default:
            return false
        }
    }
    
    var isError: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
}

fileprivate class SpyBookDetailService: BookDetailService {
    let response: BookDetail
    let throwError: Bool
    
    var bookDetailCallCount = 0
    
    init(
        response: BookDetail = BookDetailViewModelTests.makeBook(),
        throwError: Bool = false
    ) {
        self.response = response
        self.throwError = throwError
    }
    
    func getBookDetails(volumeId: String) async throws -> BookDetail {
        bookDetailCallCount += 1
        
        guard !throwError else {
            throw NSError()
        }
        
        return response
    }
}
