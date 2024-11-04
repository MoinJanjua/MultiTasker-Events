//
//  CurrencyViewController.swift
//  MoneyMinder
//
//  Created by Unique Consulting Firm on 17/03/2024.
//

import UIKit

class CurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
       
    var selectedCurrencyIndex: Int?
    let currencyList = [
        ("$", "Dollar"),
        ("PKR", "Pak Rupees"),
        ("€", "Euro"),
        ("£", "Pound"),
        ("¥", "Yen"),
        ("₣", "Franc"),
        ("₽", "Ruble"),
        ("₹", "Rupee"),
        ("₱", "Peso"),
        ("₩", "Won"),
        ("฿", "Baht"),
        ("₫", "Dong"),
        ("₴", "Hryvnia"),
        ("₭", "Kip"),
        ("₮", "Tugrik"),
        ("₦", "Naira"),
        ("₸", "Tenge"),
        ("₲", "Guarani"),
        ("₺", "Lira"),
        ("₼", "Manat"),
        ("₡", "Colon"),
        ("₵", "Cedi"),
        ("¢", "Cent"),
        ("₥", "Mill"),
        ("₰", "Pfennig"),
        ("₤", "Lira"),
        ("₪", "Shekel"),
        ("₯", "Drachma"),
        ("₠", "Euro"),
        ("₢", "Cruzeiro"),
        ("₧", "Peseta"),
        ("₨", "Rupee"),
        ("₩", "Won"),
        ("₪", "New Shekel"),
        ("₫", "Dong"),
        ("₭", "Kip"),
        ("₮", "Tugrik"),
        ("₯", "Drachma"),
        ("₰", "Pfennig"),
        ("₳", "Austral"),
        ("₴", "Hryvnia"),
        ("₹", "Rupee"),
        ("₽", "Ruble"),
        ("₾", "Lari"),
        ("₼", "Manat"),
        ("₿", "Bitcoin")
    ]
       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.delegate = self
           tableView.dataSource = self
           let index =  UserDefaults.standard.value(forKey: "selectedIndex") as? Int ?? 0
            selectedCurrencyIndex = index
       }
    
    
    @objc func saveButtonTapped() {
        guard let selectedCurrencyIndex = selectedCurrencyIndex else {
            print("No currency selected.")
            return
        }

        let currencySymbol = currencyList[selectedCurrencyIndex].0
        UserDefaults.standard.set(currencySymbol, forKey: "currencyISoCode")
        UserDefaults.standard.set(selectedCurrencyIndex, forKey: "selectedIndex")
        self.dismiss(animated: true)

        // You can add any additional actions you want to perform after saving
    }
    
    @IBAction func savebtnPressed(_ sender:UIButton)
    {
        saveButtonTapped()
    }
    
    @IBAction func backbtnPressed(_ sender:UIButton)
    {
        self.dismiss(animated: true)
    }
       
       // MARK: - UITableView DataSource Methods
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return currencyList.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CurencyTableViewCell
           
           let currencyName = currencyList[indexPath.row].1
           let currencysign = currencyList[indexPath.row].0
           cell.CRlbl.text = "\(currencyName) \(currencysign)"
           if let selectedCurrencyIndex = selectedCurrencyIndex, selectedCurrencyIndex == indexPath.row {
               cell.SelectedIconimg.image = UIImage(named: "check")
           } else {
               cell.SelectedIconimg.image = UIImage(named: "uncheck")
           }
           
           return cell
       }
       
       // MARK: - UITableView Delegate Methods
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

           selectedCurrencyIndex = indexPath.row
           tableView.reloadData()
       }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
   }
