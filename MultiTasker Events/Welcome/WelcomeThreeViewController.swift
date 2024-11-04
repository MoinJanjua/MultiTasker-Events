//
//  WelcomeThreeViewController.swift
//  NameSpectrum Hub
//
//  Created by Maaz on 03/10/2024.
//

import UIKit

class WelcomeThreeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    @IBAction func startButton(_ sender: Any) {
        
               let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
               let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
               newViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
               newViewController.modalTransitionStyle = .crossDissolve
               self.present(newViewController, animated: true, completion: nil)
    }
    @IBAction func previousButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
