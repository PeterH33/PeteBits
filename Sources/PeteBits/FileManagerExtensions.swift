//
//  FileManagerDecode.swift
//
//  Created by Peter Hartnett on 4/16/22.
//

import Foundation
import SwiftUI

extension FileManager {
    
    public func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    public static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    ///Used to decode data from a given file.
    ///
    /// example call
    ///
    /// if let yourVar: yourType = FileManager.default.decode("yourFile")
    public func decode<T: Codable>(_ fromFile: String) -> T? {
        let url = getDocumentsDirectory().appendingPathComponent(fromFile)
        let decoder = JSONDecoder()
        
        do {
            let savedData = try Data(contentsOf: url)
            do {
                let decodedData = try decoder.decode(T.self, from: savedData)
                return decodedData
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    ///Used to encode data in a JSON file at the named filename
    ///
    /// example call `FileManager.default.encode(yourData, tofile: "yourFileName")'`
    public func encode<T: Codable>(_ data: T, toFile fileName: String) {
        let encoder = JSONEncoder()
        
        do {
            let encoded = try encoder.encode(data)
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try encoded.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
