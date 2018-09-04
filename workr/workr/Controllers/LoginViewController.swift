//
//  LoginViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 30/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import PromiseKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) {
        guard let vc = segue.source as? RegisterViewController, let user = vc.user, let password = vc.password else { return }
        usernameTextField.text = user.Email
        passwordTextField.text = password
    }
    
    @IBAction func loginDidTap(_ sender: Any) {
        login()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstly {
            appData.login()
            } .done { (user) in
                self.performSegue(withIdentifier: "ShowMain", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func login() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        
        firstly {
            appData.login(username: username, password: password)
            }.done { (user) in
                self.performSegue(withIdentifier: "ShowMain", sender: self)
            }.catch { (error) in
                print(error.localizedDescription)
        }
    }
}
