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
        colorViewsForRecordingState(recording)
        
        if recording {
            recordButton .setTitle("STOP", for: UIControlState.normal)
            resultTextView.text = ""
            subtitleLabel.text = defaultSubtitleText
        } else {
            recordButton .setTitle("ASK", for: UIControlState.normal)
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
        if speechCore.audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
}

// MARK: - SpeechCoreDelegate -

extension MainViewController: SpeechCoreDelegate {
    
    func speechCoreGotAuthorisationInformation(_ wasAuthorised: Bool) {
        OperationQueue.main.addOperation() {
            self.recordButton.isEnabled = wasAuthorised
        }
    }
    
    func speechCoreRecognizedText(_ recognizedText: String) {
        guard let recognizedCity = recognitionEngine.cityWasRecognized(recognizedText) else {
            return
        }
        
        weatherProvider.getWeather(city: recognizedCity) { (weather, error) in
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
    
}
