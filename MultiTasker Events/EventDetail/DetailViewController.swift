//
//  DetailViewController.swift
//  NameSpectrum Hub
//
//  Created by Maaz on 04/10/2024.
//

import UIKit
import AVFoundation

class DetailViewController: UIViewController {

    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var reaminTime: UILabel!
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var tittle: UILabel!
   
    var selectedOrderDetail: Events?
    var remainingTimeString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let eventsDetail = selectedOrderDetail {
            tittle.text = eventsDetail.Tittle
//            reaminTime.text = eventsDetail.
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: eventsDetail.DateAndTime)
            date.text = dateString
            location.text = eventsDetail.Location
            descriptions.text = eventsDetail.Description
          
    
        }
    }

    @IBAction func BackBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
