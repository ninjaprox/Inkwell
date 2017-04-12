//
//  Font.swift
//  InkwellExample
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

/// The struct encapsulating font information.
public struct Font {

    /// The font variant.
    ///
    /// - regular: Regular.
    /// - _700: Bold.
    /// - italic: Italic.
    /// - _700italic: BoldItalic.
    public enum Variant: String {
        /// Regular.
        case regular

        /// Bold.
        case _700 = "700"

        /// Italic.
        case italic

        /// BoldItalic
        case _700italic = "700italic"
    }

    /// The font family.
    public let family: String

    /// The font variant.
    public let variant: Variant

    var name: String {
        return "\(family)-\(variant.rawValue)"
    }

    var filename: String {
        return "\(name).ttf"
    }

    /// Create a new font struct.
    ///
    /// - Parameters:
    ///   - family: The font family.
    ///   - variant: The font variant.
    public init(family: String, variant: Variant) {
        self.family = family
        self.variant = variant
    }
}
