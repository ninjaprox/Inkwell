//
//  InkwellExample.swift
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

    private static let domain = "me.vinhis.Inkwell"
    private let queue: DispatchQueue
    private let storage: Storage
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata
    private let operationQueue: OperationQueue

    // MARK: - Init

    private init() {
        queue = DispatchQueue(label: Inkwell.domain)
        storage = Storage()
        nameDictionary = NameDictionary(storage: storage)
        fontRegister = FontRegister(storage: storage, nameDictionary: nameDictionary)
        fontDownloader = FontDownloader(storage: storage, queue: queue)
        googleFontsMetadata = GoogleFontsMetadata(APIKey: APIKey, storage: storage, queue: queue)
        operationQueue = OperationQueue()
        operationQueue.name = Inkwell.domain
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        operationQueue.underlyingQueue = queue
    }

    // MARK: - Public interface

    /// Create the `UIFont` with specified font information.
    ///
    /// - Note: Google Fonts has higher priority
    ///         that means the `at` param is only used unless the given font
    ///         information is found on Google Fonts, otherwise the `at` param
    ///         is ignored.
    ///
    /// - Parameters:
    ///   - font: The font information.
    ///   - size: The font size.
    ///   - at: The URL used to download the font file. Default is `nil`.
    ///   - completion: The completion handler.
    /// - Returns: The font operation.
    @discardableResult
    public func font(for font: Font,
                     size: CGFloat,
                     at url: URL? = nil,
                     completion: @escaping (UIFont?) -> Void) -> FontOperation {
        let operation = InternalFontOperation(storage: storage,
                                              nameDictionary: nameDictionary,
                                              fontRegister: fontRegister,
                                              fontDownloader: fontDownloader,
                                              googleFontsMetadata: googleFontsMetadata,
                                              font: font,
                                              size: size,
                                              url: url) { uifont in
                                                DispatchQueue.main.async {
                                                    completion(uifont)
                                                }
        }

        operationQueue.addOperation(operation)

        return FontOperation(operation: operation)
    }
}
