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

/// The class to work Google Fonts API.
/// This class is used to fetch Google Fonts metadata, i.e. list of fonts supported by Google Fonts.
/// The metadata can be downloaded if no persisted file found or load locally.
final class GoogleFontsMetadata {
    typealias JSON = [String: Any]
    typealias ItemsJSON = [ItemJSON]
    typealias ItemJSON = [String: Any]
    typealias FilesJSON = [String: String]
    typealias FamilyDictionary = [String: [String]]

    var APIKey: String
    private let APIEndpoint = "https://www.googleapis.com/webfonts/v1/webfonts"
    private let storage: Storage
    private let queue: DispatchQueue?

    init(APIKey: String, storage: Storage, queue: DispatchQueue?) {
        self.APIKey = APIKey
        self.storage = storage
        self.queue = queue
    }

    // MARK: - Interface

    /// Fetch the Google Fonts metadata.
    ///
    /// - Parameter completion: The completion handler.
    /// - Returns: The download request.
    func fetch(completion: @escaping (Result<FamilyDictionary>) -> Void) -> DownloadRequest {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (self.storage.metadataURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        return Alamofire.download(APIEndpoint,
                                  method: .get,
                                  parameters: ["key": APIKey],
                                  encoding: URLEncoding.queryString,
                                  headers: nil,
                                  to: destination)
            .responseJSON(queue: queue, options: .allowFragments) { response in
                debugPrint("fetched Google Fonts metadata")

                let familyResponse = response.flatMap { json -> FamilyDictionary in
                    guard let json = json as? JSON else { return [:] }

                    return self.parse(json: json)
                }

                switch familyResponse.result {
                case .success(let value): completion(.success(value))
                case .failure(let error): completion(.failure(error))
                }
        }
    }

    /// Get the family dictionary from persisted Google Fonts metadata files.
    ///
    /// - Returns: The family dictionary.
    func familyDictionary() -> FamilyDictionary {
        guard let data = try? Data(contentsOf: storage.metadataURL),
            let optionalJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = optionalJson as? JSON else {
                return [:]
        }

        return parse(json: json)
    }

    /// Get the file of specified font.
    ///
    /// - Parameter font: The font needed to get the file.
    /// - Returns: The file.
    func file(of font: Font) -> String? {
        debugPrint("file(of:)")

        guard let files = familyDictionary()[font.family] else {
            return nil
        }
        guard let index = files.index(where: { $0.hasSuffix(font.variant.rawValue) }) else {
            return nil
        }

        return files[index]
    }

    func exist() -> Bool {
        debugPrint("exist()")

        return storage.googleFontsMetadataExists()
    }

    // MARK: - Helpers

    /// Parse the JSON to the family dictionary.
    ///
    /// - Note: Only concerned variants are taken.
    ///
    /// - Parameters:
    ///   - json: The JSON.
    ///   - variants: Concerned variants.
    /// - Returns: The family dictionary.
    private func parse(json: JSON,
                       variants: [Font.Variant]? = [.regular, ._700, .italic, ._700italic]) -> FamilyDictionary {
        guard let items = json["items"] as? ItemsJSON else {
            return [:]
        }

        return items.reduce([:]) { result, item in
            guard let family = item["family"] as? String,
                let files = item["files"] as? FilesJSON else {
                    return result
            }

            let variants = variants?.map { $0.rawValue }
            var result = result

            result[family] = files.flatMap { (key, value) in
                if let variants = variants {
                    return variants.contains(key) ? value.appending("#\(key)") : nil
                } else {
                    return value
                }
            }
            
            return result
        }
    }
}
