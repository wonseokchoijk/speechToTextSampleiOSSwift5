//
//  ViewController.swift
//  STT
//
//  Created by Zedd on 2017. 3. 10..
//  Copyright © 2017년 Zedd. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var button: UIButton!
    
    
private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var timer : Timer?
    var resultStr: String = ""
    
    @IBAction func speechToText(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.recognitionTask?.cancel()
            button.isEnabled = false
            button.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            button.setTitle("Stop Recording", for: .normal)
        }
    }
    @IBOutlet weak var myTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self

    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            self.timer?.invalidate()
//            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: Selector("didFinishTalk"), userInfo: nil, repeats: false)
            self.timer = Timer.scheduledTimer(withTimeInterval:1.0, repeats:false) { _ in

                self.timer?.invalidate()
//                Logger.log.debug("FINAL result!.bestTranscription.formattedString: \(String(describing: result.bestTranscription.formattedString))")

//                self.voiceRecognizingAlert(str: self.resultStr)
                
                self.audioEngine.stop() // オーティオ入力を中断
                recognitionRequest.endAudio() // 音声認識も中断
                self.recognitionTask?.cancel()
            }
            
            
            var isFinal = false
            
            if result != nil {
                
                self.myTextView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.button.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        myTextView.text = "Say something, I'm listening!"
        
    }
    
    
   
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }

}

