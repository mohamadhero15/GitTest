//  Created by Sina MNouri on 2/25/19.
//  Copyright © 2019 Amin. All rights reserved.

import UIKit
import Alamofire

class Util {
    
    static let defaults = UserDefaults.standard
    
    static func createVC(storyBoard:String,viewControllerID:String) -> UIViewController {
        let filterStoryboard = UIStoryboard(name: storyBoard, bundle: nil)
        let filtersTableVC = filterStoryboard.instantiateViewController(withIdentifier: viewControllerID)
        return filtersTableVC
    }
    
    static func present(storyboard: String, viewControllerID: String, viewController: UIViewController, animated: Bool = true) {
        let vc = createVC(storyBoard: storyboard, viewControllerID: viewControllerID)
        viewController.present(vc, animated: animated, completion: nil)
    }
    
    static func alertAction(parent:UIViewController,title:String ,message:String, actions:[String:( (UIAlertAction)->() ) ]){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        for (actionTitle,actionFunc) in actions{
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionFunc))
        }
        alert.setValue(NSAttributedString(string: title,
                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "6E7688"),
                                                       NSAttributedString.Key.font: UIFont(name: "IRANSansMobileFaNum",
                                                                                           size: 16.0)!]),
                       forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: message,
                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "6E7688"),
                                                       NSAttributedString.Key.font: UIFont(name: "IRANSansMobileFaNum-Medium", size: 14.0)!]),
                       forKey: "attributedMessage")
        parent.present(alert, animated: true, completion: nil)
    }
    
    static func alert(parent:UIViewController,
                      title:String,
                      message:String,
                      handler:((UIAlertAction) -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "متوجه شدم", style: UIAlertAction.Style.default, handler: handler))
        parent.present(alert, animated: true, completion: nil)
    }
    
    static func putBool(key: String, bool: Bool) {
        defaults.set(bool, forKey: key)
    }
    
    static func putInt(key: String, int: Int) {
        defaults.set(int, forKey: key)
    }
    
    static func putString(key: String, string: String) {
        defaults.set(string, forKey: key)
    }
    
    static func getBool(key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    static func getInt(key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    static func getString(key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    static func alert(title:String, message:String, buttonTitle:String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func setDatePicker (_ target: Any?, forTextfield: UITextField, handler: Selector) {
        let datePickerView = UIDatePicker()
        datePickerView.addTarget (target, action: handler, for: .valueChanged)
        datePickerView.datePickerMode = .date
        datePickerView.calendar = Calendar (identifier: .persian)
        datePickerView.locale = NSLocale (localeIdentifier: "fa_IR") as Locale
        forTextfield.inputView = datePickerView
        //forTextfield.keyboardToolbar.isHidden = true
    }
    
    func attachVC (childVC: UIViewController,to parentVC: UIViewController, parentView:UIView) {
        parentVC.addChild (childVC)
        childVC.view.frame = CGRect (origin: .zero,
                                     size: parentView.frame.size)
        parentView.addSubview (childVC.view)
        childVC.didMove (toParent: parentVC)
    }
    
    func readContentFile (fileName: String, fileType: String) -> String {
        var content: String = "nil"
        let bundle = Bundle.main
        let path = bundle.path (forResource: fileName, ofType: fileType)
        do {
            content = try String.init (contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {}
        return content
    }
    
    func duration (d: Int) -> String {
        if d <= 60 {
            return "\(d) ثانیه"
        } else {
            return "\(d/60) دقیقه"
        }
    }
    
    func getPersianDate (gerogorianDateString: String) -> String {
        var dateString = gerogorianDateString
        if dateString.count > 10 {
            dateString = String (dateString.dropLast (dateString.count - 10))
        }
        let formatter = DateFormatter ()
        formatter.dateFormat = "yyyy-MM-dd"
        let gerogorianDate = formatter.date (from: dateString)
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.calendar = Calendar (identifier: .persian)
        if let date = gerogorianDate
        { return formatter.string (from: date) }
        return ""
    }
    
    func showAlert (parent: UIViewController,
                    title: String,
                    message: String,
                    handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alert = UIAlertController (title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction (UIAlertAction (title: "متوجه شدم", style: UIAlertAction.Style.default, handler: handler))
        parent.present (alert, animated: true, completion: nil)
    }
    
    func calculateAge (birthdayDate: String) -> String {
        var dateString = birthdayDate
        if dateString.count > 10 {
            dateString = String (dateString.dropLast (dateString.count - 10))
        }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthday: Date = dateFormatter.date (from:dateString)!
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents ([.year], from: birthday, to: now)
        let age = ageComponents.year!
        return age.description
    }
}
