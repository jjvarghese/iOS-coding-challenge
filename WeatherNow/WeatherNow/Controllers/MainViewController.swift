import UIKit
import Speech

class MainViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-AU"))!
    
    // MARK: - UIViewController -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()
        configureSubviews()
        configureSpeech()
    }
    
    // MARK: - Configuration -
    
    func configureBackground() {
        view.backgroundColor = UIColor.lightText
    }
    
    func configureSubviews() {
        configureLabels()
        configureTextView()
        configureButton()
    }
    
    func configureLabels() {
        titleLabel.backgroundColor = UIColor.clear
        subtitleLabel.backgroundColor = UIColor.clear
    }
    
    func configureTextView() {
        resultTextView.backgroundColor = UIColor.clear
    }
    
    func configureButton() {
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.setTitleColor(UIColor.white, for: UIControlState.normal)
    }
    
    func configureSpeech() {
        recognizer.delegate = self
        requestSpeechAuthorisation()
    }
    
    // MARK: - Speech -
    
    func requestSpeechAuthorisation() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    // MARK: - Recording -
    
    func startRecording() {
        styleSubviewsAsRecording(true)
        
        if task != nil {
            task?.cancel()
            task = nil
        }
        
        setupAudioSession()
        setupAudioRequest()
        startAudioEngine()
    }
    
    func stopRecording() {
        audioEngine.stop()
        request?.endAudio()
        styleSubviewsAsRecording(false)
    }
    
    func styleSubviewsAsRecording(_ recording: Bool) {
        if recording {
            view.backgroundColor = UIColor.red
            recordButton .setTitle("STOP", for: UIControlState.normal)
        } else {
            view.backgroundColor = UIColor.lightText
            recordButton .setTitle("RECORD", for: UIControlState.normal)
        }
    }
    
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Couldn't set audiosession properly. Show error if time!")
        }
    }
    
    func setupAudioRequest() {
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = request else {
            fatalError("Request couldn't be made. Ideally show an error if time!")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        task = recognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                guard let heardText = result?.bestTranscription.formattedString else {
                    return
                }
                
                self.resultTextView.text = heardText
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                
                self.request = nil
                self.task = nil
                
                self.recordButton.isEnabled = true
            }
        })
    }
    
    func startAudioEngine() {
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine couldn't start. Ideally show an error to the user at this point - will add if time permits!")
        }
    }

    // MARK: - Actions -
    
    @IBAction func recordPressed(_ sender: Any) {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
}
