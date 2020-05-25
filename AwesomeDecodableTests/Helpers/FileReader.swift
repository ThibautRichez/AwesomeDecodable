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
    private static let bundle = Bundle(for: FileReader.self)
    private static let fileManager: FileManager = .default

    static func get(filename: String,
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
