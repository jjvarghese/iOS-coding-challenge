import UIKit
import Speech

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    private let speechCore = SpeechCore()
    private let weatherProvider = WeatherProvider()
    private let recognitionEngine = RecognitionEngine()
    private let defaultSubtitleText = "i.e. \"How is the weather in Berlin?\""
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()
        configureSubviews()
        configureSpeech()
        configureAccessibilityLabels()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Configuration -
    
    private func configureBackground() {
        view.backgroundColor = UIColor.white
    }
    
    private func configureSubviews() {
        configureLabels()
        configureTextView()
        configureButton()
    }
    
    private func configureLabels() {
        titleLabel.backgroundColor = UIColor.clear
        subtitleLabel.backgroundColor = UIColor.clear
    }
    
    private func configureTextView() {
        resultTextView.backgroundColor = UIColor.clear
    }
    
    private func configureButton() {
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    
    private func configureSpeech() {
        speechCore.delegate = self
        speechCore.requestSpeechAuthorisation()
        speechCore.requestMicrophoneAuthorisation()
    }
    
    private func configureAccessibilityLabels() {
        view.accessibilityIdentifier = "view"
        titleLabel.accessibilityIdentifier = "titleLabel"
        subtitleLabel.accessibilityIdentifier = "subtitleLabel"
        recordButton.accessibilityIdentifier = "recordButton"
    }
    
    // MARK: - Recording -
    
    private func startRecording() {
        styleSubviewsAsRecording(true)
        
        speechCore.prepareToStartRecording()
    }
    
    private func stopRecording() {
        speechCore.prepareToStopRecording()
        
        styleSubviewsAsRecording(false)
    }
    
    private func styleSubviewsAsRecording(_ recording: Bool) {
        OperationQueue.main.addOperation() {
            self.colorViewsForRecordingState(recording)
            
            if recording {
                self.recordButton .setTitle("STOP", for: UIControlState.normal)
                self.resultTextView.text = ""
                self.subtitleLabel.text = self.defaultSubtitleText
            } else {
                self.recordButton .setTitle("ASK", for: UIControlState.normal)
            }
        }
    }
    
    private func colorViewsForRecordingState(_ recording: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = recording ? UIColor.red : UIColor.white
            self.recordButton.backgroundColor = recording ? UIColor.white : UIColor.red
            self.recordButton .setTitleColor(recording ? UIColor.red : UIColor.white, for: UIControlState.normal)
        }
    }

    // MARK: - Actions -
    
    @IBAction func recordPressed(_ sender: Any) {
        guard speechCore.hasSpeechPermission() == true else {
             showError(with: "WeatherNow does not have permission to analyse your speech. Please check your device settings and enable permission in order to record.")
            return
        }
        
        guard speechCore.hasMicrophonePermission() == true else {
             showError(with: "WeatherNow does not have permission to access your microphone. Please check your device settings and enable permission in order to record.")
            return
        }
        
        if speechCore.audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    // MARK: - Helper -
    
    private func showError(with message: String) {
        OperationQueue.main.addOperation() {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

// MARK: - SpeechCoreDelegate -

extension MainViewController: SpeechCoreDelegate {
    
    func speechCoreRecognizedText(_ recognizedText: String) {
        guard let recognizedCity = recognitionEngine.recognizeCityFromText(recognizedText) else {
            return
        }
        
        weatherProvider.getWeather(city: recognizedCity) { (weather, error) in
            guard error == nil else {
                guard let errorDescription = error?.localizedDescription else {
                    self.showError(with: "An unknown error occurred. Please try again later.")
                    self.stopRecording()
                    return
                }
                
                self.showError(with: errorDescription)
                self.stopRecording()
                return
            }
            
            guard let parsedWeather = weather else {
                OperationQueue.main.addOperation() {
                    self.subtitleLabel.text = self.defaultSubtitleText
                    self.resultTextView.text = "Sorry, I didn't understand you! Could you please try that again? Remember to enunciate clearly ;)"
                    self.stopRecording()
                }
                
                return
            }
            
            let weatherDescriptions: WeatherDescriptions = parsedWeather.weather[0]
            let temperatureInCelsius = parsedWeather.main.temp - 273.15
            let formattedTemperature = String(format: "%.1f", temperatureInCelsius)
            let lowercaseSummary = weatherDescriptions.main.lowercased()
            
            let resultToShow = "The weather in \(parsedWeather.name) today is \(lowercaseSummary) (\(weatherDescriptions.description)), with a temperature of \(formattedTemperature) degrees celsius."
            
            OperationQueue.main.addOperation() {
                self.subtitleLabel.text = "The weather in \(parsedWeather.name):"
                self.resultTextView.text = resultToShow
                self.stopRecording()
            }
        }

    }
    
    func speechCoreEncounteredAnError(_ errorText: String) {
        showError(with: errorText)
    }
    
}
