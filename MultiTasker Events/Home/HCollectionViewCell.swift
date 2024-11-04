//
//  HCollectionViewCell.swift
//  SpeakScan Voice
//
//  Created by Moin Janjua on 05/09/2024.
//

import UIKit

class HCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var Label: UILabel!
    
    @IBOutlet weak var images: UIImageView!
    
    @IBOutlet weak var cView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //     viewShadow(view: curveView)
        
        // Set up shadow properties
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            contentView.layer.shadowOpacity = 0.3
            contentView.layer.shadowRadius = 4.0
            contentView.layer.masksToBounds = false
        
        // Set background opacity
        contentView.alpha = 1.5 // Adjust opacity as needed
        
    }
}
