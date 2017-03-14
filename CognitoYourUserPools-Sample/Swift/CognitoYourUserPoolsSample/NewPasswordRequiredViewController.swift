//
//  NewPasswordRequiredViewController.swift
//  CognitoYourUserPoolsSample
//
//  Created by bhind on 2017/03/13.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class NewPasswordRequiredViewController : UIViewController, UITextFieldDelegate, AWSCognitoIdentityNewPasswordRequired {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!

    var passwordRequiredCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>? = nil

    // UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phone.delegate = self
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField == self.phone) {
            do {
                let regex:NSRegularExpression = try NSRegularExpression(pattern: "^\\+(|\\d)*$", options: NSRegularExpression.Options());
                let nsString:NSString? = self.phone.text as NSString?
                if(nsString?.length != 0) {
                    return regex.numberOfMatches(in: nsString as! String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: (nsString?.length)!)) == 1;
                }
            } catch _ as NSError {
                // TODO
                return false
            }
        }
        return true;
    }

    func getNewPasswordDetails(_ newPasswordRequiredInput: AWSCognitoIdentityNewPasswordRequiredInput, newPasswordRequiredCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>) {
        self.passwordRequiredCompletionSource = newPasswordRequiredCompletionSource
        DispatchQueue.main.async {
            if(self.phone != nil) { self.phone.text = newPasswordRequiredInput.userAttributes["phone_number"] }
            if(self.email != nil) { self.email.text = newPasswordRequiredInput.userAttributes["email"] }
        }
    }
    
    func didCompleteNewPasswordStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if((error) != nil) {
                let nsError: NSError = error as! NSError
                let alert: UIAlertController = UIAlertController(title: nsError.userInfo["__type"] as! String?, message: nsError.userInfo["message"] as! String?, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction!) -> Void in
                    // TODO
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func completeProfile(_ sender: UIButton) {
        let userAttributes: Dictionary = [ "email": self.email.text, "phone_number": self.phone.text ] as [String : String?]
        let details: AWSCognitoIdentityNewPasswordRequiredDetails = AWSCognitoIdentityNewPasswordRequiredDetails(proposedPassword: self.password.text!, userAttributes: userAttributes as! [String : String])
        self.passwordRequiredCompletionSource?.set(result: details);
    }
}
