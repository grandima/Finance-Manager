//
//  SignUpViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 13.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    @IBOutlet weak var activityView: UIView!
    let httpService = HTTPService()
    let validator = Validator()

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: - Add validation
        validator.registerField(userNameTF, rules: [RequiredRule(),RegexRule(regex: "^(?=.{8,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")])
        validator.registerField(emailTF, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordTF, rules: [RequiredRule()])
        activityView.layer.cornerRadius = 10
        userNameTF.returnKeyType = .Next
        emailTF.returnKeyType = .Next
        passwordTF.returnKeyType = .Done
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userNameTF.becomeFirstResponder()
    }
}

//MARK: - Textfield Delegate methods
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;
        // Try to find next responder
        let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!

        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }

}

//MARK: - User Interaction Handlers
extension SignUpViewController {
    @IBAction func signUpButtonTapped(sender: UIButton) {
        //TODO: Validation
        //validator.validate(self)
        weak var weakActivityView = self.activityView
        weakActivityView!.hidden = false

        let username = (userNameTF.text)!
        let email = emailTF.text!
        let password = (passwordTF.text)!

        //TODO: Handle network avaliability and return codes
        let params = ["username": username, "password": password, "email": email]
        let url = HTTPService.httpbaseURL + HTTPService.httpsignUp
        //print(url)
        Alamofire.request(.POST, url, parameters: params).validate()
            .responseJSON { [unowned self] response in
                print(response.request?.URL?.absoluteString)
                switch response.result {
                case .Success:
                    let responseJSON = JSON(data: response.data!)

                    Defaults[HTTPService.udtoken] = responseJSON[HTTPService.jsonapiToken]
                    Defaults[HTTPService.udisLoggedIn] = true

                    dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                        print(NSThread.currentThread().name)
                        weakActivityView!.hidden = true
                        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                        })
                    //TODO: Handle this error
                case .Failure(let error):
                    weakActivityView!.hidden = true
                    print(error)

                }
        }
    }
    
}

//MARK: - Validation delegate methods
extension SignUpViewController: ValidationDelegate {
    func validationSuccessful() {

    }

    func validationFailed(errors:[UITextField:ValidationError]) {
        // turn the fields to red
        for (field, error) in validator.errors {
            field.layer.borderColor = UIColor.redColor().CGColor
            field.layer.borderWidth = 1.0
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.hidden = false
        }
    }

}
