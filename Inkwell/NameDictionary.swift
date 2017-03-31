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

import Foundation

final class NameDictionary {
    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    /// Get the postscript name of specified font.
    ///
    /// - Parameter font: The font needed to get the postscript name.
    /// - Returns: The postscript name.
    func postscriptName(for font: Font) -> String? {
        guard let nameDictionary = NSDictionary(contentsOf: storage.nameDictionaryURL) else {
            return nil
        }

        return nameDictionary.value(forKey: font.name) as? String
    }

    /// Set the postscript name of specified font.
    ///
    /// - Parameters:
    ///   - name: The postscript name.
    ///   - font: The font needed to get the postscript name.
    /// - Returns: `true` if set successfully, otherwise `false`.
    func setPostscriptName(_ name: String, for font: Font) -> Bool {
        let URL = storage.nameDictionaryURL

        guard let nameDictionary = NSMutableDictionary(contentsOf: URL) else {
            return false
        }

        nameDictionary.setValue(name, forKey: font.name)

        return nameDictionary.write(to: URL, atomically: true)
    }
}
