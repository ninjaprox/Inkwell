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
    private let operationQueue = OperationQueue()

    // MARK: - Init

    private init() {
        operationQueue.name = "me.vinhis.Inkwell"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility

        nameDictionary = NameDictionary(storage: storage)
        fontRegister = FontRegister(storage: storage)
        fontDownloader = FontDownloader(storage: storage, queue: operationQueue.underlyingQueue)
        googleFontsMetadata = GoogleFontsMetadata(APIKey: APIKey, storage: storage, queue: operationQueue.underlyingQueue)
    }

    // MARK: - Public interface

    public func font(for font: Font, size: CGFloat, completion: @escaping (UIFont?) -> Void) {
        let operation = FontOperation(storage: storage,
                                      nameDictionary: nameDictionary,
                                      fontRegister: fontRegister,
                                      fontDownloader: fontDownloader,
                                      googleFontsMetadata: googleFontsMetadata,
                                      font: font,
                                      size: size) { uifont in
                                        DispatchQueue.main.async {
                                            completion(uifont)
                                        }
        }

        operationQueue.addOperation(operation)
    }
}
