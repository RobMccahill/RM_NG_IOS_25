//
//  AppSession.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 01/06/2025.
//

import Foundation

class AppSession {
    let client: NetworkClient
    let bookSearchService: BookSearchService
    let bookDetailService: BookDetailService
    
    init(client: NetworkClient = NetworkClient(baseURL: Constants.BASE_URL, apiKey: Constants.API_KEY)) {
        self.client = client
        self.bookSearchService = NetworkBookSearchService(client: client)
        self.bookDetailService = NetworkBookDetailService(client: client)
    }
}
