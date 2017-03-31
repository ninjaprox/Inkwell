//
//  GoogleFontsMetadata.swift
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

final class GoogleFontsMetadata {
    private let APIEndpoint = "https://www.googleapis.com/webfonts/v1/webfonts"
    private let APIKey: String
    private let storage: Storage

    init(APIKey: String, storage: Storage) {
        self.APIKey = APIKey
        self.storage = storage
    }

    /// Fetch the Google Fonts metadata.
    func fetch() {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.storage.metadataURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let _ = Alamofire.download(APIEndpoint,
                                   method: .get,
                                   parameters: ["key": APIKey],
                                   encoding: URLEncoding.queryString,
                                   headers: nil,
                                   to: destination)
    }

    /// Get font families from persisted Google Fonts metadata files.
    ///
    /// - Returns: The list of font families.
    func families() -> [Family] {
        guard let data = try? Data(contentsOf: storage.metadataURL),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let itemsJson = json?["items"] as? [[String: Any]] else {
                return []
        }

        return itemsJson.flatMap {
            return Family(json: $0, variants: [.regular, ._700, .italic, ._700italic])
        }
    }

    /// Get files in the family of specified font.
    ///
    /// - Parameter font: The font.
    /// - Returns: The list of files.
    func files(of font: Font) -> [String] {
        guard let family = families().first(where: { $0.name == font.family }) else {
            return []
        }

        return family.files
    }
}

extension GoogleFontsMetadata {
    struct Family {
        let name: String
        let files: [String]

        init?(json: [String: Any], variants: [Font.Variant]?) {
            guard let files = json["files"] as? [String: String] else { return nil }
            guard let name = json["family"] as? String else { return nil }

            self.name = name
            self.files = files.flatMap { (key, value) in
                if let variants = variants?.map({ $0.rawValue }) {
                    return variants.contains(key) ? value : nil
                } else {
                    return value
                }
            }
        }
    }
}
