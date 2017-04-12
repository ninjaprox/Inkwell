//
//  FontRegisterTests.swift
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

class FontRegisterTests: XCTestCase {
    var storage = MockStorage()
    var nameDictionary: NameDictionaryProtocol!
    var fontRegister: FontRegister!
    var fontURL: URL!
    var nameDictionaryURL: URL!

    override func setUp() {
        super.setUp()

        fontURL = Bundle(for: FontRegisterTests.self).url(forResource: "ABeeZee-regular", withExtension: "ttf")
        nameDictionaryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("nameDictionary.plist")
        storage._nameDictionaryURL = nameDictionaryURL
        storage.fontURL = fontURL!
        nameDictionary = NameDictionary(storage: storage)
        fontRegister = FontRegister(storage: storage, nameDictionary: nameDictionary)
    }

    override func tearDown() {
        nameDictionary = nil
        fontRegister = nil

        // Unregister font.
        let data = try! Data(contentsOf: fontURL)
        let provider = CGDataProvider(data: data as CFData)
        let cgfont = CGFont(provider!)

        CTFontManagerUnregisterGraphicsFont(cgfont, nil)
        try? FileManager.default.removeItem(atPath: nameDictionaryURL.path)

        fontURL = nil
        nameDictionaryURL = nil

        super.tearDown()
    }

    func test_register() {
        let font = Font(family: "ABeeZee", variant: .regular)
        let result = fontRegister.register(font)
        let postScriptName = nameDictionary.postscriptName(for: font)
        let uifont = UIFont(name: "ABeeZee-regular", size: 10)

        XCTAssertTrue(result)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual("ABeeZee-Regular", postScriptName!)
        XCTAssertNotNil(uifont)
    }

    func test_register_fail_duplicate() {
        let font = Font(family: "ABeeZee", variant: .regular)
        fontRegister.register(font)
        let result = fontRegister.register(font)
        let postScriptName = nameDictionary.postscriptName(for: font)
        let uifont = UIFont(name: "ABeeZee-regular", size: 10)

        XCTAssertFalse(result)
        XCTAssertNotNil(postScriptName)
        XCTAssertEqual("ABeeZee-Regular", postScriptName!)
        XCTAssertNotNil(uifont)
    }

    func test_register_fail_postScriptName() {
        let mockNameDictionary = MockNameDictionary()
        fontRegister = FontRegister(storage: storage, nameDictionary: mockNameDictionary)
        let font = Font(family: "ABeeZee", variant: .regular)
        let result = fontRegister.register(font)
        let postScriptName = nameDictionary.postscriptName(for: font)

        XCTAssertFalse(result)
        XCTAssertNil(postScriptName)
    }

    func test_register_fileNotFound() {
        storage.fontURL = URL(string: "fileNotFound")!
        let font = Font(family: "ABeeZee", variant: ._700)
        let result = fontRegister.register(font)
        let postScriptName = nameDictionary.postscriptName(for: font)
        let uifont = UIFont(name: "ABeeZee-Bold", size: 10)

        XCTAssertFalse(result)
        XCTAssertNil(postScriptName)
        XCTAssertNil(uifont)
    }
}
