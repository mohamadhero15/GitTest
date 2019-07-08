//
//  ViewController.swift
//  NOON
//
//  Created by mohammad mokhtarzade on 6/11/19.
//  Copyright © 2019 Satya. All rights reserved.
//

import UIKit
import BetterSegmentedControl


class ViewController: UIViewController, UITextFieldDelegate {

    @IBAction func noonPick(_ sender: Any) {
    }
    @IBOutlet weak var textOTP1: UITextField!
    @IBOutlet weak var textOTP2: UITextField!
    @IBOutlet weak var textOTP3: UITextField!
    @IBOutlet weak var textOTP4: UITextField!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textOTP1.delegate = self
        textOTP2.delegate = self
        textOTP3.delegate = self
        textOTP4.delegate = self
        
        textOTP1.becomeFirstResponder()
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1 ) && (string.count < 0){
            if textField == textOTP1{
                textOTP2.becomeFirstResponder()
            }
            if textField == textOTP2{
                textOTP3.becomeFirstResponder()
            }
            if textField == textOTP3{
                textOTP4.becomeFirstResponder()
            }
            if textField == textOTP4{
                textOTP4.resignFirstResponder()
            }
            textField.text = string
            return false
        } else if ((textField.text?.count)! >= 1 ) && (string.count == 0){
            if textField == textOTP2 {
                textOTP1.becomeFirstResponder()
            }
            if textField == textOTP3 {
                textOTP2.becomeFirstResponder()
            }
            if textField == textOTP4 {
                textOTP3.becomeFirstResponder()
            }
            if textField == textOTP1 {
                textOTP1.resignFirstResponder()
            }
            textField.text = ""
            return false
        } else if (textField.text?.count)! >= 1 {
            textField.text = string
            return false
        }
        
        return true
    }
    
    
    
   


}

