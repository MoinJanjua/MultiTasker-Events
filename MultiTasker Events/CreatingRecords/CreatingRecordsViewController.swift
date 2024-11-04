//
//  CreatingRecordsViewController.swift
//  DailyExpense
//
//  Created by UCF on 19/08/2024.
//

import UIKit

class CreatingRecordsViewController: UIViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var optionDD:DropDown!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBOutlet weak var monthlyBudgetTF: UITextField!
    @IBOutlet weak var incomebtn: UIButton!
    @IBOutlet weak var expensebtn: UIButton!
    @IBOutlet weak var Currencybtn: UIButton!
    
    var radioButtonTap = String()
    //circle.fill
    override func viewDidLoad() {
        super.viewDidLoad()
        radioButtonTap = "Income"
        optionDD.optionArray = [
            "Salary", "Freelance", "Rent", "Utilities", "Groceries",
            "Transportation", "Dining Out", "Entertainment", "Insurance",
            "Healthcare", "Clothing", "Education", "Loans", "Investments",
            "Savings", "Gifts", "Charity", "Subscriptions", "Memberships",
            "Travel", "Home Maintenance", "Childcare", "Pet Care",
            "Internet", "Phone", "Gym", "Hobbies", "Office Supplies",
            "Taxes", "Miscellaneous"
        ]
        
        incomebtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                tapGesture.cancelsTouchesInView = false
                view.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadSavedBudget()


    }
    @objc func hideKeyboard()
      {
          view.endEditing(true)
      }
    func loadSavedBudget() {
        let defaults = UserDefaults.standard
        if let savedBudget = defaults.string(forKey: "lastBudget") {
            monthlyBudgetTF.text = savedBudget
            
        }
    }
    @IBAction func IncomeButtonTapped(_ sender: UIButton)
    {
        radioButtonTap = "Income"
        incomebtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        expensebtn.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    @IBAction func ExpenseButtonTapped(_ sender: UIButton)
    {
        radioButtonTap = "Expense"
        expensebtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        incomebtn.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        // Validate all required fields
        guard let title = titleTF.text, !title.isEmpty else {
            showAlert(title: "Error!", message: "Please enter a title")
            return
        }
        
        guard let amount = amountTF.text, !amount.isEmpty else {
            showAlert(title: "Error!", message: "Please enter an amount")
            return
        }
        
        guard let reason = optionDD.text, !reason.isEmpty else {
            showAlert(title: "Error!", message: "Please select a reason")
            return
        }
        
        let selectedDate = dateTime.date
        let budget = monthlyBudgetTF.text ?? ""

    
        // Create a Transaction object
        let transaction = Transaction(title: title,
                                      amount: amount,
                                      type: radioButtonTap,
                                      reason: reason,
                                      dateTime: selectedDate,
                                      budget: budget)
        
        // Save to UserDefaults
        saveTransaction(transaction)
        saveLastBudget(budget)
        showAlert(title: "Success!", message: "Your record has been saved!")
        // Optionally, clear fields or navigate to another screen
        clearFields()
    }
    func saveLastBudget(_ budget: String) {
        let defaults = UserDefaults.standard
        defaults.set(budget, forKey: "lastBudget")
    }
    // Function to save transaction to UserDefaults
    func saveTransaction(_ transaction: Transaction) {
        let defaults = UserDefaults.standard
        
        // Retrieve existing transactions from UserDefaults
        var transactions = getSavedTransactions()
        
        // Append the new transaction
        transactions.append(transaction)
        
        // Save the updated array back to UserDefaults
        if let encoded = try? JSONEncoder().encode(transactions) {
            defaults.set(encoded, forKey: "transactions")
        }
    }

    // Function to retrieve saved transactions from UserDefaults
    func getSavedTransactions() -> [Transaction] {
        let defaults = UserDefaults.standard
        
        if let savedTransactions = defaults.object(forKey: "transactions") as? Data {
            if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactions) {
                return decodedTransactions
            }
        }
        return []
    }

    // Optional: Function to clear fields after submission
    func clearFields() {
        titleTF.text = ""
        amountTF.text = ""
        optionDD.text = ""
       
        radioButtonTap = "Income"
    }

    @IBAction func Currencybtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
}
