//
//  BookSearchViewModelTests.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 03/06/2025.
//

import Foundation
import Combine
import Testing
@testable import NetgearSampleApplication

@Suite
struct BookSearchViewModelTests {

    @Test("Check empty query does not initiate search")
    func testEmptyQueryDoesNotInitiateSearch() async throws {
        let spy = SpyBookSearchService()
        let sut = await BookSearchViewModel(service: spy)
        
        //check initial state before calling searchBooks
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
        
        await sut.searchBooks(query: "")
        
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
    }
    
    @Test("Check empty list of books returns empty state")
    func testEmptyResponseReturnsEmptyState() async throws {
        let spy = SpyBookSearchService(response: [])
        let sut = await BookSearchViewModel(service: spy)
        
        //check initial state before calling searchBooks
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
        
        await sut.searchBooks(query: "Query")
        
        #expect(spy.searchBooksCallCount == 1)
        await #expect(sut.state.isEmptyResponse)
    }
    
    @Test("Check list of books returns success state")
    func testListOfBooksReturnsSuccessState() async throws {
        let spy = SpyBookSearchService(response: [
            NetgearSampleApplication.Book(id: "1", title: "Title", imageURL: nil),
            NetgearSampleApplication.Book(id: "1", title: "Title", imageURL: nil),
            NetgearSampleApplication.Book(id: "1", title: "Title", imageURL: nil)
        ])
        
        let sut = await BookSearchViewModel(service: spy)
        
        //check initial state before calling searchBooks
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
        
        await sut.searchBooks(query: "Query")
        
        #expect(spy.searchBooksCallCount == 1)
        
        guard case .success(let results) = await sut.state else {
            Issue.record("Success state was not returned from view model, actual result: \(await sut.state)")
            return
        }
        
        #expect(results.count == 3)
    }
    
    @Test("Check service throwing error returns error state")
    func testServiceThrowingErrorReturnsErrorState() async throws {
        let spy = SpyBookSearchService(throwError: true)
        
        let sut = await BookSearchViewModel(service: spy)
        
        //check initial state before calling searchBooks
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
        
        await sut.searchBooks(query: "Query")
        
        #expect(spy.searchBooksCallCount == 1)
        #expect(await sut.state.isError)
    }
    
    @Test("Check sending an empty query after a successful response resets the view model state")
    func testEmptyQueryResetsState() async throws {
        let spy = SpyBookSearchService(response: [
            NetgearSampleApplication.Book(id: "1", title: "Title", imageURL: nil)
        ])
        
        let sut = await BookSearchViewModel(service: spy)
        
        //check initial state before calling searchBooks
        await #expect(sut.state.isWaitingForQuery)
        #expect(spy.searchBooksCallCount == 0)
        
        await sut.searchBooks(query: "Query")
        
        #expect(spy.searchBooksCallCount == 1)
        #expect(await sut.state.isSuccess)
        
        await sut.searchBooks(query: "")
        #expect(spy.searchBooksCallCount == 1)
        #expect(await sut.state.isWaitingForQuery)
    }
}

fileprivate extension BookSearchViewModel.State {
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
    
    var isWaitingForQuery: Bool {
        switch self {
        case .waitingForQuery(_):
            return true
        default:
            return false
        }
    }
    
    var isEmptyResponse: Bool {
        switch self {
        case .noResultsFound(_):
            return true
        default:
            return false
        }
    }
}


fileprivate class SpyBookSearchService: BookSearchService {
    let response: [Book]
    let throwError: Bool
    
    var searchBooksCallCount = 0
    
    init(
        response: [Book] = [],
        throwError: Bool = false
    ) {
        self.response = response
        self.throwError = throwError
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        searchBooksCallCount += 1
        
        guard !throwError else {
            throw NSError()
        }
        
        return response
    }
}
