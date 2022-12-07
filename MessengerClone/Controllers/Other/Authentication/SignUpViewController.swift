//
//  SignUpViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import ProgressHUD

/// class for registering a new user
class SignUpViewController: UIViewController {
    
    // MARK: Attributes
    
    private var user: User?
    private var hasPicture: Bool = false
    
    // MARK: UI Elements
    
    private lazy var profileImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var firstNameField: MessengerTextField = {
        let field = MessengerTextField()
        field.returnKeyType = .next
        field.keyboardType = .default
        field.autocapitalizationType = .words
        field.attributedPlaceholder = NSAttributedString(string: "Enter first name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return field
    }()
    
    private lazy var lastNameField: MessengerTextField = {
        let field = MessengerTextField()
        field.returnKeyType = .next
        field.autocapitalizationType = .words
        field.attributedPlaceholder = NSAttributedString(string: "Enter last name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        field.keyboardType = .default
        return field
    }()
    
    private lazy var emailField: MessengerTextField = {
        let field = MessengerTextField()
        field.returnKeyType = .next
        field.attributedPlaceholder = NSAttributedString(string: "Enter email address", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        field.keyboardType = .emailAddress
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
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Already have an account? Sign in", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // add subviews
        addSubviews()
        // add button actions
        addActions()
        
        // set delegates
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setFrames()
    }
    
    // MARK: View Functions
    
    private func addSubviews() {
        
        view.addSubview(profileImg)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(signInButton)
        
    }
    
    private func setFrames() {
        
        let height: CGFloat = 50
        
        // profile img
        profileImg.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 150, height: 150)
        profileImg.center.x = view.center.x
        
        // first name tf
        firstNameField.frame = CGRect(x: 0, y: profileImg.bottom + height, width: view.width - height, height: height)
        firstNameField.center.x = view.center.x
        
        // last name tf
        lastNameField.frame = CGRect(x: 0, y: firstNameField.bottom + (height/2), width: view.width - height, height: height)
        lastNameField.center.x = view.center.x
        
        // email tf
        emailField.frame = CGRect(x: 0, y: lastNameField.bottom + (height/2), width: view.width - height, height: height)
        emailField.center.x = view.center.x
        
        // password tf
        passwordField.frame = CGRect(x: 0, y: emailField.bottom + (height/2), width: view.width - height, height: height)
        passwordField.center.x = view.center.x
        
        // sing up btn
        signUpButton.frame = CGRect(x: 0, y: passwordField.bottom + height, width: passwordField.width - 20, height: height)
        signUpButton.center.x = view.center.x
        
        // sign in btn
        signInButton.frame = CGRect(x: 0, y: signUpButton.bottom + (height/2), width: 300, height: height)
        signInButton.center.x = view.center.x
        
    }
    
    private func addActions() {
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tap)
        
    }
    
    // MARK: Button Actions
    
    @objc
    private func didTapProfileImage() {
        
        
        let actions = UIAlertController(title: "Profile Photo", message: "Choose your profile photo.", preferredStyle: .actionSheet)
        
        actions.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] action in
            
            DispatchQueue.main.async { 
                
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            }
            
        }))
        
        actions.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] action in
            
            DispatchQueue.main.async {
             
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = true
                picker.sourceType = .photoLibrary
                self?.present(picker, animated: true)
            }
            
        }))
        
        actions.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        DispatchQueue.main.async { [weak self] in
         
            self?.present(actions, animated: true)
        }
        
    }
    
    @objc
    private func didTapSignUp() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        signUp()
        
    }
    
    @objc
    private func didTapSignIn() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Sign Up
    
    private func signUp() {
        
        // validate user input
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              firstName.count >= 2,
              lastName.count >= 2,
              password.count >= 6,
              email.contains("@") else {
            
            if passwordField.text!.count < 6 {
                
                let alert = UIAlertController(title: "Error", message: "Password must have 6 or more characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(alert, animated: true)
                
            }
            
            if firstNameField.text!.count < 2 || lastNameField.text!.count < 2 {
                
                let alert = UIAlertController(title: "Error", message: "First name and last name must have 2 or more characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                present(alert, animated: true)
                
            }
            
            let alert = UIAlertController(title: "Error", message: "Please input all fields correctly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            
            return
            
        }
        
        
        // if user didnt put profile picture, alert him
        if !hasPicture {
            
            let alert = UIAlertController(title: "Error", message: "Please add your profile picture.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
            
            return
        }
        
        ProgressHUD.show("Registering")
        
        // start authentication, database and storage fetch
        AuthManager.shared.signUp(firstName: firstName, lastName: lastName, email: email, password: password) { [weak self] success in
            
            if success {
                
                DatabaseManager.shared.getUserData(with: email) { [weak self] result in
                    
                    guard let strongSelf = self else {return}
                    
                    switch result {
                        
                    case .failure(let error):
                        
                        print(error.localizedDescription)
                        
                    case .success(let dictionary):
                        
                        let user = User(dictionary: dictionary)
                        
                        strongSelf.user = user
                        
                        guard let image = strongSelf.profileImg.image else {return}
                        
                        guard let imageData = image.pngData() else {return}
                        
                        let filename = user.profilePictureFilename
                        
                        // save profile photo to storage
                        StorageManager.shared.insertProfilePicture(user: user, fileName: filename, photoData: imageData) { [weak self] result in
                            
                                switch result {
                                    
                                case .success(let url):
                                    
                                    ProgressHUD.showSuccess()
                                    
                                    UserDefaults.standard.set(url, forKey: "profilePictureURL")
                                    UserDefaults.standard.set(user.firstName, forKey: "firstName")
                                    UserDefaults.standard.set(user.lastName, forKey: "lastName")
                                    UserDefaults.standard.set(user.fullName, forKey: "fullName")
                                    UserDefaults.standard.set(user.email, forKey: "email")
                                    
                                    DispatchQueue.main.async {
                                        let vc = TabBarViewController()
                                        vc.modalPresentationStyle = .fullScreen
                                        self?.present(vc, animated: true)
                                    }
                                    
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    
                                }
                        }
                        
                    }
                }
                
            } else {
                
                ProgressHUD.showError("There was an error, try again")
                
            }
        }
    }
    
    
    
} // class ends

// MARK: Text Field Delegate

extension SignUpViewController: UITextFieldDelegate {
    
    // changing textfields after "next" on keyboard is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField {
            
            lastNameField.becomeFirstResponder()
            
        } else if textField == lastNameField {
            
            emailField.becomeFirstResponder()
            
        } else if textField == emailField {
            
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            
            passwordField.resignFirstResponder()
            signUp()
        }
        
        return true
    }
}

// MARK: UI Image Picker Delegate

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // grab selected image and set it as profile photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        
        DispatchQueue.main.async { [weak self] in
            
            guard let strongSelf = self else {return}
            
            strongSelf.hasPicture = true
            strongSelf.profileImg.image = selectedImage
            strongSelf.profileImg.layer.cornerRadius = strongSelf.profileImg.height / 2
            strongSelf.profileImg.contentMode = .scaleAspectFill
            strongSelf.profileImg.layer.borderWidth = 1
            strongSelf.profileImg.layer.borderColor = UIColor.systemBlue.cgColor
            
        }
        
    }
    
    // dismiss image picker if user cancels
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
        
    }
    
}


