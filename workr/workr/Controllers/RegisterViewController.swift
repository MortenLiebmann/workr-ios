//
//  RegisterViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 30/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    var textFields: [UITextField] = []
    var user: User?
    var password: String?
    
    @IBAction func registerDidTap(_ sender: Any) {
        register()
    }
    
    @IBAction func cancelDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields = [
            nameTextField,
            emailTextField,
            passwordTextField,
            repeatPasswordTextField
        ]
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorTextField(textField: UITextField) {
        if validate(textField) {
            textField.borderColor = .darkGray
        } else {
            textField.borderColor = .red
        }
    }
    
    func validate(_ textField: UITextField) -> Bool {
        return !(textField.text?.isEmptyOrWhitespace())!
    }
    
    func invalidTextFields() -> Bool {
        if (textFields.first{ $0.borderColor == .red }) == nil {
            return false
        } else {
            return true
        }
    }
    
    func register() {
        textFields.forEach { (textField) in
            self.colorTextField(textField: textField)
        }
        
        if invalidTextFields() {
            return
        }
        
        if passwordTextField.text != repeatPasswordTextField.text {
            return
        }
        
        firstly {
            appData.registerUser(name: nameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!)
            }.done { (user) in
                self.user = user
                self.password = self.passwordTextField.text
                self.performSegue(withIdentifier: "unwind", sender: self)
                print(user)
            }.catch { (error) in
                print(error)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
