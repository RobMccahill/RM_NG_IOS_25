//
//  BookCoverPlaceholderView.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 03/06/2025.
//
import SwiftUI

struct BookCoverPlaceholderView: View {
    var body: some View {
        ZStack {
            Color(.background)
            Image(systemName: "book.closed.fill")
                .foregroundStyle(.blue)
                .font(.system(size: 72))
        }.cornerRadius(10)
    }
}

#Preview {
    BookCoverPlaceholderView()
}
