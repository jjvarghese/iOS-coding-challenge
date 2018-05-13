import XCTest
@testable import WeatherNow

class AppDelegateTests: XCTestCase {
    
    // MARK: - Tests -
    
    func testConfigureStartupOnApplicationDidFinishLaunchingWithOptions() {
        
        class AppDelegateMock: AppDelegate {
            var configureStartupWasCalled: Bool = false
            
            override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
                configureStartupWasCalled = true
                
                return true
            }
        }
        
        let appDelegateMock = AppDelegateMock()
        
        let appFinishedLaunching: Bool? = appDelegateMock.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        
        if appFinishedLaunching == true {
            XCTAssertTrue(appDelegateMock.configureStartupWasCalled)
        } else {
            XCTFail()
        }
    }
}

