//
//  FontOperation.swift
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

final class FontOperation: Operation {
    typealias Completion = (UIFont) -> Void

    private var uifont: UIFont
    private let storage: Storage
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata
    private let font: Font
    private let size: CGFloat
    private let completion: Completion

    // MARK: - Init

    init(storage: Storage,
         nameDictionary: NameDictionary,
         fontRegister: FontRegister,
         fontDownloader: FontDownloader,
         googleFontsMetadata: GoogleFontsMetadata,
         font: Font,
         size: CGFloat,
         completion: @escaping Completion) {
        uifont = UIFont.systemFont(ofSize: size)
        self.storage = storage
        self.nameDictionary = nameDictionary
        self.fontRegister = fontRegister
        self.fontDownloader = fontDownloader
        self.googleFontsMetadata = googleFontsMetadata
        self.font = font
        self.size = size
        self.completion = completion
    }

    // MARK: - Override

    override var isAsynchronous: Bool { return true }

    private var _executing : Bool = false
    override var isExecuting : Bool {
        get { return _executing }
        set {
            guard _executing != newValue else { return }
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished : Bool = false
    override var isFinished : Bool {
        get { return _finished }
        set {
            guard _finished != newValue else { return }
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        isExecuting = true
        isFinished = false

        if let postscriptName = nameDictionary.postscriptName(for: font),
            let _ = UIFont(name: postscriptName, size: size) {
            finish()
        }

        if storage.fileExists(for: font) {
            register(font)
            finish()
        } else if self.googleFontsMetadata.exist() {
            download(font) { _ in
                self.register(self.font)
                self.finish()
            }
        } else {
            fetchGoogleFontsMetadata { _ in
                self.download(self.font) { _ in
                    self.register(self.font)
                    self.finish()
                }
            }
        }
    }

    // MARK: - Helpers

    private func fetchGoogleFontsMetadata(completion: @escaping (Result<GoogleFontsMetadata.FamilyDictionary>) -> Void) {
        _ = googleFontsMetadata.fetch(completion: completion)
    }

    private func download(_ font: Font, completion: @escaping (Result<URL>) -> Void) {
        guard let file = googleFontsMetadata.file(of: font),
            let URL = URL(string: file) else {
                completion(.failure(nil))

                return
        }

        _ = fontDownloader.download(font, at: URL, completion: completion)
    }

    private func register(_ font: Font) {
        fontRegister.register(font)
    }

    private func finish(isCancelled: Bool = false) {
        isExecuting = false
        isFinished = true
        if let postscriptName = nameDictionary.postscriptName(for: font),
            let _uifont = UIFont(name: postscriptName, size: size) {
            uifont = _uifont
        }
        if !isCancelled {
            completion(uifont)
        }
    }
}
