
import Foundation
import UIKit

@IBDesignable extension UIButton {
    func applyCornerRadiusAndShadowbutton(cornerRadius: CGFloat = 12, shadowColor: UIColor = .white, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowOpacity: Float = 0.3, shadowRadius: CGFloat = 4.0, backgroundAlpha: CGFloat = 1.0) {
         
         // Set corner radius
         self.layer.cornerRadius = cornerRadius
         
         // Set up shadow properties
         self.layer.shadowColor = shadowColor.cgColor
         self.layer.shadowOffset = shadowOffset
         self.layer.shadowOpacity = shadowOpacity
         self.layer.shadowRadius = shadowRadius
         self.layer.masksToBounds = false

         // Set background opacity
         self.alpha = backgroundAlpha
     }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UILabel {

    @IBInspectable var borderWidth2: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius2: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor2: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable extension UIView {
    func applyCornerRadiusAndShadow(cornerRadius: CGFloat = 12, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowOpacity: Float = 0.3, shadowRadius: CGFloat = 4.0, backgroundAlpha: CGFloat = 1.0) {
         
         // Set corner radius
         self.layer.cornerRadius = cornerRadius
         
         // Set up shadow properties
         self.layer.shadowColor = shadowColor.cgColor
         self.layer.shadowOffset = shadowOffset
         self.layer.shadowOpacity = shadowOpacity
         self.layer.shadowRadius = shadowRadius
         self.layer.masksToBounds = false

         // Set background opacity
         self.alpha = backgroundAlpha
     }
    
    @IBInspectable var borderWidth1: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius1: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor1: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
@IBDesignable extension UIImageView {
    
    func addBottomCurve(curveHeight: CGFloat = 50) {
         // Define the size of the image view
         let imageViewBounds = self.bounds
         
         // Create a bezier path with a curved bottom
         let path = UIBezierPath()
         path.move(to: CGPoint(x: 0, y: 0))
         path.addLine(to: CGPoint(x: imageViewBounds.width, y: 0))
         path.addLine(to: CGPoint(x: imageViewBounds.width, y: imageViewBounds.height - curveHeight)) // Adjust height for curve
         path.addQuadCurve(to: CGPoint(x: 0, y: imageViewBounds.height - curveHeight), controlPoint: CGPoint(x: imageViewBounds.width / 2, y: imageViewBounds.height)) // Control point for curve
         path.close()
         
         // Create a shape layer mask
         let maskLayer = CAShapeLayer()
         maskLayer.path = path.cgPath
         
         // Apply the mask to the imageView
         self.layer.mask = maskLayer
     }
}
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        if hexString.count != 6 {
            self.init(white: 1.0, alpha: 0.0) // Return a clear color if invalid
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

func roundCorner(button:UIButton)
{
    button.layer.cornerRadius = button.frame.size.height/2
    button.clipsToBounds = true
}

func roundCorneView(view:UIView)
{
    view.layer.cornerRadius = view.frame.size.height/2
    view.clipsToBounds = true
}

func roundCorneLabel(label:UILabel)
{
    label.layer.cornerRadius = label.frame.size.height/2
    label.clipsToBounds = true
}
func applyCornerRadiusToBottomCorners(view: UIView, cornerRadius: CGFloat) {
     // Create a bezier path with rounded corners at bottom-left and bottom-right
     let path = UIBezierPath(roundedRect: view.bounds,
                             byRoundingCorners: [.bottomLeft, .bottomRight],
                             cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
     
     // Create a shape layer with the bezier path
     let maskLayer = CAShapeLayer()
     maskLayer.path = path.cgPath
     
     // Set the shape layer as the mask for the view
     view.layer.mask = maskLayer
 }
extension UIViewController
{
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
//    func showToast(message: String, font: UIFont) {
//           let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75,
//                                                  y: self.view.frame.size.height-100,
//                                                  width: 150,
//                                                  height: 35))
//           toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//           toastLabel.textColor = UIColor.white
//           toastLabel.textAlignment = .center
//           toastLabel.font = font
//           toastLabel.text = message
//           toastLabel.alpha = 1.0
//           toastLabel.layer.cornerRadius = 10
//           toastLabel.clipsToBounds = true
//           self.view.addSubview(toastLabel)
//           
//           UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
//               toastLabel.alpha = 0.0
//           }, completion: { (isCompleted) in
//               toastLabel.removeFromSuperview()
//           })
//       }
    
    func setupDatePicker(for textField: UITextField, target: Any, doneAction: Selector) {
        // Initialize the date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date // Change to .dateAndTime if needed
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        } // Optional: Choose style
        
        // Set the date picker as the input view for the text field
        textField.inputView = datePicker
        
        // Create a toolbar with a done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: doneAction)
        toolbar.setItems([doneButton], animated: true)
        
        // Set the toolbar as the input accessory view for the text field
        textField.inputAccessoryView = toolbar
    }
    
    
}
func curveTopLeftCornersforView(of view: UIView, radius: CGFloat) {
       let path = UIBezierPath(roundedRect: view.bounds,
                               byRoundingCorners: [.topRight],
                               cornerRadii: CGSize(width: radius, height: radius))
       
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       view.layer.mask = mask
   }
func curveTopCornersDown(of view: UIView, radius: CGFloat) {
       let path = UIBezierPath(roundedRect: view.bounds,
                               byRoundingCorners: [.topLeft, .topRight],
                               cornerRadii: CGSize(width: radius, height: radius))
       
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       view.layer.mask = mask
   }

func addDropShadowButtonOne(to button: UIButton) {
    button.layer.shadowColor = UIColor.white.cgColor   // Shadow color
    button.layer.shadowOpacity = 0.5                   // Shadow opacity (0 to 1, where 1 is completely opaque)
    button.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset (width = horizontal, height = vertical)
    button.layer.shadowRadius = 4                      // Shadow blur radius
    button.layer.masksToBounds = false                 // Ensure shadow appears outside the view bounds
}
func addDropShadow(to view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor   // Shadow color
    view.layer.shadowOpacity = 0.5                   // Shadow opacity (0 to 1, where 1 is completely opaque)
    view.layer.shadowOffset = CGSize(width: 0, height: 2) // Shadow offset (width = horizontal, height = vertical)
    view.layer.shadowRadius = 4                      // Shadow blur radius
    view.layer.masksToBounds = false                 // Ensure shadow appears outside the view bounds
}

struct Transaction: Codable,Equatable {
    var title: String
    var amount: String
    var type: String // "Income" or "Expense"
    var reason: String
    var dateTime: Date
    var budget:String
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
           return lhs.amount == rhs.amount &&
               lhs.type == rhs.type &&
                lhs.title == rhs.title &&
               lhs.reason == rhs.reason &&
               lhs.dateTime == rhs.dateTime &&
               lhs.budget == rhs.budget
       }
}

struct TransactionSection {
    let date: String
    var transactions: [Transaction]
}


var currency = ""


func formatAmount(_ amount: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    
    // Convert amount to a number
    if let number = formatter.number(from: amount) {
        return formatter.string(from: number) ?? amount
    } else {
        // If conversion fails, assume there's no dot and add two zeros after it
        let amountWithDot = amount + ".00"
        return formatter.string(from: formatter.number(from: amountWithDot)!) ?? amountWithDot
    }
}

struct Events:Codable {
    
    let Tittle : String
    let DateAndTime: Date
    let Location : String?
    let Description: String?

}
struct Country {
    let name: String
    let flag: String
    let code: String
}
struct VoiceRecognization:Codable  {
    let VoiceDescription: String
    let Tittle: String
    let DateofSave: String
 
}
