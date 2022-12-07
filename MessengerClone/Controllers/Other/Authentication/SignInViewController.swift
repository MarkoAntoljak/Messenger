//
//  SignInViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import SafariServices
import ProgressHUD

/// singing in the user view controller
class SignInViewController: UIViewController {
    
    // MARK: Attributes
    var user: User?
    
    // MARK: UI Elements
    private lazy var headline: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messenger-textHeader")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var emailField: MessengerTextField = {
        let field = MessengerTextField()
        field.returnKeyType = .next
        field.attributedPlaceholder = NSAttributedString(string: "Enter email address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        field.keyboardType = .emailAddress
        field.tintColor = .black
        return field
    }()
    
    private lazy var passwordField: MessengerTextField = {
        let field = MessengerTextField()
        field.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        field.returnKeyType = .done
        field.isSecureTextEntry = true
        field.keyboardType = .default
        return field
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Terms & Conditions", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // add subviews
        addSubviews()
        // add actions
        addActions()
        // set delegates
        emailField.delegate = self
        passwordField.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setFrames()
    }
    
    // MARK: View Functions
    private func addSubviews() {
        
        view.addSubview(headline)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(privacyButton)
        view.addSubview(termsButton)
        
    }
    
    private func setFrames() {
        
        let height: CGFloat = 50
        
        //headline
        headline.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: 100)
        headline.center.x = view.center.x
        
        // email tf
        emailField.frame = CGRect(x: 0, y: headline.bottom + 50, width: view.width - height, height: height)
        emailField.center.x = view.center.x
        
        // password tf
        passwordField.frame = CGRect(x: 0, y: emailField.bottom + (height/2), width: view.width - height, height: height)
        passwordField.center.x = view.center.x
        
        // sing in btn
        signInButton.frame = CGRect(x: 0, y: passwordField.bottom + height, width: passwordField.width - 20, height: height)
        signInButton.center.x = view.center.x
        
        // sign up btn
        signUpButton.frame = CGRect(x: 0, y: signInButton.bottom + (height/2), width: 150, height: height)
        signUpButton.center.x = view.center.x
        
        // privacy and terms
        privacyButton.sizeToFit()
        privacyButton.frame = CGRect(x: 0, y: signUpButton.bottom + (height*2), width: 150, height: privacyButton.height)
        privacyButton.center.x = view.center.x
        
        termsButton.sizeToFit()
        termsButton.frame = CGRect(x: 0, y: signUpButton.bottom + (height*3), width: 300, height: privacyButton.height)
        termsButton.center.x = view.center.x
        
    }
    
    private func addActions() {
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        
    }
    
    // MARK: Actions
    
    @objc
    private func didTapSignIn() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        signIn()
    }
    
    @objc
    private func didTapSignUp() {
        
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func didTapPrivacy() {
        
        guard let url = URL(string: "https://www.facebook.com/privacy/policy/") else {return}
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    @objc
    private func didTapTerms() {
        
        guard let url = URL(string: "https://www.facebook.com/terms.php") else {return}
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    // MARK: Sign In
    
    private func signIn() {
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6,
              email.contains("@") else {
            
            if passwordField.text!.count < 6 {
                
                let alert = UIAlertController(title: "Error", message: "Password must have 6 or more characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(alert, animated: true)
                
            }
            
            let alert = UIAlertController(title: "Error", message: "Please input all fields correctly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            
            return
            
        }
        
        ProgressHUD.show("Signing in")
        ProgressHUD.colorAnimation = .systemBlue
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] success in
            
            DispatchQueue.main.async {
                
                if success {
                    // go to home view controller
                    ProgressHUD.showSuccess()
                    
                    DatabaseManager.shared.getUserData(with: email) { [weak self] result in
                        
                        switch result {
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            
                        case .success(let dictionary):
                            
                            let user = User(dictionary: dictionary)
                            
                            self?.user = user
                            
                            UserDefaults.standard.set(user.email, forKey: "email")
                            UserDefaults.standard.set(user.firstName, forKey: "firstName")
                            UserDefaults.standard.set(user.lastName, forKey: "lastName")
                            UserDefaults.standard.set(user.fullName, forKey: "fullName")
                            
                            let vc = TabBarViewController()
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: true)
                            
                        }
                    }
                } else {
                    // show error
                    ProgressHUD.showError("Wrong email or password")
                }
            }
        }
        
    }
    
}


// MARK: Text Field Delegate
extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            
            didTapSignIn()
        }
        
        return true
    }
    
}
