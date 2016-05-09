//
//  LoginViewController.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 08.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityView: UIView!

    let httpService = HTTPService()
    let validator = Validator()

    override func viewDidLoad() {

        //TODO: - Add validation
        validator.registerField(userNameTextField, rules: [RequiredRule(),RegexRule(regex: "^(?=.{8,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$")])
        validator.registerField(passwordTextField, rules: [RequiredRule()])
        super.viewDidLoad()
        activityView.layer.cornerRadius = 10
        userNameTextField.returnKeyType = .Next
        passwordTextField.returnKeyType = .Done

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userNameTextField.becomeFirstResponder()
    }
}


//MARK: - Textfield Delegate methods
extension LoginViewController: UITextFieldDelegate {
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
extension LoginViewController {
    @IBAction func loginButtonTapped(sender: UIButton) {

        //TODO: Validation
        //validator.validate(self)
        weak var weakActivityView = self.activityView
        weakActivityView!.hidden = false

        let username = (userNameTextField.text)!
        let password = (passwordTextField.text)!

        //TODO: Handle network avaliability and return codes
        let params = ["username": username, "password": password]
        let url = HTTPService.httpbaseURL + HTTPService.httpapiToken
        //print(url)
        Alamofire.request(.POST, url, parameters: params).validate()
            .responseJSON { [unowned self] response in
//                print(response.request?.URL?.absoluteString)
            switch response.result {
                case .Success:
                    let responseJSON = JSON(data: response.data!)
                    Defaults[HTTPService.udtoken] = responseJSON[HTTPService.jsonapiToken].string
                    print(responseJSON[HTTPService.jsonapiToken].string)
                    Defaults[HTTPService.udisLoggedIn] = true
                    dispatch_async(dispatch_get_main_queue(), { [unowned self]() -> Void in
                        weakActivityView!.hidden = true
                        self.dismissViewControllerAnimated(true, completion: nil)
                        SyncNotification.StartSync.postNotification()
                    })
                    //TODO: Handle this error
                case .Failure(let error):
                    print(error)
                }
        }
    }


    }

//MARK: - Validation delegate methods
extension LoginViewController: ValidationDelegate {
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