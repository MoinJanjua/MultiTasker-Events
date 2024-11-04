
import UIKit

class DWiseTViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Fromlbl: UILabel!
    @IBOutlet weak var Tolbl: UILabel!
    @IBOutlet weak var FromDatePicker: UIDatePicker!
    @IBOutlet weak var ToDatePicker: UIDatePicker!
    @IBOutlet weak var TableV: UITableView!
    @IBOutlet weak var SelectTypeDropD: DropDown!
    @IBOutlet weak var CurrencyBtn: UIButton!
    
    var Currency = String()
    var dataSource = [Transaction]()
    var selectedItem = "All"
    var filteredDataSource = [Transaction]()
    var dataFilterApplied = false  // Flag to check if filtering has been applied
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SelectTypeDropD.optionArray = ["All", "Income", "Expense"]
        setupDropDownSelection()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        
        // Set up the action for the date pickers
        FromDatePicker.addTarget(self, action: #selector(fromDatePickerChanged(_:)), for: .valueChanged)
        ToDatePicker.addTarget(self, action: #selector(toDatePickerChanged(_:)), for: .valueChanged)
        SelectTypeDropD.didSelect{ [self](selectedText , index ,id) in
        self.SelectTypeDropD.text = selectedText
            self.selectedItem = selectedText
            let defaults = UserDefaults.standard
            
            if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
                if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                    dataSource = decodedTransactions
                    if selectedItem == "All"
                    {
                        filteredDataSource = dataSource
                    }
                    else
                    {
                        filteredDataSource = dataSource.filter { $0.reason == selectedItem }
                    }
                   
                    TableV.reloadData()
                }
            }
        }
            filterTransactions()
        getSavedTransactions()
        filterTransactions()
    }
    
    func setupDropDownSelection() {
        // Set up the dropdown for selecting transaction type
        SelectTypeDropD.didSelect { [self](selectedText, index, id) in
            self.SelectTypeDropD.text = selectedText
            self.selectedItem = selectedText
            filterTransactions()
        }
    }

    @objc func fromDatePickerChanged(_ sender: UIDatePicker) {
        dataFilterApplied = true // The user interacted with the filter
        filterTransactions()
    }

    @objc func toDatePickerChanged(_ sender: UIDatePicker) {
        dataFilterApplied = true // The user interacted with the filter
        filterTransactions()
    }

    func getSavedTransactions() {
        let defaults = UserDefaults.standard
        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                dataSource = decodedTransactions
                filteredDataSource = dataSource
            }
        }
    }

    func filterTransactions() {
        let fromDate = FromDatePicker.date
        let toDate = ToDatePicker.date
        
        if selectedItem == "All" {
            filteredDataSource = dataSource.filter { $0.dateTime >= fromDate && $0.dateTime <= toDate }
        } else {
            filteredDataSource = dataSource.filter { $0.type == selectedItem && $0.dateTime >= fromDate && $0.dateTime <= toDate }
        }
        
        updateTableViewBackground(showNoRecordsMessage: dataFilterApplied)
        TableV.reloadData()
    }

    func updateTableViewBackground(showNoRecordsMessage: Bool) {
        if showNoRecordsMessage && filteredDataSource.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: TableV.bounds.size.width, height: TableV.bounds.size.height))
            noDataLabel.text = "No data available on select date."
            noDataLabel.textColor = .black
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 20)
            TableV.backgroundView = noDataLabel
            TableV.backgroundColor = .white
            TableV.separatorStyle = .none
        } else {
            TableV.backgroundView = nil
            TableV.separatorStyle = .singleLine
        }
    }
    // Function to create PDF from table view data
    func createPDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "DayWise Expenditure",
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
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredDataSource.isEmpty {
            return UITableViewCell() // Fallback, although with the flag this shouldn't be necessary
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DWiseTTableViewCell
            let data = filteredDataSource[indexPath.row]
            cell.titleLb.text = data.title
            cell.amuntLb.text = "\(Currency) \(data.amount)"
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
    @IBAction func Bckbtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func CurrencyBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
}
