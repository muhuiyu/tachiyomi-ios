//
//  String+Extensions.swift
//  Fastiee
//
//  Created by Mu Yu on 6/8/22.
//

import Foundation
import UIKit

// MARK: - Captialization
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

// MARK: - URL
extension String {
    enum URLScheme {
        case local
        case remote
        case unknown
    }
    func getURLScheme() -> URLScheme? {
        // If urlString starts with '/', it's likely a local path, so add 'file://' prefix
        let usableURLString = self.hasPrefix("/") ? "file://\(self)" : self
        guard let url = URL(string: usableURLString) else { return nil }
        switch url.scheme {
        case "http", "https":
            return .remote
        case "file":
            return .local
        default:
            return .unknown
        }
    }
}

func convertTextToAttributedString(fromHTMLInputText inputText: String) -> (String, NSAttributedString) {
    var titlesArray: [(String, NSRange)] = []
    let basicDescription = inputText as NSString
    
    guard let boldRegularExpression = try? NSRegularExpression(pattern: "<b>(.*?)</b>", options: []) else { return ("", NSAttributedString()) }
    let boldTokenFront = "<b>"
    let boldTokenBack = "</b>"
    boldRegularExpression.enumerateMatches(in: inputText, options: [],
                                           range: NSMakeRange(0, inputText.count)) { (result, flags, stop) in
        if let range = result?.range(at: 1) {
            titlesArray.append((basicDescription.substring(with: range),
                                NSRange(location: range.location - boldTokenFront.count,
                                        length: range.length + boldTokenFront.count + boldTokenBack.count)))
        }
    }
    
    let endIndex = basicDescription.length
    var parsedTitleArray: [(String, NSRange)] = []
    var parsedText: String = ""
    var currentLocation: Int = 0
    var currentParsedTextLocation: Int = 0
    for title in titlesArray {
        let titleRangeLocationIndex = title.1.location
        if currentLocation != titleRangeLocationIndex {    // plain text
            let plainTextlength = titleRangeLocationIndex - currentLocation
            let plainTextRange = NSRange(location: currentLocation, length: plainTextlength)
            let textValue = basicDescription.substring(with: plainTextRange)
            parsedText.append(textValue)
            currentLocation = titleRangeLocationIndex
            currentParsedTextLocation += plainTextlength
        }
        let titleRange = title.1
        let length = titleRange.length - boldTokenFront.count - boldTokenBack.count
        let textValue = basicDescription.substring(with: NSRange(location: titleRangeLocationIndex + boldTokenFront.count,
                                                                 length: length))
        let newTitleRange = NSRange(location: currentParsedTextLocation, length: length)
        parsedText.append(textValue)
        parsedTitleArray.append((textValue, newTitleRange))
        currentLocation += titleRange.length
        currentParsedTextLocation += length
    }
    if currentLocation != endIndex {
        let plainTextlength = endIndex - currentLocation
        let plainTextRange = NSRange(location: currentLocation, length: plainTextlength)
        let textValue = basicDescription.substring(with: plainTextRange)
        parsedText.append(textValue)
    }
    let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)]
    let attributedString = NSMutableAttributedString(string: parsedText, attributes: .none)
    for parsedTitle in parsedTitleArray {
        attributedString.addAttributes(boldFontAttribute, range: parsedTitle.1)
    }
    return (parsedText, attributedString)
}
