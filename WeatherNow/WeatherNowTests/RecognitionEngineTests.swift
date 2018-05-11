import XCTest
@testable import WeatherNow

class RecognitionEngineTests: XCTestCase {
    
    // MARK: - XCTestCase  -
    
    var recognitionEngine: RecognitionEngine!
    
    override func setUp() {
        super.setUp()
        
        recognitionEngine = RecognitionEngine()
    }
    
    override func tearDown() {
        recognitionEngine = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests -
    
    func testRecognizedCorrectCityNameWithMultipleWords() {
        let sentenceToCheck = "I would love to know the weather in Rio de Janeiro!!"
        let foundCity = recognitionEngine.recognizeCityFromText(sentenceToCheck)
        XCTAssertEqual(foundCity, "+rio+de+janeiro")
    }
    
    func testRecognizedCorrectCityNameWithSingleWord() {
        let sentenceToCheck = "Tell me about the weather in Melbourne"
        let foundCity = recognitionEngine.recognizeCityFromText(sentenceToCheck)
        XCTAssertEqual(foundCity, "+melbourne")
    }
    
    func testDidNotRecognizeCityName() {
        let sentenceToCheck = "This is an unrelated sentence that the engine is not trained to recognise..."
        let foundCity = recognitionEngine.recognizeCityFromText(sentenceToCheck)
        XCTAssertNil(foundCity)
    }
}
