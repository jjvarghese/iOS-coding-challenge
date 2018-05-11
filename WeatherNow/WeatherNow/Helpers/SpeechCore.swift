import Foundation
import Speech

class SpeechCore {
    weak var delegate: SpeechCoreDelegate?
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-AU"))! // TODO: Dynamic locale initiation within language boundaries (i.e. all English possibilities)
    let audioEngine = AVAudioEngine()

    // MARK: - Public -
    
    func prepareToStartRecording() {
        prepareToStopRecording()

        setupAudioSession()
        setupAudioRequest()
        startAudioEngine()
    }
    
    func prepareToStopRecording() {
        if task != nil {
            task?.cancel()
            task = nil
        }
        
        audioEngine.stop()
        request?.endAudio()
    }
    
    func requestSpeechAuthorisation() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in }
    }
    
    func requestMicrophoneAuthorisation() {
        AVAudioSession.sharedInstance().requestRecordPermission { (authStatus) in }
    }
    
    func hasSpeechPermission() -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .denied:
            return false
        case .restricted:
            return false
        case .notDetermined:
            return false
        }
    }
    
    func hasMicrophonePermission() -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            return true
        case AVAudioSessionRecordPermission.denied:
            return false
        case AVAudioSessionRecordPermission.undetermined:
            return false
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
            handleAudioSessionCouldNotSetPropertiesError()
        }
    }
    
    private func setupAudioRequest() {
        request = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = request else {
            handleRecognitionRequestCouldNotBeMadeError()
            return
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
            handleAudioEngineCouldNotStartError()
        }
    }
    
    // MARK: - Error Handling -
    
    private func handleAudioEngineCouldNotStartError() {
        let errorText = "Audio Engine could not start. Please try again later."
        delegate?.speechCoreEncounteredAnError(errorText)
        prepareToStopRecording()
    }
    
    private func handleRecognitionRequestCouldNotBeMadeError() {
        let errorText = "The recognition request could not be made. Please try again later."
        delegate?.speechCoreEncounteredAnError(errorText)
        prepareToStopRecording()
    }
    
    private func handleAudioSessionCouldNotSetPropertiesError() {
        let errorText = "Could not correctly setup the audio session. Please try again later."
        delegate?.speechCoreEncounteredAnError(errorText)
        prepareToStopRecording()
    }
}

// MARK: - SpeechCoreDelegate -

protocol SpeechCoreDelegate: class {
    func speechCoreRecognizedText(_ recognizedText: String)
    func speechCoreEncounteredAnError(_ errorText: String)
}
