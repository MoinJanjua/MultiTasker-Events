//
//  SavedViewController.swift
//  MultiTasker Events
//
//  Created by Maaz on 25/10/2024.
//

import UIKit
import PDFKit

class SavedViewController: UIViewController {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var translation_Detail: [VoiceRecognization] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        TableView.dataSource = self
        TableView.delegate = self
        noDataLabel.text = "There is no data available, first you need to translation of yoy speech" // Set the message

    }
    override func viewWillAppear(_ animated: Bool) {
        // Load data from UserDefaults
        // Retrieve stored medication records from UserDefaults
        if let savedData = UserDefaults.standard.array(forKey: "voiceRecognizationDetails") as? [Data] {
            let decoder = JSONDecoder()
            translation_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(VoiceRecognization.self, from: data)
                    return order
                } catch {
                    print("Error decoding medication: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        noDataLabel.text = "There Is No Event Available, Please Add Your Events First" // Set the message
        // Show or hide the table view and label based on data availability
               if translation_Detail.isEmpty {
                   TableView.isHidden = true
                   noDataLabel.isHidden = false  // Show the label when there's no data
               } else {
                   TableView.isHidden = false
                   noDataLabel.isHidden = true   // Hide the label when data is available
               }
     TableView.reloadData()
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    private func clearUserData() {
        // Remove keys related to user data but not login information
        UserDefaults.standard.removeObject(forKey: "voiceRecognizationDetails")
        

 }

    private func showResetConfirmation() {
        let confirmationAlert = UIAlertController(title: "Reset Complete", message: "The data has been reset successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        confirmationAlert.addAction(okAction)
        self.present(confirmationAlert, animated: true, completion: nil)
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
            for order in translation_Detail {
                let orderText = """
                Product: \(order.Tittle)
                User: \(order.VoiceDescription)
                Date: \(order.DateofSave)
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
    @IBAction func ClearAllSalesButton(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Events", message: "Are you sure you want to remove all your events?", preferredStyle: .alert)
          
          let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
              // Step 1: Clear user-specific data from UserDefaults
              self.clearUserData()
              
              // Step 2: Clear the data source (order_Detail array)
              self.translation_Detail.removeAll()
              
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
extension SavedViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return translation_Detail.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saveCell", for: indexPath) as! SavedTableViewCell
        
        let item = translation_Detail[indexPath.row]
        cell.titleNameLbl?.text = item.Tittle // Customize the display
        
        cell.dateLbl.text = item.DateofSave
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            translation_Detail.remove(at: indexPath.row)
            
            let encoder = JSONEncoder()
            do {
                let encodedData = try translation_Detail.map { try encoder.encode($0) }
                UserDefaults.standard.set(encodedData, forKey: "voiceRecognizationDetails")
            } catch {
                print("Error encoding medications: \(error.localizedDescription)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = translation_Detail[indexPath.row]
    
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyBoard.instantiateViewController(withIdentifier: "VoiceToTextViewController") as?                      VoiceToTextViewController {
            newViewController.selectedTranslation = selectedItem // Pass the selected translation
            newViewController.selectedIndex = indexPath.row // Pass the index for updating
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
            
            
        }
        
    }
    
}
