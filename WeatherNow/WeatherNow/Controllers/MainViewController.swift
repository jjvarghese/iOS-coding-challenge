import UIKit
import Speech

class MainViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    private var speechCore = SpeechCore()
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()
        configureSubviews()
        configureSpeech()
    }
    
    // MARK: - Configuration -
    
    private func configureBackground() {
        view.backgroundColor = UIColor.lightText
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
        if recording {
            view.backgroundColor = UIColor.red
            recordButton .setTitle("STOP", for: UIControlState.normal)
        } else {
            view.backgroundColor = UIColor.lightText
            recordButton .setTitle("RECORD", for: UIControlState.normal)
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
        OperationQueue.main.addOperation() {
            self.resultTextView.text = recognizedText
        }
    }
    
}
