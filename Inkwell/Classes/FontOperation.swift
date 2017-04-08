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

import Alamofire

public final class FontOperation: Operation {
    typealias Completion = (UIFont?) -> Void

    private let storage: Storage
    private let nameDictionary: NameDictionary
    private let fontRegister: FontRegister
    private let fontDownloader: FontDownloader
    private let googleFontsMetadata: GoogleFontsMetadata
    private let font: Font
    private let size: CGFloat
    private let completion: Completion
    private var metadataRequest: DownloadRequest?
    private var downloadRequest: DownloadRequest?

    // MARK: - Init

    init(storage: Storage,
         nameDictionary: NameDictionary,
         fontRegister: FontRegister,
         fontDownloader: FontDownloader,
         googleFontsMetadata: GoogleFontsMetadata,
         font: Font,
         size: CGFloat,
         completion: @escaping Completion) {
        self.storage = storage
        self.nameDictionary = nameDictionary
        self.fontRegister = fontRegister
        self.fontDownloader = fontDownloader
        self.googleFontsMetadata = googleFontsMetadata
        self.font = font
        self.size = size
        self.completion = completion

        super.init()

        addObserver(self, forKeyPath: #keyPath(isCancelled), options: .new, context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: #keyPath(isCancelled))
    }

    // MARK: - KVO

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case .some(#keyPath(isCancelled)):
            guard isCancelled else { break }

            metadataRequest?.cancel()
            downloadRequest?.cancel()
        default: break
        }
    }

    // MARK: - Override

    override public var isAsynchronous: Bool { return true }

    private var _executing : Bool = false
    override public var isExecuting : Bool {
        get { return _executing }
        set {
            guard _executing != newValue else { return }
            willChangeValue(forKey: #keyPath(isExecuting))
            _executing = newValue
            didChangeValue(forKey: #keyPath(isExecuting))
        }
    }

    private var _finished : Bool = false
    override public var isFinished : Bool {
        get { return _finished }
        set {
            guard _finished != newValue else { return }
            willChangeValue(forKey: #keyPath(isFinished))
            _finished = newValue
            didChangeValue(forKey: #keyPath(isFinished))
        }
    }

    override public func start() {
        guard !isCancelled else { return }

        isExecuting = true
        isFinished = false

        if let postscriptName = nameDictionary.postscriptName(for: font),
            let _ = UIFont(name: postscriptName, size: size) {
            finish()

            return
        }

        if storage.fileExists(for: font) {
            register(font)
            finish()
        } else if self.googleFontsMetadata.exist() {
            download(font, familyDictionary: nil) { result in
                switch result {
                case .success:
                    self.register(self.font)
                    self.finish()
                case .failure:
                    self.fail()
                }
            }
        } else {
            fetchGoogleFontsMetadata { fetchResult in
                switch fetchResult {
                case .success(let familyDictionary):
                    guard !self.isCancelled else { return }

                    self.download(self.font, familyDictionary: familyDictionary) { downloadResult in
                        switch downloadResult {
                        case .success:
                            self.register(self.font)
                            self.finish()
                        case .failure:
                            self.fail()
                        }
                    }
                case .failure: self.fail()
                }
            }
        }
    }

    // MARK: - Helpers

    private func fetchGoogleFontsMetadata(completion: @escaping (Result<GoogleFontsMetadata.FamilyDictionary>) -> Void) {
        metadataRequest = googleFontsMetadata.fetch(completion: completion)
    }

    private func download(_ font: Font,
                          familyDictionary: GoogleFontsMetadata.FamilyDictionary?,
                          completion: @escaping (Result<URL>) -> Void) {
        guard let file = googleFontsMetadata.file(of: font, familyDictionary: familyDictionary),
            let URL = URL(string: file) else {
                completion(.failure(nil))

                return
        }

        downloadRequest = fontDownloader.download(font, at: URL, completion: completion)
    }

    private func register(_ font: Font) {
        fontRegister.register(font)
    }

    private func finish(isCancelled: Bool = false) {
        isExecuting = false
        isFinished = true
        guard let postscriptName = nameDictionary.postscriptName(for: font),
            let uifont = UIFont(name: postscriptName, size: size),
            !isCancelled else {
                return
        }

        completion(uifont)
    }
    
    private func fail() {
        isExecuting = false
        isFinished = true
        guard !isCancelled else { return }
        
        completion(nil)
    }
}
