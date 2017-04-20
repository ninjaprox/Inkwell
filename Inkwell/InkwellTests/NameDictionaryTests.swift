//
//  NameDictionary.swift
//  Inkwell
//
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

class NameDictionaryTests: XCTestCase {
    let storage = Storage()
    var nameDictionary: NameDictionary!

    override func setUp() {
        super.setUp()

        nameDictionary = NameDictionary(storage: storage)

        try? FileManager.default.createDirectory(at: storage.domainURL, withIntermediateDirectories: true, attributes: nil)

        let nameDictionaryContent = NSDictionary(dictionary: ["Roboto-regular": "Roboto-regular"])
        nameDictionaryContent.write(to: storage.nameDictionaryURL, atomically: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(atPath: storage.nameDictionaryURL.path)
        try? FileManager.default.removeItem(atPath: storage.domainURL.path)

        super.tearDown()
    }

    func test_postscriptName() {
        var font = Font(family: "Roboto", variant: .regular)
        var postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Roboto-regular")

        font = Font(family: "Roboto", variant: ._700)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNil(postScriptName)
    }

    func test_postscriptName_fileNotFound() {
        try? FileManager.default.removeItem(atPath: storage.nameDictionaryURL.path)

        let font = Font(family: "Roboto", variant: .regular)
        let postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNil(postScriptName)
    }

    func test_postscriptName_lookUpFromRegisteredFonts() {
        // Futura family
        var font = Font(family: "Futura", variant: .regular)
        var postScriptName = nameDictionary.postscriptName(for: font)

        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Futura-Medium")

        font = Font(family: "Futura", variant: ._700)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Futura-Bold")

        font = Font(family: "Futura", variant: .italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Futura-MediumItalic")

        font = Font(family: "Futura", variant: ._700italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNil(postScriptName)

        // Arial family

        font = Font(family: "Arial", variant: .regular)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "ArialMT")

        font = Font(family: "Arial", variant: ._700)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Arial-BoldMT")

        font = Font(family: "Arial", variant: .italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Arial-ItalicMT")

        font = Font(family: "Arial", variant: ._700italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Arial-BoldItalicMT")

        // Helvetica family

        font = Font(family: "Helvetica", variant: .regular)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Helvetica")

        font = Font(family: "Helvetica", variant: ._700)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Helvetica-Bold")

        font = Font(family: "Helvetica", variant: .italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Helvetica-Oblique")

        font = Font(family: "Helvetica", variant: ._700italic)
        postScriptName = nameDictionary.postscriptName(for: font)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Helvetica-BoldOblique")

    }

    func test_setPostscriptName() {
        let font = Font(family: "Roboto", variant: ._700)
        let result = nameDictionary.setPostscriptName("Roboto-bold", for: font)
        let postScriptName = nameDictionary.postscriptName(for: font)

        XCTAssertTrue(result)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Roboto-bold")
    }

    func test_setPostscriptName_fileNotFound() {
        try? FileManager.default.removeItem(atPath: storage.nameDictionaryURL.path)

        let font = Font(family: "Roboto", variant: ._700)
        let result = nameDictionary.setPostscriptName("Roboto-bold", for: font)
        let postScriptName = nameDictionary.postscriptName(for: font)

        XCTAssertTrue(result)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual(postScriptName, "Roboto-bold")
    }
}
