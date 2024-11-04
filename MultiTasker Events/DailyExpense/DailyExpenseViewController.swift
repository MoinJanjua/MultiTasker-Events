
import UIKit
import Charts

class DailyExpenseViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var Userimg: UIImageView!
    @IBOutlet weak var Usernamelbl: UILabel!
    @IBOutlet weak var TotalBalncelbl: UILabel!
    @IBOutlet weak var Incomelbl: UILabel!
    @IBOutlet weak var IncomeAmountlbl: UILabel!
    @IBOutlet weak var Expenselbl: UILabel!
    @IBOutlet weak var ExpenseAmountlbl: UILabel!
    @IBOutlet weak var Allbtn: UIButton!
    @IBOutlet weak var Incomebtn: UIButton!
    @IBOutlet weak var Expense: UIButton!
    @IBOutlet weak var TbalanceView: UIView!
    @IBOutlet weak var IncomeView: UIView!
    @IBOutlet weak var ExpenseView: UIView!
    @IBOutlet weak var TotalBudget: UILabel!
    @IBOutlet weak var Curencybtn: UIButton!
    @IBOutlet weak var TotalBudgetlbl: UILabel!
    @IBOutlet weak var TotalBudgetV: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!


    
    var curency = String()
    var tbugde = String()
    var dataSource = [Transaction]()
    var filteredDataSource = [Transaction]() // For filtered transactions based on Income/Expense/All
    var sections = [TransactionSection]()

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust the format as needed
        return formatter
    }()
    
    var transactions: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curveTopCorners(of: mainView, radius: 35)
        roundCorner(button: createButton)
        
        // Do any additional setup after loading the view.
    //    loadData()
        getSavedTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        curency =  UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        tbugde =  UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? ""
  
        addDropShadow(to:TbalanceView)
        addDropShadow(to:IncomeView)
        addDropShadow(to:ExpenseView)
     
         calculateTotals()
        loadSavedBudget()
        
        setPieChartData()
       // loadData()
        getSavedTransactions()
        
        
        print("Data Source Count: \(dataSource.count)")
    }
    
    func saveTransactionsToUserDefaults() {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(dataSource) {
            defaults.set(encoded, forKey: "transactions")
        }
    }
    func curveTopCorners(of view: UIView, radius: CGFloat) {
           let path = UIBezierPath(roundedRect: view.bounds,
                                   byRoundingCorners: [.bottomLeft, .bottomRight],
                                   cornerRadii: CGSize(width: radius, height: radius))
           
           let mask = CAShapeLayer()
           mask.path = path.cgPath
           view.layer.mask = mask
       }
    
    func getSavedTransactions() {
        let defaults = UserDefaults.standard

        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                dataSource = decodedTransactions
                filteredDataSource = dataSource
                filterAndGroupTransactions() // Ensure filtered transactions are grouped by date
                calculateTotals() // Recalculate totals after fetching transactions
            }
        } else {
            // If no transactions are found, clear the chart and reset data
            dataSource = []
            filteredDataSource = []
            pieChartView.data = nil
            pieChartView.notifyDataSetChanged() // Update the chart with no data
        }

        setPieChartData() // Always call to set data on the pie chart
    }
  
//    func loadData() {
//        
//           if let savedTransactions = UserDefaults.standard.object(forKey: "transactions") as? Data {
//               if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
//                   transactions = decodedTransactions
//               }
//           }
//
//           // Reload the pie chart with transaction data
//           setPieChartData()
//       }
    func setPieChartData() {
           var entries = [PieChartDataEntry]()

           // Convert transactions into PieChartDataEntry
           for transaction in dataSource {
               let amount = Double(transaction.amount) ?? 0.0
               let label = transaction.reason // Reason as label for the pie chart
               entries.append(PieChartDataEntry(value: amount, label: label))
           }

           // Check if there are transactions
           guard !entries.isEmpty else {
               // If no data, handle it (e.g., show no records label or clear chart)
               pieChartView.data = nil
               return
           }

           // Create PieChartDataSet
           let dataSet = PieChartDataSet(entries: entries, label: "Transactions")
           dataSet.colors = ChartColorTemplates.material()

           // Set pie chart data
           let data = PieChartData(dataSet: dataSet)
           pieChartView.data = data

           // Customize pie chart appearance (optional)
           pieChartView.centerText = "Expenses Chart"
           pieChartView.holeRadiusPercent = 0.4
           pieChartView.chartDescription.enabled = false
           pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
           pieChartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeInOutQuad)
           pieChartView.legend.enabled = true
           pieChartView.legend.orientation = .vertical
           pieChartView.legend.horizontalAlignment = .right
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

    func loadSavedBudget() {
        let defaults = UserDefaults.standard
        if let savedBudget = defaults.string(forKey: "lastBudget") {
            TotalBudgetlbl.text = "\(curency) \(savedBudget)"
            
        }
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
        
        IncomeAmountlbl.text = String(format: "\(curency) %.2f", totalIncome)
        ExpenseAmountlbl.text = String(format: "\(curency) %.2f", totalExpense)
        TotalBalncelbl.text = String(format: "\(curency) %.2f", totalBalance)
       // TotalBudgetlbl.text = String(format: "\(curency) %.2f", totalBudget)
    }

    @IBAction func AllTransactionButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "AllTransactionsVC") as! AllTransactionsVC
       // self.tabBarController?.selectedIndex = 3
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
  
    @IBAction func Curencybtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func createButton(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CreatingRecordsViewController") as! CreatingRecordsViewController
        newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    @IBAction func BackBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

