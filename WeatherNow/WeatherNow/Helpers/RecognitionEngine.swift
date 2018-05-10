import Foundation

struct RecognitionEngine {
    
    func textWasRecognized(_ textToCheck: String) -> Bool {
        return textToCheck.caseInsensitiveCompare("How is the weather in Berlin") == ComparisonResult.orderedSame
    }
    
}
