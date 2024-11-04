//
//  RecordsViewController.swift
//  POS
//
//  Created by Maaz on 10/10/2024.
//

import UIKit
import PDFKit
import UserNotifications


class RecordsViewController: UIViewController {
    
    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var createbtn: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!  // Add this outlet for the label

    var events_Detail: [Events] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TableView.dataSource = self
        TableView.delegate = self
        
    //    applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 35)
        addDropShadowButtonOne(to: createbtn)
        
        noDataLabel.text = "There is no data available, please create sales first" // Set the message
     //   // Request permission for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification access granted")
            } else {
                print("Notification access denied")
            }
        }
    

    }
    override func viewWillAppear(_ animated: Bool) {
        // Load data from UserDefaults
        // Retrieve stored medication records from UserDefaults
        if let savedData = UserDefaults.standard.array(forKey: "EventDetails") as? [Data] {
            let decoder = JSONDecoder()
            events_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(Events.self, from: data)
                    return order
                } catch {
                    print("Error decoding medication: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        noDataLabel.text = "There Is No Event Available, Please Add Your Events First" // Set the message
        // Show or hide the table view and label based on data availability
               if events_Detail.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
     TableView.reloadData()
    }
    func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "MultiTasker Events",
            
            kCGPDFContextTitle: "Events All Data"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0 // 8.5 inches in points
        let pageHeight = 11.0 * 72.0 // 11 inches in points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let title = "Events Report"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let titleSize = title.size(withAttributes: attributes)
            let titleRect = CGRect(x: (pageRect.width - titleSize.width) / 2.0, y: 36, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: attributes)
            
            var yOffset = titleRect.maxY + 36 // Start below the title
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Loop through order_Detail and add each record to the PDF
            for order in events_Detail {
                let orderText = """
                Product: \(order.Tittle)
                User: \(order.Location)
                Date: \(formatDate(order.DateAndTime))
                """
                let textSize = orderText.size(withAttributes: textAttributes)
                let textRect = CGRect(x: 36, y: yOffset, width: pageRect.width - 72, height: textSize.height)
                orderText.draw(in: textRect, withAttributes: textAttributes)
                
                yOffset += textSize.height + 12 // Adjust spacing between entries
                
                // Add a new page if content goes beyond the current page height
                if yOffset > pageRect.height - 72 {
                    context.beginPage()
                    yOffset = 36 // Reset for new page
                }
            }
        }
        
        return data
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    private func clearUserData() {
        // Remove keys related to user data but not login information
        UserDefaults.standard.removeObject(forKey: "EventDetails")
        

 }

    private func showResetConfirmation() {
        let confirmationAlert = UIAlertController(title: "Reset Complete", message: "The data has been reset successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        confirmationAlert.addAction(okAction)
        self.present(confirmationAlert, animated: true, completion: nil)
    }
    @IBAction func PdfGenerateButton(_ sender: Any) {
        // Generate PDF
           let pdfData = generatePDF()
           
           // Save the PDF data to a temporary file
           let tempDirectory = FileManager.default.temporaryDirectory
           let pdfPath = tempDirectory.appendingPathComponent("EventsData.pdf")
           
           do {
               try pdfData.write(to: pdfPath)
               // Share the PDF
               let activityViewController = UIActivityViewController(activityItems: [pdfPath], applicationActivities: nil)
               present(activityViewController, animated: true, completion: nil)
           } catch {
               print("Error saving PDF: \(error.localizedDescription)")
           }

    }
    @IBAction func CreateSales(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    @IBAction func ClearAllSalesButton(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Events Data", message: "Are you sure you want to remove all the events data?", preferredStyle: .alert)
          
          let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
              // Step 1: Clear user-specific data from UserDefaults
              self.clearUserData()
              
              // Step 2: Clear the data source (order_Detail array)
              self.events_Detail.removeAll()
              
              // Step 3: Reload the table view to reflect the change
              self.TableView.reloadData()
              
              // Step 4: Optionally, show a confirmation to the user
              self.showResetConfirmation()
          }
          
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          
          alert.addAction(confirmAction)
          alert.addAction(cancelAction)
          
          self.present(alert, animated: true, completion: nil)
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension RecordsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events_Detail.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ordersCell", for: indexPath) as! RecordsTableViewCell

        let EventData = events_Detail[indexPath.row]
        cell.eventNameLabel?.text = EventData.Tittle
        cell.locationLbl?.text = EventData.Location
//        cell.orderNumLbl?.text = EventData.Description

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        // Set the event date
        let eventDate = EventData.DateAndTime
        cell.dateLbl.text = dateFormatter.string(from: eventDate)
        
        // Calculate the remaining days and time
        let currentDate = Date()
        let remainingTime = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: eventDate)
        
        if let days = remainingTime.day, let hours = remainingTime.hour, let minutes = remainingTime.minute {
            if days > 0 || hours > 0 || minutes > 0 {
                cell.remainingTimeLbl.text = "Remaining Time is:\(days) days, \(hours) hours, \(minutes) minutes left"
            } else {
                cell.remainingTimeLbl.text = "Event Passed"
            }
        }

        // Schedule notification one hour before the event
       scheduleNotification(for: EventData.Tittle, eventDate: eventDate)
        
        return cell
    }
    // Schedule notification one hour before the event date
    private func scheduleNotification(for eventName: String, eventDate: Date) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Event Reminder"
        notificationContent.body = "Reminder for your event: \(eventName) is in one hour!"
        notificationContent.sound = UNNotificationSound.default

        // Calculate the trigger time, which is one hour before the event
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            events_Detail.remove(at: indexPath.row)
            
            let encoder = JSONEncoder()
            do {
                let encodedData = try events_Detail.map { try encoder.encode($0) }
                UserDefaults.standard.set(encodedData, forKey: "EventDetails")
            } catch {
                print("Error encoding medications: \(error.localizedDescription)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let EventData = events_Detail[indexPath.row]
      

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as?                      DetailViewController {
            newViewController.selectedOrderDetail = EventData
            
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
            
        }
        
    }
 }


