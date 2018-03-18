//
//  FontRegister.swift
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

import Foundation
import CoreText

/// The class to register font.
final class FontRegister {
    private let storage: Storable
    private let nameDictionary: NameDictionaryProtocol

    init(storage: Storable, nameDictionary: NameDictionaryProtocol) {
        self.storage = storage
        self.nameDictionary = nameDictionary
    }

    /// Register the font.
    ///
    /// - Parameter font: The font.
    /// - Returns: `true` if successful, otherwise `false.
    @discardableResult func register(_ font: Font) -> Bool {
        guard let data = try? Data(contentsOf: storage.URL(for: font)),
            let provider = CGDataProvider(data: data as CFData) else {
                return false
        }

        let cgfont = CGFont(provider)

        guard CTFontManagerRegisterGraphicsFont(cgfont!, nil) else { return false }
        guard let postscriptName = cgfont?.postScriptName as String?,
            nameDictionary.setPostscriptName(postscriptName, for: font) else {
                CTFontManagerUnregisterGraphicsFont(cgfont!, nil)

                return false
        }
        
        return true
    }
}
