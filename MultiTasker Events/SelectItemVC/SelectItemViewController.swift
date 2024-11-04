//
//  SelectItemViewController.swift
//  DailyExpense
//
//  Created by UCF on 16/08/2024.
//
import UIKit

class SelectItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var SelectItemDropDown: DropDown!
    @IBOutlet weak var Currencyimage: UIImageView!
    
    @IBOutlet weak var currencyBtn: UIButton!
    
    var currency = String()
    var dataSource = [Transaction]()
    var selectedItem = String()
    var filteredDataSource = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        
        // Dropdown setup
        SelectItemDropDown.optionArray = ["All", "Salary", "Freelance", "Rent", "Utilities", "Groceries", "Transportation", "Dining Out", "Entertainment", "Insurance", "Healthcare", "Clothing", "Education", "Loans", "Investments", "Savings", "Gifts", "Charity", "Subscriptions", "Memberships", "Travel", "Home Maintenance", "Childcare", "Pet Care", "Internet", "Phone", "Gym", "Hobbies", "Office Supplies", "Taxes", "Miscellaneous"]
        
        SelectItemDropDown.didSelect { [self] (selectedText, index, id) in
            self.SelectItemDropDown.text = selectedText
            self.selectedItem = selectedText
            
            // Load and filter transactions based on the selection
            loadTransactions()
        }
        
        getSavedTransactions()
    }
    
    // Method to retrieve saved transactions
    func getSavedTransactions() {
        let defaults = UserDefaults.standard
        
        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                dataSource = decodedTransactions
                filteredDataSource = dataSource
                tv.reloadData()
            }
        }
    }
    
    // Method to filter transactions based on the dropdown selection
    func loadTransactions() {
        let defaults = UserDefaults.standard
        
        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                dataSource = decodedTransactions
                
                // Filter transactions
                if selectedItem == "All" {
                    filteredDataSource = dataSource
                } else {
                    filteredDataSource = dataSource.filter { $0.reason == selectedItem }
                }
                
                // Update table view
                tv.reloadData()
                updateTableViewBackground(showNoRecordsMessage: filteredDataSource.isEmpty)
            }
        }
    }
    
    // Method to show "No data available" if no filtered transactions are present
    func updateTableViewBackground(showNoRecordsMessage: Bool) {
        if showNoRecordsMessage {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tv.bounds.size.width, height: tv.bounds.size.height))
            noDataLabel.text = "There is no data available on this item"
            noDataLabel.textColor = .black
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            tv.backgroundView = noDataLabel
            tv.separatorStyle = .none
        } else {
            tv.backgroundView = nil
            tv.separatorStyle = .singleLine
        }
    }
    // Function to create PDF from table view data
    func createPDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Selected Expense Item ",
            kCGPDFContextAuthor: "MultiTasker Evevts",
            kCGPDFContextTitle: "Transaction Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // Title
            let title = "Transaction Report"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .paragraphStyle: centeredParagraphStyle()
            ]
            title.draw(in: CGRect(x: 0, y: 20, width: pageWidth, height: 30), withAttributes: titleAttributes)
            
            // Transaction data
            let bodyFont = UIFont.systemFont(ofSize: 12)
            var textYPosition: CGFloat = 60
            
            for transaction in filteredDataSource {
                let transactionText = "\(transaction.title) | \(currency)\(transaction.amount) | \(transaction.reason)"
                let textRect = CGRect(x: 20, y: textYPosition, width: pageWidth - 40, height: 20)
                transactionText.draw(in: textRect, withAttributes: [.font: bodyFont])
                
                textYPosition += 25
                if textYPosition > pageRect.height - 40 {
                    context.beginPage()
                    textYPosition = 20
                }
            }
        }
        
        return data
    }

    // Helper function for centered paragraph style
    func centeredParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
    @IBAction func pdfGenerator(_ sender: Any) {
        if filteredDataSource.isEmpty {
               // Show alert if no data is available
               let alert = UIAlertController(title: "No Data", message: "There is no data available.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               self.present(alert, animated: true, completion: nil)
           } else {
               // Generate PDF if data exists
               let pdfData = createPDFData()
               
               // Save or share PDF
               let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
               present(activityViewController, animated: true, completion: nil)
           }
    }
    
    @IBAction func BackBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func CurrencyBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show one row if no data, so that we can display the background message
        return filteredDataSource.isEmpty ? 0 : filteredDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredDataSource.isEmpty {
            // This will be handled by the background label, so no cell creation needed
            return UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DWiseTTableViewCell
            let data = filteredDataSource[indexPath.row]
            cell.titleLb.text = data.title
            cell.amuntLb.text = "\(currency) \(data.amount)"
            cell.optionLb.text = data.reason
            
            if data.type == "Income" {
                cell.img.image = UIImage(named: "Incomes")
                cell.arrowImg.image = UIImage(named: "-down")

            } else {
                cell.img.image = UIImage(named: "Expenses")
                cell.arrowImg.image = UIImage(named: "up-")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
