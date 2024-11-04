//
//  AllTransactionsVC.swift
//  DailyLedger Flow
//
//  Created by Maaz on 24/09/2024.
//

import UIKit

class AllTransactionsVC: UIViewController {

    @IBOutlet weak var TV: UITableView!
    
    var filteredDataSource = [Transaction]()
    var sections = [TransactionSection]()
    var dataSource = [Transaction]()
    var curency = String()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust the format as needed
        return formatter
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        TV.dataSource = self
        TV.delegate = self
        
        curency =  UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        // Example of applying to a UIView

         getSavedTransactions()
         calculateTotals()
      
        
    }
    func getSavedTransactions() {
        let defaults = UserDefaults.standard
        
        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                dataSource = decodedTransactions
                filteredDataSource = dataSource
                filterAndGroupTransactions()
                calculateTotals()
               TV.reloadData()
            }
        }
    }
    func updateTableViewBackground(showNoRecordsMessage: Bool) {
        if showNoRecordsMessage && filteredDataSource.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: TV.bounds.size.width, height: TV.bounds.size.height))
            noDataLabel.text = "There is no record in the database."
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            TV.backgroundView = noDataLabel
            TV.separatorStyle = .none
        } else {
            TV.backgroundView = nil
            TV.separatorStyle = .singleLine
        }
    }
    
    func filterAndGroupTransactions() {
        var groupedTransactions = [String: [Transaction]]()
        
        // Group transactions by date
        for transaction in filteredDataSource {
            let dateKey = dateFormatter.string(from: transaction.dateTime) // Convert Date to String
            
            if groupedTransactions[dateKey] == nil {
                groupedTransactions[dateKey] = [Transaction]()
            }
            groupedTransactions[dateKey]?.append(transaction)
        }
        
        // Convert the grouped transactions into an array of TransactionSection
        sections = groupedTransactions.map { TransactionSection(date: $0.key, transactions: $0.value) }
        
        // Sort sections by date in descending order (latest date first)
        sections.sort { dateFormatter.date(from: $0.date)! > dateFormatter.date(from: $1.date)! }
    }
    func calculateTotals() {
        let totalIncome = dataSource
            .filter { $0.type == "Income" }
            .reduce(0.0) { $0 + (Double($1.amount) ?? 0.0) }
        
        let totalExpense = dataSource
            .filter { $0.type == "Expense" }
            .reduce(0.0) { $0 + (Double($1.amount) ?? 0.0) }
        
        let totalBalance = totalIncome - totalExpense
        UserDefaults.standard.setValue(totalBalance, forKey: "TotalExpense")
        
    }
    func saveTransactionsToUserDefaults() {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(dataSource) {
            defaults.set(encoded, forKey: "transactions")
        }
    }
    // Function to create PDF from table view data
    func createPDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "All Transactions",
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
    @IBAction func pdeGenerator(_ sender: Any) {
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
    @IBAction func AllRecordBtn(_ sender: UIButton) {
          filteredDataSource = dataSource
             filterAndGroupTransactions()
             updateTableViewBackground(showNoRecordsMessage: false) // Don't show message for All records
             TV.reloadData()
      }

      @IBAction func IncomeBtn(_ sender: UIButton) {
          filteredDataSource = dataSource.filter { $0.type == "Income" }
             filterAndGroupTransactions()
             updateTableViewBackground(showNoRecordsMessage: false) // Don't show message for Income records
             TV.reloadData()
      }

      @IBAction func ExpenseBtn(_ sender: UIButton) {
          filteredDataSource = dataSource.filter { $0.type == "Expense" }
            filterAndGroupTransactions()
            updateTableViewBackground(showNoRecordsMessage: true) // Show message if no Expense records
            TV.reloadData()
      }
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
}
extension AllTransactionsVC:UICollectionViewDelegate , UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DailyExpenseTableViewCell
        let transaction = sections[indexPath.section].transactions[indexPath.row] // Correctly access the transaction

        cell.titleLb.text = transaction.title
        cell.amuntLb.text = "\(curency) \(transaction.amount)"
        cell.optionLb.text = transaction.reason

        if transaction.type == "Income" {
            cell.img.image = UIImage(named: "Incomes")
            cell.arrowImg.image = UIImage(named: "-down")
          
        } else {
            cell.img.image = UIImage(named: "Expenses")
            cell.arrowImg.image = UIImage(named: "up-")
           
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "#424242")
        
        let dateLabel = UILabel()
        dateLabel.text = "Date: \(sections[section].date)" // Use the date from the section
        dateLabel.textColor = .white
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dateLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40)
        
        headerView.addSubview(dateLabel)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the section and row to remove
            let sectionIndex = indexPath.section
            let transactionToRemove = sections[sectionIndex].transactions[indexPath.row]
            
            // Remove the transaction from the filteredDataSource and sections
            if let filteredIndex = filteredDataSource.firstIndex(of: transactionToRemove) {
                filteredDataSource.remove(at: filteredIndex)
            }
            
            sections[sectionIndex].transactions.remove(at: indexPath.row)
            
            // If the section is empty, remove it
            if sections[sectionIndex].transactions.isEmpty {
                sections.remove(at: sectionIndex)
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

            // Also remove it from the main data source
            if let index = dataSource.firstIndex(of: transactionToRemove) {
                dataSource.remove(at: index)
            }
            
            // Update UserDefaults
            saveTransactionsToUserDefaults()
            
            // Recalculate totals
            calculateTotals()
        }
    }


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}




//for order in dataSource {
//    let orderText = """
//    Tittle: \(order.title)
//    Amount: \(order.amount)
//    Type: \(order.type)
//    Reason: \(order.reason)
//     Date: \(order.dateTime)
//     Budget: \(order.budget)
