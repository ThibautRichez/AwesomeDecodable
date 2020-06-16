//
//  FileReader.swift
//  AwesomeDecodableTests
//
//  Created by RICHEZ Thibaut on 5/25/20.
//  Copyright © 2020 richez. All rights reserved.
//

import Foundation

enum FileReaderError: Error {
    case fileNotFound(named: String, ofType: String, bundleURL: URL)
    case read(filename: String, ofType: String, bundleURL: URL)
}

class FileReader {
    private let bundle = Bundle(for: FileReader.self)
    private let fileManager: FileManager = .default

    func get(filename: String,
             ofType type: String = "json") throws -> Data {
        guard let path = self.bundle.path(forResource: filename, ofType: type) else {
            throw FileReaderError.fileNotFound(
                named: filename,
                ofType: type,
                bundleURL: self.bundle.bundleURL
            )
        }

        guard let data = self.fileManager.contents(atPath: path) else {
            throw FileReaderError.read(
                filename: filename,
                ofType: type,
                bundleURL: self.bundle.bundleURL
            )
        }

        return data
    }
}

enum StringConversionError: Error {
    case invalidValue(_ value: String, encoding: String.Encoding)
}

extension String {
    func decode<T: Decodable>(using encoding: String.Encoding = .utf8,
                              decoder: JSONDecoder = .init()) throws -> T {
        guard let data = self.data(using: encoding) else {
            throw StringConversionError.invalidValue(self, encoding: encoding)
        }

        return try decoder.decode(T.self, from: data)
    }
}
