//
//  FontTests.swift
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

class FontTests: XCTestCase {

    func test_init() {
        let font = Font(family: "Arial", variant: ._700)

        XCTAssertEqual(font.family, "Arial")
        XCTAssertEqual(font.variant, ._700)
    }

    func test_name() {
        let font = Font(family: "Arial", variant: ._700)

        XCTAssertEqual(font.name, "Arial-700")
    }

    func test_filname() {
        let font = Font(family: "Arial", variant: ._700)

        XCTAssertEqual(font.filename, "Arial-700.ttf")
    }

    func test_variant() {
        var variant: Font.Variant = .regular
        XCTAssertEqual(variant.rawValue, "regular")

        variant = ._700
        XCTAssertEqual(variant.rawValue, "700")

        variant = .italic
        XCTAssertEqual(variant.rawValue, "italic")

        variant = ._700italic
        XCTAssertEqual(variant.rawValue, "700italic")
    }
}
