//
//  GoogleFontsDownloader.swift
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

import Alamofire

/// The class to download font.
final class FontDownloader {
    private let storage: Storage
    private let queue: DispatchQueue?

    init(storage: Storage, queue: DispatchQueue?) {
        self.storage = storage
        self.queue = queue
    }

    /// Download the font at specified URL.
    ///
    /// - Parameters:
    ///   - font: The font.
    ///   - URL: The URL
    ///   - completion: The completion handler.
    /// - Returns: The download request.
    func download(_ font: Font, at URL: URL, completion: @escaping (Result<URL>) -> Void) -> DownloadRequest {
        let storageURL = storage.URL(for: font)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (storageURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return Alamofire.download(URL, to: destination)
            .response(queue: queue) { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(storageURL))
                }
        }
    }
}
