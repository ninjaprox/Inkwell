//
//  NameDictionary.swift
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

import Foundation

protocol NameDictionaryProtocol {

    func postscriptName(for font: Font) -> String?
    func setPostscriptName(_ name: String, for font: Font) -> Bool
}

final class NameDictionary: NameDictionaryProtocol {
    private let storage: Storable
    private var cache: NSMutableDictionary?

    init(storage: Storable) {
        self.storage = storage
    }

    // MARK: - Interface

    /// Get the postscript name of specified font.
    ///
    /// - Parameter font: The font needed to get the postscript name.
    /// - Returns: The postscript name.
    func postscriptName(for font: Font) -> String? {
        guard let nameDictionary = cache ?? NSMutableDictionary(contentsOf: storage.nameDictionaryURL) else {
            return nil
        }

        if cache == nil {
            cache = nameDictionary
        }

        return lookUpPostscriptName(for: font) ??
            (nameDictionary.value(forKey: font.name) as? String)
    }

    /// Set the postscript name of specified font.
    ///
    /// - Parameters:
    ///   - name: The postscript name.
    ///   - font: The font needed to get the postscript name.
    /// - Returns: `true` if set successfully, otherwise `false`.
    @discardableResult func setPostscriptName(_ name: String, for font: Font) -> Bool {
        let URL = storage.nameDictionaryURL
        let nameDictionary = cache ?? NSMutableDictionary(contentsOf: URL) ?? NSMutableDictionary(capacity: 1)

        nameDictionary.setValue(name, forKey: font.name)
        if cache == nil {
            cache = nameDictionary
        }

        return nameDictionary.write(to: URL, atomically: true)
    }

    // MARK: - Helpers

    /// Try to look up the postscript name of specified font from registered fonts.
    ///
    /// - Parameter font: The font needed to get the postscript name.
    /// - Returns: The postscript name.
    private func lookUpPostscriptName(for font: Font) -> String? {
        let weightNounRegex = try! NSRegularExpression(pattern: "(light|medium|bold|extrabold)", options: [.caseInsensitive])
        let obliqueNounRegex = try! NSRegularExpression(pattern: "(italic|oblique)", options: [.caseInsensitive])
        let boldRegex = try! NSRegularExpression(pattern: "(?<!\\w)bold", options: [.caseInsensitive])
        let regularRegex = try! NSRegularExpression(pattern: "(^\\w+$|regular|(?<!\\w)medium)", options: [.caseInsensitive])
        let fontNames = UIFont.fontNames(forFamilyName: font.family)
        var filteredFontNames = fontNames

        /*
         ["ArialMT", "Arial-BoldItalicMT", "Arial-BoldMT", "Arial-ItalicMT"]
         ["CourierNewPS-BoldMT", "CourierNewPS-ItalicMT", "CourierNewPSMT", "CourierNewPS-BoldItalicMT"]
         ["Futura-CondensedMedium", "Futura-CondensedExtraBold", "Futura-Medium", "Futura-MediumItalic", "Futura-Bold"]
         ["Georgia-BoldItalic", "Georgia", "Georgia-Italic", "Georgia-Bold"]
         ["Helvetica-Bold", "Helvetica", "Helvetica-LightOblique", "Helvetica-Oblique", "Helvetica-BoldOblique", "Helvetica-Light"]
         ["TimesNewRomanPSMT", "TimesNewRomanPS-BoldItalicMT", "TimesNewRomanPS-ItalicMT", "TimesNewRomanPS-BoldMT"]
         ["Trebuchet-BoldItalic", "TrebuchetMS", "TrebuchetMS-Bold", "TrebuchetMS-Italic"]
         ["Verdana-Italic", "Verdana-BoldItalic", "Verdana", "Verdana-Bold"]
         */

        switch font.variant {
        case ._700italic:
            filteredFontNames = fontNames.filter {
                return regexMatches(boldRegex, string: $0) &&
                    regexMatches(obliqueNounRegex, string: $0)
            }
        case ._700:
            filteredFontNames = fontNames.filter {
                return regexMatches(boldRegex, string: $0) &&
                    !regexMatches(obliqueNounRegex, string: $0)
            }
        case .italic:
            filteredFontNames = fontNames.filter {
                return regexMatches(obliqueNounRegex, string: $0) &&
                    !regexMatches(weightNounRegex, string: $0)
            }
            // Give another try with weight nouns.
            if filteredFontNames.count == 0 {
                filteredFontNames = fontNames.filter {
                    return regexMatches(obliqueNounRegex, string: $0)
                }
            }
        case .regular:
            filteredFontNames = fontNames.filter {
                return regexMatches(regularRegex, string: $0) &&
                    !regexMatches(obliqueNounRegex, string: $0)
            }
        }

        return filteredFontNames.count > 0 ? filteredFontNames[0] : nil
    }

    private func regexMatches(_ regex: NSRegularExpression, string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        
        return regex.matches(in: string, options: [], range: range).count > 0
    }
}
