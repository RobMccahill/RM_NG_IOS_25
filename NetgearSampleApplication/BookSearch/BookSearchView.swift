//
//  ContentView.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 01/06/2025.
//

import SwiftUI

struct BookSearchView: View {
    @State var viewModel: BookSearchViewModel
    @State var searchQuery: String = ""
    @State private var selection = 0
    
    init(model: BookSearchViewModel) {
        self.viewModel = model
    }
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .waitingForQuery(let message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
            case .loading(let loadingMessage):
                ProgressView(loadingMessage)
            case .noResultsFound(message: let message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
            case .success(let results):
                TabView(selection: $selection) {
                    ForEach(0..<results.count, id: \.self) { index in
                        BookSearchResultView(book: results[index]) { volumeId in
                            viewModel.onBookSelected(volumeId)
                        }
                        //TabView seems to have some visual issues (buggy animations) unless each view is tagged and a selection parameter is passed through the initialiser
                        .tag(index)
                    }
                }
                .frame(height: 400)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            case .error(let message):
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Title, author, publisher")
        .onChange(of: searchQuery) {
            Task {
                //Checks if the search query is cleared to reset the state of the view
                if searchQuery.isEmpty {
                    await viewModel.searchBooks(query: searchQuery)
                }
            }
            
        }
        .onSubmit(of: .search) {
            Task {
                //Search is only executed when the submit button is tapped for performance reasons - it could be possible to search based on character, but that would require more in-depth work in terms of checking query length, limiting calls based on input, etc.
                await viewModel.searchBooks(query: searchQuery)
            }
        }
    }
}

struct BookSearchResultView: View {
    let book: BookSearchResultModel
    let onBookSelected: (String) -> Void
    
    var body: some View {
        VStack {
            AsyncImage(url: book.imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(10)
                } else if phase.error != nil || book.imageURL == nil {
                    BookCoverPlaceholderView()
                        .frame(width: 200, height: 150)
                } else {
                    ZStack {
                        Color.clear.frame(width: 200, height: 150)
                        ProgressView()
                    }
                }
            }
            .padding(.top, 48)
            .padding(.bottom, 32)
            .onTapGesture {
                self.onBookSelected(book.id)
            }
            Text(book.name)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            Spacer()
        }.padding()
    }
}



fileprivate class PreviewSearchService: BookSearchService {
    let books: [Book]
    let throwError: Bool
    let delay: ContinuousClock.Instant.Duration?
    
    init(books: [Book] = [], throwError: Bool = false, delay: ContinuousClock.Instant.Duration? = nil) {
        self.books = books
        self.throwError = throwError
        self.delay = delay
    }
    
    init(sampleResponse: String, throwError: Bool = false, delay: ContinuousClock.Instant.Duration? = nil) {
        self.books = loadResponseFromFile(filename: sampleResponse, type: NetworkBookSearchService.Response.self)!.items.map(Book.init)
        self.throwError = throwError
        self.delay = delay
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        if let delay = delay {
            try? await Task.sleep(for: delay)
        }
        
        guard !throwError else {
            throw NSError()
        }
        
        return books
    }
}

#Preview {
    NavigationStack {
        let viewModel = BookSearchViewModel(service: PreviewSearchService(
            sampleResponse: "Dorian-Gray-Search"
        ))
        
        return BookSearchView(model: viewModel)
            .onAppear {
                Task {
                    await viewModel.searchBooks(query: "Dorian")
                }
            }
    }
}
