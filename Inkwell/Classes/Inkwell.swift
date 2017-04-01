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
    public var APIKey: String = "" {
        didSet {
            googleFontsMetadata.APIKey = APIKey
        }
    }

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

    public func font(for font: Font, size: CGFloat, completion: @escaping (UIFont) -> Void) {
        if case let (uifont, false) = createFont(for: font, size: size) {
            completion(uifont)
        }

        if storage.fileExists(for: font) {
            register(font)
            completion(createFont(for: font, size: size).font)
        } else if googleFontsMetadata.exist() {
            download(font) { _ in
                self.register(font)
                completion(self.createFont(for: font, size: size).font)
            }
        } else {
            fetchGoogleFontsMetadata { _ in
                self.download(font) { _ in
                    self.register(font)
                    completion(self.createFont(for: font, size: size).font)
                }
            }
        }
    }

    // MARK: Helpers

    func fetchGoogleFontsMetadata(completion: @escaping (Result<GoogleFontsMetadata.FamilyDictionary>) -> Void) {
        _ = googleFontsMetadata.fetch(completion: completion)
    }

    func download(_ font: Font, completion: @escaping (Result<URL>) -> Void) {
        guard let file = googleFontsMetadata.file(of: font),
            let URL = URL(string: file) else {
                completion(.failure(nil))

                return
        }

        _ = fontDownloader.download(font, at: URL, completion: completion)
    }

    func register(_ font: Font) {
        fontRegister.register(font)
    }

    func createFont(for font: Font, size: CGFloat) -> (font: UIFont, fallback: Bool) {
        guard let postscriptName = nameDictionary.postscriptName(for: font),
            let uifont = UIFont(name: postscriptName, size: size) else {
                return (UIFont.systemFont(ofSize: size), true)
        }
        
        return (uifont, false)
    }
}
