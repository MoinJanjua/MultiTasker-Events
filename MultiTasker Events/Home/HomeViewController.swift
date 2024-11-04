//
//  HomeViewController.swift
//  NameSpectrum Hub
//
//  Created by Maaz on 03/10/2024.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var MianView: UIView!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SideMenu: UIView!
    @IBOutlet weak var sideMenuTB: UITableView!
    @IBOutlet weak var vesion_Label: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!

    
    var sideMenuList = [String]()
    var sideMenuImgs = ["H","A","F","S","P"]
    var type = [String]()
    var Imgs: [UIImage] = [
        UIImage(named: "birthday-date")!,
        UIImage(named:"translation")!,
        UIImage(named: "budget")!,
        UIImage(named:"speech-recognition")!,
        UIImage(named: "conversion")!]
    
    let titleList = [
        "Regilious",
        "Trending",
        "Historical","Name & History",
        "Unique","Random"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        applyCornerRadiusToBottomCorners(view: MianView, cornerRadius: 50)

        type = ["Events Handle","Future Event History","Expenditure Manage","Future Events (Voice to Text)","Language Conversion"]
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        CollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        sideMenuList = ["Home","About Us","Share Feedback","Share App","Privacy Notice"]
        sideMenuTB.delegate = self
        sideMenuTB.dataSource = self
        SideMenu.isHidden = true
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "N/A"
        vesion_Label.text = "Version \(version) (\(build))"
        
        setGreetingMessage()
    }
    private func setGreetingMessage() {
        let hour = Calendar.current.component(.hour, from: Date())
        var greeting: String
        
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<21:
            greeting = "Good Evening"
        default:
            greeting = "Good Night"
        }
        TimeLbl.text = greeting
    }
    @IBAction func MenuButton(_ sender: Any) {
        SideMenu.isHidden = false
    }
    @IBAction func cancelButton(_ sender: Any) {
        SideMenu.isHidden = true
    }
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! SideMenuTableViewCell
        
        cell.sMenuImgs?.image = UIImage(named: sideMenuImgs[indexPath.row])
        cell.sidemenu_label.text = sideMenuList[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.item == 0 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeOneViewController") as! WelcomeOneViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        else if indexPath.item == 1 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "AboutusViewController") as! AboutusViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        else if indexPath.item == 2 {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        else if indexPath.item == 3 {
            let appID = "MultiTaskerEvents" // Replace with your actual App ID
            let appURL = URL(string: "https://apps.apple.com/app/id\(appID)")!
            let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
       else if indexPath.item == 4 {
                // Open Privacy Policy Link
                if let url = URL(string: "https://jtechapps.pages.dev/privacy") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        }
    }
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! HCollectionViewCell
    
        cell.Label.text = type[indexPath.item]
        cell.images.image? = Imgs[indexPath.item]
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacing: CGFloat = 10
        let availableWidth = collectionViewWidth - (spacing * 3)
        let width = availableWidth / 2
        return CGSize(width: width + 3, height: width + 14)
      // return CGSize(width: wallpaperCollectionView.frame.size.width , height: wallpaperCollectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5) // Adjust as needed
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0
            {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "RecordsViewController") as! RecordsViewController
                newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                newViewController.modalTransitionStyle = .crossDissolve
                self.present(newViewController, animated: true, completion: nil)
            }
        
        if indexPath.row == 1
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SavedViewController") as! SavedViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
        }
        
        if indexPath.row == 2
        {
                 let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let newViewController = storyBoard.instantiateViewController(withIdentifier: "ExpenditureViewController") as! ExpenditureViewController
                 newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                 newViewController.modalTransitionStyle = .crossDissolve
                 self.present(newViewController, animated: true, completion: nil)
        }
        
        if indexPath.row == 3
       {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "VoiceToTextViewController") as! VoiceToTextViewController
                newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                newViewController.modalTransitionStyle = .crossDissolve
                self.present(newViewController, animated: true, completion: nil)
       }
        if indexPath.row == 4
       {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "TranslationViewController") as! TranslationViewController
            newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            newViewController.modalTransitionStyle = .crossDissolve
            self.present(newViewController, animated: true, completion: nil)
            
            
               
       }
 
    }
}
