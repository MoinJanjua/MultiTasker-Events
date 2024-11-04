//
//  TranslationViewController.swift
//  LinguaLens
//
//  Created by Unique Consulting Firm on 29/06/2024.
//

import UIKit
import AVFoundation

class TranslationViewController: UIViewController,UITextViewDelegate,UIGestureRecognizerDelegate, UITextFieldDelegate, AVSpeechSynthesizerDelegate {
    
    @IBOutlet weak var translatebtn: UIButton!
      
    @IBOutlet weak var fromCountryTF: DropDown!
    
    @IBOutlet weak var ToCountryTF: DropDown!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
       @IBOutlet weak var FromTView: UITextView!
       @IBOutlet weak var ToTextView: UITextView!
       @IBOutlet weak var FromCountryLb: UILabel!
       @IBOutlet weak var ToCountryLb: UILabel!
       @IBOutlet weak var fromSpeakButton: UIButton!
       @IBOutlet weak var toSpeakButton: UIButton!

       var fromCountryCode = String()
       var ToCountryCode = String()
       let placeholderText = "Enter text to translate..."
       var speechSynthesizer = AVSpeechSynthesizer()
       var isSpeakingFrom = false
       var isSpeakingTo = false
       
       let countries: [Country] = [
           Country(name: "United States", flag: "🇺🇸", code: "en"),
           Country(name: "Spain", flag: "🇪🇸", code: "es"),
           Country(name: "France", flag: "🇫🇷", code: "fr"),
           Country(name: "Germany", flag: "🇩🇪", code: "de"),
           Country(name: "Italy", flag: "🇮🇹", code: "it"),
           Country(name: "Japan", flag: "🇯🇵", code: "ja"),
           Country(name: "China", flag: "🇨🇳", code: "zh"),
           Country(name: "Russia", flag: "🇷🇺", code: "ru"),
           Country(name: "India", flag: "🇮🇳", code: "hi"),
           Country(name: "Brazil", flag: "🇧🇷", code: "pt"),
           Country(name: "Canada", flag: "🇨🇦", code: "en"),
           Country(name: "Mexico", flag: "🇲🇽", code: "es"),
           Country(name: "South Korea", flag: "🇰🇷", code: "ko"),
           Country(name: "Turkey", flag: "🇹🇷", code: "tr"),
           Country(name: "Saudi Arabia", flag: "🇸🇦", code: "ar"),
           Country(name: "Sweden", flag: "🇸🇪", code: "sv"),
           Country(name: "Norway", flag: "🇳🇴", code: "no"),
           Country(name: "Denmark", flag: "🇩🇰", code: "da"),
           Country(name: "Finland", flag: "🇫🇮", code: "fi"),
           Country(name: "Netherlands", flag: "🇳🇱", code: "nl"),
           Country(name: "Switzerland", flag: "🇨🇭", code: "de"),
           Country(name: "Australia", flag: "🇦🇺", code: "en"),
           Country(name: "New Zealand", flag: "🇳🇿", code: "en"),
           Country(name: "South Africa", flag: "🇿🇦", code: "af"),
           Country(name: "Argentina", flag: "🇦🇷", code: "es")
       ]
       
       override func viewDidLoad() {
           super.viewDidLoad()
           activityIndicator.isHidden = true
           fromCountryTF.isSearchEnable = false
           ToCountryTF.isSearchEnable = false
           
           fromCountryTF.delegate = self
           ToCountryTF.delegate = self
           // Create an array of formatted strings with country name and flag
           let countryNamesAndFlags = countries.map { "\($0.flag) \($0.name)" }
           fromCountryTF.optionArray = countryNamesAndFlags
           ToCountryTF.optionArray = countryNamesAndFlags
           
           fromCountryTF.didSelect { [weak self] (selectedText, index, id) in
               guard let self = self else { return }
               let selectedCountryCode = self.countries[index].code
               let name = self.countries[index].name
               self.fromCountryCode = selectedCountryCode
               self.FromCountryLb.text = "(\(name))"
               print("Selected from Country Code: \(selectedCountryCode)")
           }
       
           ToCountryTF.didSelect { [weak self] (selectedText, index, id) in
               guard let self = self else { return }
               let selectedCountryCode = self.countries[index].code
               self.ToCountryCode = selectedCountryCode
               let name = self.countries[index].name
                   
               self.ToCountryLb.text = "(\(name))"
               print("Selected to Country Code: \(selectedCountryCode)")
           }
           
           FromTView.delegate = self
           FromTView.text = placeholderText
           FromTView.textColor = UIColor.darkGray
           
           speechSynthesizer.delegate = self
           
//           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//           tapGesture.delegate = self
//           view.addGestureRecognizer(tapGesture)
       }
       
       @objc func dismissKeyboard() {
           view.endEditing(true)
           FromTView.resignFirstResponder()
           ToTextView.resignFirstResponder()
       }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
     /**
      * Called when the user click on the view (outside the UITextField).
      */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func translatebtnPressed(_ sender: UIButton) {
        let fromText = FromTView.text.trimmingCharacters(in: .whitespacesAndNewlines)
               
               // Check if the text view contains the placeholder or is empty
               if fromText.isEmpty || fromText == placeholderText {
                   showAlert(title: "Error!", message: "Please Enter The Text")
                   return
               }
         
         if !fromCountryCode.isEmpty && !ToCountryCode.isEmpty {
             activityIndicator.startAnimating()
             activityIndicator.isHidden = false
             SwiftyTranslate.translate(text: fromText ?? "", from: fromCountryCode, to: ToCountryCode) { result in
                 DispatchQueue.main.async {
                     self.activityIndicator.stopAnimating()
                     self.activityIndicator.isHidden = true
                     switch result {
                     case .success(let translation):
                         print("Translated: \(translation.translated)")
                         self.ToTextView.text = translation.translated
                     case .failure(let error):
                         print("Error: \(error)")
                         self.showAlert(title: "Error!", message: "Translation failed. Please try again.")
                     }
                 }
             }
         } else {
             showAlert(title: "Error!", message: "Please Select the Country First")
         }
     }
    
    @IBAction func backbtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func ShareFromButton(_ sender: Any) {
        if let textToShare = FromTView.text {
               let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
               
               // Present the activity view controller
               activityViewController.popoverPresentationController?.sourceView = self.view // For iPad support
               self.present(activityViewController, animated: true, completion: nil)
           }
    }
    
    @IBAction func ShareToButton(_ sender: Any) {
        if let textToShare = ToTextView.text {
               let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
               
               // Present the activity view controller
               activityViewController.popoverPresentationController?.sourceView = self.view // For iPad support
               self.present(activityViewController, animated: true, completion: nil)
           }
        
    }
    @IBAction func FromcopybtnPressed(_ sender: UIButton) {
          UIPasteboard.general.string = FromTView.text
          self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
      }
      
      @IBAction func TocopybtnPressed(_ sender: UIButton) {
          UIPasteboard.general.string = ToTextView.text
          self.showToast(message: "Text Copied", font: .systemFont(ofSize: 14.0))
      }
      
      @IBAction func FromspeakbtnPressed(_ sender: UIButton) {
          speak(text: FromTView.text, languageCode: fromCountryCode)
      }
      
      @IBAction func TospeakbtnPressed(_ sender: UIButton) {
          speak(text: ToTextView.text, languageCode: ToCountryCode)
      }
      
      func speak(text: String, languageCode: String) {
          let utterance = AVSpeechUtterance(string: text)
          utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
          speechSynthesizer.speak(utterance)
      }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        FromTView.textColor = .darkGray
            if textView.text == placeholderText {
                textView.text = ""
                textView.textColor = UIColor.darkGray
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = UIColor.lightGray
            }
        }
}


extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-500, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.backgroundColor = .systemYellow
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
