//
//  Extensions.swift
//  NetgearSampleApplication
//
//  Created by Robert Mccahill on 02/06/2025.
//

import Foundation

///convenience function for loading a decodable type from a json file
func loadResponseFromFile<Response: Decodable>(filename: String, type: Response.Type) -> Response? {
    do {
        let url = Bundle.main.url(forResource: filename, withExtension: "json")!
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    } catch {
        assertionFailure("Failed to load / decode json from file: \(error)")
        return nil
    }
}
