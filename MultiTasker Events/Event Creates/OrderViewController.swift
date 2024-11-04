//
//  OrderViewController.swift
//  POS
//
//  Created by Maaz on 09/10/2024.
//

import UIKit
import UserNotifications


class OrderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var EventNameTF: UITextField!
    @IBOutlet weak var DateAndTimeTF: UITextField!
    @IBOutlet weak var LocationTF: UITextField!
    @IBOutlet weak var DescriptionTF: UITextField!
    @IBOutlet weak var datePickerAndTime: UIDatePicker!
    @IBOutlet weak var notificationbutton: UISwitch!

    var pickedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification access granted")
            } else {
                print("Notification access denied")
            }
        }
        //applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    func clearTextFields() {
        EventNameTF.text = ""
        DateAndTimeTF.text = ""
        LocationTF.text = ""
        DescriptionTF.text = ""
    //    datePickerAndTime.date = nil
        
    }
    func saveOrderData(_ sender: Any) {
        // Check if event title is filled
        guard let eventTittle = EventNameTF.text, !eventTittle.isEmpty else {
            showAlert(title: "Error", message: "Please fill the event title.")
            return
        }

        // If LocationTF or DescriptionTF is empty, store the string "nil"
        let location = LocationTF.text?.isEmpty == true ? "Nil" : LocationTF.text
        let description = DescriptionTF.text?.isEmpty == true ? "Nil" : DescriptionTF.text

        // Get selected date and time from the date picker
        let selectedDateTime = datePickerAndTime.date
        let currentDateTime = Date()

        // Check if the selected date is the same as today
        if Calendar.current.isDate(selectedDateTime, inSameDayAs: currentDateTime) {
            // If the selected time is the same or earlier than the current time
            if selectedDateTime <= currentDateTime {
                showAlert(title: "Error", message: "Please select a future time.")
                return
            }
        }

        // Create new order detail safely
        let newCreateSale = Events(
            Tittle: eventTittle, DateAndTime: selectedDateTime,
            Location: location ?? "nil", Description: description ?? "nil"
        )

        // Save the order detail
        saveCreateSaleDetail(newCreateSale)

        // Schedule a notification if the switch is on
        if notificationbutton.isOn {
            scheduleNotification(for: eventTittle, eventDate: selectedDateTime)
        }
    }



    // Schedule notification for the selected event
    private func scheduleNotification(for eventName: String, eventDate: Date) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Event Reminder"
        notificationContent.body = "Your event '\(eventName)' is coming up!"
        notificationContent.sound = UNNotificationSound.default
        
        // Calculate the trigger date and time (e.g., one hour before the event)
        let triggerDate = Calendar.current.date(byAdding: .hour, value: -1, to: eventDate) ?? eventDate
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveCreateSaleDetail(_ order: Events) {
        var orders = UserDefaults.standard.object(forKey: "EventDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "EventDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Event Details has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveOrderData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
