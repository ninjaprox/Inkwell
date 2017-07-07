//
//  GoogleFontsMetadata.swift
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
    private let defaultVariantFilter: (String) -> Bool = {
        let variants: [Font.Variant] = [.regular, ._700, .italic, ._700italic]

        return variants.map { $0.rawValue }.contains($0)
    }
    private var cache: FamilyDictionary?

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
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue, options: .allowFragments) { response in
                let familyResponse = response.flatMap { json -> FamilyDictionary in
                    guard let json = json as? JSON else { return [:] }

                    return self.parse(json: json, variantFilter: self.defaultVariantFilter)
                }

                switch familyResponse.result {
                case .success(let value):
                    self.cache = value
                    completion(.success(value))
                case .failure(let error):
                    self.storage.removeGoogleFontsMetadata()
                    completion(.failure(error))
                }
        }
    }

    /// Get the family dictionary from persisted Google Fonts metadata file.
    ///
    /// - Returns: The family dictionary.
    func familyDictionary() -> FamilyDictionary {
        if let cache = cache {
            return cache
        }

        guard let data = try? Data(contentsOf: storage.metadataURL),
            let optionalJson = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
            let json = optionalJson as? JSON else {
                cache = nil

                return [:]
        }

        if cache == nil {
            cache = parse(json: json, variantFilter: defaultVariantFilter)
        }

        return cache!
    }

    /// Get the file of specified font.
    ///
    /// - Parameters:
    ///   - font: The font needed to get the file.
    ///   - familyDictionary: The family dictionary to look up the file.
    /// - Returns: The file.
    func file(of font: Font, familyDictionary: FamilyDictionary?) -> String? {
        let familyDictionary = cache ?? familyDictionary ?? self.familyDictionary()

        guard let files = familyDictionary[font.family],
            let index = files.index(where: { $0.hasSuffix(font.variant.rawValue) }) else {
                return nil
        }

        return files[index]
    }

    /// Check if the Google Fonts metadata file exists.
    ///
    /// - Returns: `true` if existing, otherwise `false`.
    func exist() -> Bool {
        return storage.googleFontsMetadataExists()
    }

    // MARK: - Helpers

    /// Parse the JSON to the family dictionary.
    ///
    /// - Note: Only concerned variants are taken.
    ///
    /// - Parameters:
    ///   - json: The JSON.
    ///   - variantFilter: The variant filter.
    /// - Returns: The family dictionary.
    private func parse(json: JSON, variantFilter: ((String) -> Bool)) -> FamilyDictionary {
        guard let items = json["items"] as? ItemsJSON else {
            return [:]
        }

        return items.reduce([:]) { result, item in
            guard let family = item["family"] as? String,
                let files = item["files"] as? FilesJSON else {
                    return result
            }

            var result = result

            result[family] = files.flatMap { (key, value) in
                guard variantFilter(key),
                    var urlComponents = URLComponents(string: value) else { return nil }

                urlComponents.scheme = "https"
                urlComponents.fragment = key
                
                return urlComponents.string
            }
            
            return result
        }
    }
}
