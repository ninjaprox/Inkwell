//
//  Inkwell.swift
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

/// The Inkwell itself.
public final class Inkwell {
    /// The shared instance.
    public static let shared = Inkwell()

    /// The Google API key used for Google Fonts.
    public var APIKey: String = ""

    private let storage = Storage()
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata

    // MARK: - Init

    private init() {
        nameDictionary = NameDictionary(storage: storage)
        fontRegister = FontRegister(storage: storage)
        fontDownloader = FontDownloader(storage: storage)
        googleFontsMetadata = GoogleFontsMetadata(APIKey: APIKey, storage: storage)
    }

    // MARK: - Public interface

    public func font(for _font: Font, size: CGFloat) -> UIFont {
        var postscriptName = nameDictionary.postscriptName(for: _font) ?? ""
        let font = UIFont(name: postscriptName, size: size)

        guard font == nil else {
            return font!
        }

        if storage.fileExists(for: _font) {
            fontRegister.register(_font)

            postscriptName = nameDictionary.postscriptName(for: _font) ?? ""

            return UIFont(name: postscriptName, size: size) ?? UIFont.systemFont(ofSize: size)
        } else if storage.googleFontsMetadataExists() {
            let files = googleFontsMetadata.files(of: _font)

            for file in files {
                fontDownloader.download(_font, at: URL(string: file)!)
            }
            fontRegister.register(_font)
            postscriptName = nameDictionary.postscriptName(for: _font) ?? ""

            return UIFont(name: postscriptName, size: size) ?? UIFont.systemFont(ofSize: size)
        } else {
            fetchGoogleFontsMetadata { _ in }
            let files = googleFontsMetadata.files(of: _font)

            for file in files {
                fontDownloader.download(_font, at: URL(string: file)!)
            }
            fontRegister.register(_font)
            postscriptName = nameDictionary.postscriptName(for: _font) ?? ""

            return UIFont(name: postscriptName, size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }

    // MARK: Helpers

    func fetchGoogleFontsMetadata(completion: @escaping (Result<GoogleFontsMetadata.FamilyDictionary>) -> Void) {
        _ = googleFontsMetadata.fetch(completion: completion)
    }

    func downloadFontFiles(_ files: String) {
        
    }
    
    func registerFont(_ font: Font) {
        
    }
    
    func setPostScriptName(for font: Font) {
        
    }
}
