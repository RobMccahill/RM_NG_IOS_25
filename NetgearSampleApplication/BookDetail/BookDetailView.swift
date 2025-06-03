//
//  BookDetailView.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 02/06/2025.
//

import SwiftUI

struct BookDetailView: View {
    @State var viewModel: BookDetailViewModel
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading(let message):
                ProgressView(message)
            case .success(let book):
                BookContentsView(book: book)
            case .error(let message):
                Text(message)
            }
        }
        
        .animation(.smooth, value: viewModel.state)
        .onAppear {
            Task {
                await viewModel.loadBookDetails()
            }
        }
    }
}

struct BookContentsView: View {
    let book: BookDetailModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    AsyncImage(url: book.imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .clipped()
                        } else if phase.error != nil || book.imageURL == nil {
                            BookCoverPlaceholderView()
                                .frame(height: 300)
                        } else {
                            ZStack {
                                Color.clear.frame(height: 300)
                                ProgressView()
                            }
                        }
                    }
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 5, x: 0, y: 0)
                    Spacer()
                }.padding(.top, 16)
                Text(book.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                if let authorDescription = book.authorDescription {
                    Text(authorDescription)
                        .font(.title2)
                }
                
                if let publisher = book.publisher {
                    Text("Publisher: \(publisher)")
                        .font(.subheadline.italic())
                        .padding(.bottom, 8)
                }
                Text("Description:")
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(book.description)
            }.padding()
        }
    }
}

fileprivate class PreviewBookDetailService: BookDetailService {
    let book: BookDetail
    let throwError: Bool
    let delay: ContinuousClock.Instant.Duration?
    
    private static let sampleBook = BookDetail(id: "1", title: "Title", description: "Description", authors: ["Author"], publisher: "Publisher", imageURL: nil)
    
    init(book: BookDetail = PreviewBookDetailService.sampleBook, throwError: Bool = false, delay: ContinuousClock.Instant.Duration? = nil) {
        self.book = book
        self.throwError = throwError
        self.delay = delay
    }
    
    init(sampleResponse: String, throwError: Bool = false, delay: ContinuousClock.Instant.Duration? = nil) {
        self.book = BookDetail(from: loadResponseFromFile(filename: sampleResponse, type: NetworkBookDetailService.BookDetailResponse.self)!)
        self.throwError = throwError
        self.delay = delay
    }
    
    func getBookDetails(volumeId: String) async throws -> BookDetail {
        if let delay = delay {
            try? await Task.sleep(for: delay)
        }
        
        guard !throwError else {
            throw NSError()
        }
        
        return book
    }
}

#Preview {
    NavigationStack {
        let viewModel = BookDetailViewModel(
            volumeId: "1",
            service: PreviewBookDetailService(
            sampleResponse: "Dorian-Gray-Detail",
            throwError: false
        ))
        
        BookDetailView(viewModel: viewModel)
    }
}
