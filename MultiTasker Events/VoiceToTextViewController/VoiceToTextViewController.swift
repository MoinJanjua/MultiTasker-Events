//
//  VoiceToTextViewController.swift
//  Linguamaster
//
//  Created by Developer UCF on 31/07/2024.
//

import UIKit
import Speech
import AVKit
import Lottie

class VoiceToTextViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate ,UIGestureRecognizerDelegate ,AVSpeechSynthesizerDelegate{
    
    @IBOutlet weak var Micbtn: UIButton!
        @IBOutlet weak var FromTV: UITextView!
        @IBOutlet weak var ToTV: UITextView!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var currentDateTF: UITextField!
    @IBOutlet weak var EventNameTF: UITextField!

    
    var ToCountryCode = String()
        var speechRecognizer: SFSpeechRecognizer? // Modified: Initialize without a locale for auto-detection
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let audioEngine = AVAudioEngine()
        var speechSynthesizer = AVSpeechSynthesizer()
        
        // Countries array remains the same...
    private var animationView: LottieAnimationView!
    private var isAnimationPlaying = false
    let datePicker = UIDatePicker()
    
    var selectedTranslation: VoiceRecognization?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // If there is selectedTranslation, populate the fields for editing
               if let translation = selectedTranslation {
                   FromTV.text = translation.VoiceDescription
                   EventNameTF.text = translation.Tittle
                   currentDateTF.text = translation.DateofSave
               }
//        // Set up the date picker
//         configureDatePicker()
        
        setupLottieAnimation()
        setupSpeech()
        speechSynthesizer.delegate = self
        FromTV.delegate = self
        
        setupDatePicker(for: currentDateTF, target: self, doneAction: #selector(donePressed))
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
     
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @objc func donePressed() {
        // Get the date from the picker and set it to the text field
        if let datePicker = currentDateTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            currentDateTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        currentDateTF.resignFirstResponder()
    }
//    func configureDatePicker() {
//          // Set the date picker mode to date (you can use .dateAndTime if you want both date and time)
//          datePicker.datePickerMode = .date
//          
//          // Set the current date
//          datePicker.date = Date()
//
//          // Add the date picker as the input view for the text field
//        currentDateTF.inputView = datePicker
//          
//          // Create a toolbar with a Done button
//          let toolbar = UIToolbar()
//          toolbar.sizeToFit()
//
//          // Add a Done button on the toolbar
//          let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
//          toolbar.setItems([doneButton], animated: true)
//
//          // Assign the toolbar to the text field's input accessory view
//        currentDateTF.inputAccessoryView = toolbar
//
//          // Automatically display the current date in the text field
//          updateTextFieldWithDate(date: Date())
//      }
//
//      @objc func donePressed() {
//          // Get the selected date from the date picker
//          let selectedDate = datePicker.date
//          
//          // Update the text field with the selected date
//          updateTextFieldWithDate(date: selectedDate)
//          
//          // Dismiss the date picker
//          currentDateTF.resignFirstResponder()
//      }
//
//      func updateTextFieldWithDate(date: Date) {
//          // Create a date formatter to convert the date into a string
//          let formatter = DateFormatter()
//          formatter.dateFormat = "dd-MM-yyyy" // Customize the format if needed
//
//          // Set the text field's text to the formatted date string
//          currentDateTF.text = formatter.string(from: date)
//      }
    @objc func dismissKeyboard() {
        view.endEditing(true)
        FromTV.resignFirstResponder()
        ToTV.resignFirstResponder()
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        FromTV.textColor = .darkGray
//            if textView.text == placeholderText {
//                textView.text = ""
//                textView.textColor = UIColor.darkGray
//                
//            }
//        }

//        func textViewDidEndEditing(_ textView: UITextView) {
//            if textView.text.isEmpty {
//                textView.text = placeholderText
//                textView.textColor = UIColor.lightGray
//            }
//        }

    func setupSpeech() {
          Micbtn.isEnabled = false
          speechRecognizer = SFSpeechRecognizer() // Initialize without a locale for auto-detection
          speechRecognizer?.delegate = self
          
          SFSpeechRecognizer.requestAuthorization { (authStatus) in
              var isButtonEnabled = false
              switch authStatus {
              case .authorized:
                  isButtonEnabled = true
              case .denied, .restricted, .notDetermined:
                  isButtonEnabled = false
                  print("Speech recognition authorization failed with status: \(authStatus)")
              }
              
              OperationQueue.main.addOperation {
                  self.Micbtn.isEnabled = isButtonEnabled
              }
          }
      }
    func clearTextFields() {
        FromTV.text = ""
        currentDateTF.text = ""
        EventNameTF.text = ""
        }
      func startRecording() {
          if recognitionTask != nil {
              recognitionTask?.cancel()
              recognitionTask = nil
          }
          
          let audioSession = AVAudioSession.sharedInstance()
          do {
              try audioSession.setCategory(.record, mode: .measurement, options: .defaultToSpeaker)
              try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
          } catch {
              print("Failed to set audio session properties.")
          }
          
          recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
          guard let recognitionRequest = recognitionRequest else {
              fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
          }
          
          recognitionRequest.shouldReportPartialResults = true
          
          let inputNode = audioEngine.inputNode
          recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
              var isFinal = false
              if let result = result {
                  self.FromTV.text = result.bestTranscription.formattedString
                  isFinal = result.isFinal
              }
              
              if error != nil || isFinal {
                  self.audioEngine.stop()
                  inputNode.removeTap(onBus: 0)
                  self.recognitionRequest = nil
                  self.recognitionTask = nil
                  self.Micbtn.isEnabled = true
              }
          }
          
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
          
          FromTV.text = "Say something, I'm listening!"
      }
    func speak(text: String, languageCode: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Set audio session category and mode
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session properties.")
        }
        
        speechSynthesizer.speak(utterance)
    }

    private func setupLottieAnimation() {
            // Create and configure the Lottie Animation View
            animationView = LottieAnimationView(name: "A1") // Make sure "v1.json" is in your project
            animationView.loopMode = .loop
            animationView.contentMode = .scaleAspectFit
            animationView.frame = CGRect(x: 150, y: 180, width: 100, height: 100) // Adjust the frame as needed
           // animationView.center = self.view.center // Center the animation view

            // Add the animation view to the view controller's view but keep it initially hidden
            self.view.addSubview(animationView)
            animationView.isHidden = true
        }

    
    @IBAction func Micbtn(_ sender: UIButton) {
        if audioEngine.isRunning {
                    // Stop recording
                    audioEngine.stop()
                    recognitionRequest?.endAudio()
                    Micbtn.isEnabled = false
                    Micbtn.setTitle("Start Recording", for: .normal)
                    // Stop the Lottie animation and hide the view
                    animationView.stop()
                    animationView.isHidden = true
                    isAnimationPlaying = false

                } else {
                    // Start recording
                    startRecording()
                    Micbtn.setTitle("Stop Recording", for: .normal)
                    // Show and start the Lottie animation
                    animationView.isHidden = false
                    animationView.play()
                    isAnimationPlaying = true
                }
    }

    func saveOrderData(_ sender: Any) {
        // Ensure fields are not empty
            guard let from = FromTV.text, !from.isEmpty,
                  let tittleof = EventNameTF.text, !tittleof.isEmpty,
                  let dateSave = currentDateTF.text, !dateSave.isEmpty else {
                showAlert(title: "Error", message: "Please Fill All The Fields")
                return
            }
            
            let newTranslation = VoiceRecognization(
                VoiceDescription: from, Tittle: tittleof, DateofSave: dateSave
            )

            // Check if editing or creating new entry
            if let index = selectedIndex {
                updateSavedData(newTranslation, at: index) // Update existing entry
            } else {
                saveCreateSaleDetail(newTranslation) // Save new entry
            }
        }
    
    // Function to update existing data
    func updateSavedData(_ updatedTranslation: VoiceRecognization, at index: Int) {
        if var savedData = UserDefaults.standard.array(forKey: "voiceRecognizationDetails") as? [Data] {
            let encoder = JSONEncoder()
            do {
                let updatedData = try encoder.encode(updatedTranslation)
                savedData[index] = updatedData // Update the specific index
                UserDefaults.standard.set(savedData, forKey: "voiceRecognizationDetails")
            } catch {
                print("Error encoding data: \(error.localizedDescription)")
            }
        }
        showAlert(title: "Updated", message: "Your Event Has Been Updated Successfully.")
    }
    func saveCreateSaleDetail(_ order: VoiceRecognization) {
        var orders = UserDefaults.standard.object(forKey: "voiceRecognizationDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "voiceRecognizationDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Your Event Has Been Saved & Set Successfully.")
    }
    
    
    @IBAction func SavedataButtonn(_ sender: Any) {
        saveOrderData(sender)
    }
 
    @IBAction func Backbtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
extension VoiceToTextViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.Micbtn.isEnabled = true
        } else {
            self.Micbtn.isEnabled = false
        }
    }
}
