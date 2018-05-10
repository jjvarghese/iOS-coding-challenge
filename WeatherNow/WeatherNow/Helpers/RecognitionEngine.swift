import Foundation

struct RecognitionEngine {
    
    // MARK: - Public -
    
    func cityWasRecognized(_ textToCheck: String) -> String? {
        guard let recognizedCity = extractCityFromWords(textToCheck) else {
            return nil
        }
        
        return recognizedCity
    }
    
    // MARK: - Recognition -
    
    private func extractCityFromWords(_ textToRead: String) -> String? {
        let lowercaseString = textToRead.lowercased()
        let words = getWordsWithoutPunctuation(from: lowercaseString)
        
        var i = 0
        for word: String in words {
            if word.compare("in") == ComparisonResult.orderedSame {
                if words.count > (i + 1) {
                    return words[i + 1]
                }
            }
            
            i += 1
        }
        
        return nil
    }
    
    private func getWordsWithoutPunctuation(from string: String) -> [String] {
        return string.components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
    
}
