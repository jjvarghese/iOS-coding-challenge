import XCTest
@testable import WeatherNow

class SpeechCoreTests: XCTestCase {

    // MARK: - Tests -
    
    func testPrepareToStopRecordingOnPrepareToStartRecording() {
        
        class SpeechCoreMock: SpeechCore {
            var prepareToStopRecordingWasCalled: Bool = false
            
            override func prepareToStopRecording() {
                prepareToStopRecordingWasCalled = true
            }
        }
        
        let speechCoreMock = SpeechCoreMock()
        
        speechCoreMock.prepareToStartRecording()
        
        XCTAssertTrue(speechCoreMock.prepareToStopRecordingWasCalled)
    }
    
}
