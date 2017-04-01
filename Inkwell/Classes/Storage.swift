//
//  Storage.swift
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

final class Storage {
    private let domain = "me.vinhis.Inkwell"
    private let metadataFile = "googleFonts.json"
    private let fontsFolder = "fonts"
    private let nameDictionaryFile = "nameDictionary.plist"

    /// The URL to Google Fonts metadata file.
    var metadataURL: URL {
        get {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            return documentURL
                .appendingPathComponent(domain, isDirectory: true)
                .appendingPathComponent(metadataFile)
        }
    }

    /// The URL to fonts folder.
    var fontsURL: URL {
        get {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            return documentURL
                .appendingPathComponent(domain, isDirectory: true)
                .appendingPathComponent(fontsFolder, isDirectory: true)
        }
    }

    /// The URL to name dictionary file.
    var nameDictionaryURL: URL {
        get {
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

            return documentURL
                .appendingPathComponent(domain, isDirectory: true)
                .appendingPathComponent(nameDictionaryFile)
        }
    }

    /// Check if the file of specified font exists.
    ///
    /// - Parameter font: The font needed to check its file.
    /// - Returns: `true` if the file exists, otherwise `false`.
    func fileExists(for font: Font) -> Bool {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fontURL = documentURL
            .appendingPathComponent(domain, isDirectory: true)
            .appendingPathComponent(fontsFolder, isDirectory: true)
            .appendingPathComponent("\(font.filename)")

        return FileManager.default.fileExists(atPath: fontURL.path)
    }

    /// Check if the Google Fonts metadata file exists.
    ///
    /// - Returns: `true` if the file exists, otherwised `false`.
    func googleFontsMetadataExists() -> Bool {
        return FileManager.default.fileExists(atPath: metadataURL.path)
    }

    func URL(for font: Font) -> URL {
        return fontsURL.appendingPathComponent("\(font.filename)")
    }
}
