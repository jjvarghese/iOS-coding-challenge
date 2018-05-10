import Foundation
import Speech

class SpeechCore {
    weak var delegate: SpeechCoreDelegate?
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-AU"))!
    let audioEngine = AVAudioEngine()

    // MARK: - Public -
    
    func prepareToStartRecording() {
        if task != nil {
            task?.cancel()
            task = nil
        }
        
        setupAudioSession()
        setupAudioRequest()
        startAudioEngine()
    }
    
    func prepareToStopRecording() {
        audioEngine.stop()
        request?.endAudio()
    }
    
    func requestSpeechAuthorisation() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var wasAuthorised = false
            
            switch authStatus {
            case .authorized:
                wasAuthorised = true
                
            case .denied:
                wasAuthorised = false
                print("User denied access to speech recognition")
                
            case .restricted:
                wasAuthorised = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                wasAuthorised = false
                print("Speech recognition not yet authorized")
            }
            
            self.delegate?.speechCoreGotAuthorisationInformation(wasAuthorised)
        }
    }
    
    // MARK: - Audio -
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Couldn't set audiosession properly. Show error if time!")
        }
    }
    
    private func setupAudioRequest() {
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
                
                self.delegate?.speechCoreRecognizedText(heardText)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                
                self.request = nil
                self.task = nil
            }
        })
    }
    
    private func startAudioEngine() {
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
}

// MARK: - SpeechCoreDelegate -

protocol SpeechCoreDelegate: class {
    func speechCoreGotAuthorisationInformation(_ wasAuthorised: Bool)
    func speechCoreRecognizedText(_ recognizedText: String)
}
