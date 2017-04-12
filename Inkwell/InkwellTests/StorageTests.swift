//
//  StorageTests.swift
// Copyright (c) 2017 Vinh Nguyen

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import XCTest
@testable import Inkwell

class StorageTests: XCTestCase {
    var storage: Storage!

    override func setUp() {
        super.setUp()

        storage = Storage()

        let font = Font(family: "Arial", variant: .regular)
        let fontURL = storage.URL(for: font)

        try? FileManager.default.createDirectory(at: storage.fontsURL, withIntermediateDirectories: true, attributes: nil)
        FileManager.default.createFile(atPath: fontURL.path, contents: nil, attributes: nil)
        FileManager.default.createFile(atPath: storage.metadataURL.path, contents: nil, attributes: nil)
    }

    override func tearDown() {
        let font = Font(family: "Arial", variant: .regular)
        let fontURL = storage.URL(for: font)

        try? FileManager.default.removeItem(atPath: fontURL.path)
        try? FileManager.default.removeItem(atPath: storage.metadataURL.path)
        try? FileManager.default.removeItem(atPath: storage.fontsURL.path)
        try? FileManager.default.removeItem(atPath: storage.domainURL.path)

        super.tearDown()
    }

    func test_metadataURL() {
        let url = storage.metadataURL

        XCTAssertTrue(url.absoluteString.hasSuffix("/me.vinhis.Inkwell/googleFonts.json"))
    }

    func test_fontsURL() {
        let url = storage.fontsURL

        XCTAssertTrue(url.absoluteString.hasSuffix("/me.vinhis.Inkwell/fonts/"))
    }

    func test_nameDictionaryURL() {
        let url = storage.nameDictionaryURL

        XCTAssertTrue(url.absoluteString.hasSuffix("/me.vinhis.Inkwell/nameDictionary.plist"))
    }

    func test_fileExists() {
        var font = Font(family: "Arial", variant: .regular)
        XCTAssertTrue(storage.fileExists(for: font))

        font = Font(family: "Arial", variant: ._700)
        XCTAssertFalse(storage.fileExists(for: font))
    }

    func test_googleFontsMetadataExists() {
        XCTAssertTrue(storage.googleFontsMetadataExists())

        try? FileManager.default.removeItem(atPath: storage.metadataURL.path)
        XCTAssertFalse(storage.googleFontsMetadataExists())
    }

    func test_URL() {
        let font = Font(family: "Arial", variant: .regular)
        let url = storage.URL(for: font)

        XCTAssertTrue(url.absoluteString.hasSuffix("/me.vinhis.Inkwell/fonts/Arial-regular.ttf"))
    }

    func test_removeGoogleFontsMetadata() {
        storage.removeGoogleFontsMetadata()
        XCTAssertFalse(storage.googleFontsMetadataExists())
    }
}
