import XCTest
@testable import WeatherNow

class MainViewControllerTests: XCTestCase {
    
    // MARK: - XCTestCase  -
    
    var vc: MainViewController!
    
    override func setUp() {
        super.setUp()
        
        vc = MainViewController(nibName: "MainViewController", bundle: nil)
        vc.loadView()
    }
    
    override func tearDown() {
        vc = nil
        
        super.tearDown()
    }
    
    // MARK: - Subview tests -
    
    func testCorrectTextForTitle() {
        XCTAssertEqual(vc.titleLabel.text, "Ask me!")
    }
    
    func testCorrectTextForSubtitle() {
        XCTAssertEqual(vc.subtitleLabel.text, "i.e. \"How is the weather in Berlin?\"")
    }
    
    func testCorrectTextForRecordButton() {
        XCTAssertEqual(vc.recordButton.titleLabel?.text, "ASK")
    }
    
    func testCorrectTectForResultTextView() {
        XCTAssertEqual(vc.resultTextView.text, "")
    }
    
}
