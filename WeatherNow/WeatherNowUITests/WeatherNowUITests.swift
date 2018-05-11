import XCTest

class WeatherNowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - XCTestCase -
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
    }
    
    // MARK: - Tests -
    
    func testRecordButtonChangesTextOnTap() {
        app.launch()
        
        let recordButton = app.buttons["recordButton"]
        
        XCTAssertTrue(recordButton.label == "ASK")
        recordButton.tap()
        XCTAssertTrue(recordButton.label == "STOP")
        recordButton.tap()
        XCTAssertTrue(recordButton.label == "ASK")
    }
    
    // Note: Due to the simplicity of this app's GUI and its primary UI changing behaviour being contingent upon speech recognition, this will be the only UI test created.
}
