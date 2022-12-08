//
//  ProfileViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import ProgressHUD
import SDWebImage
import SafariServices

class ProfileViewController: UIViewController {
    
    
    // MARK: Attributes
    
    
    // MARK: UI Elements
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorStyle = .singleLine
        return table
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // nav bar configuration
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label]
        
        let barButton = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .done, target: self, action: #selector(didTapLogOut))
        barButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = barButton
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        
        addSubviews()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: Functions
    // create header for profile
    private func createTableHeader() -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 100))
        header.backgroundColor = .systemBackground
        
        let profileImage = UIImageView(frame: CGRect(x: 10, y: 0, width: 80, height: 80))
        profileImage.center.y = header.center.y
        
        let nameLabel = UILabel(frame: CGRect(x: profileImage.right + 10, y: 10, width: 350, height: 40))
        
        let emailLabel = UILabel(frame: CGRect(x: profileImage.right + 10, y: nameLabel.bottom, width: 250, height: 20))
        
        // configure labels
        nameLabel.numberOfLines = 0
        nameLabel.textColor = .label
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        emailLabel.textColor = .secondaryLabel
        
        // configure image
        profileImage.clipsToBounds = true
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.height / 2
        profileImage.contentMode = .scaleAspectFill
        
        // add subviews
        header.addSubview(profileImage)
        header.addSubview(nameLabel)
        header.addSubview(emailLabel)
        
        guard let email = UserDefaults.standard.string(forKey: "email") else {return nil}
        guard let fileName = UserDefaults.standard.string(forKey: "profilePictureURLString") else {return nil}
        guard let firstName = UserDefaults.standard.string(forKey: "firstName") else {return nil}
        guard let lastName = UserDefaults.standard.string(forKey: "lastName") else {return nil}
        
        nameLabel.text = ("\(firstName) \(lastName)")
        emailLabel.text = email
        
        let path = "users/\(email.lowercased())/\(fileName)"
        
        StorageManager.shared.downloadProfilePictureURL(path: path) { [weak self] result in
            
            switch result {
                
            case .success(let url):
                
                DispatchQueue.main.async {
                    
                    profileImage.sd_setImage(with: url)
                    
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    
                    profileImage.image = UIImage(systemName: "person.circle")
                    
                    self?.tableView.reloadData()
                }
            }
            
        }
        
        return header
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        
    }
    
    private func addSubviews() {
        
        view.addSubview(tableView)
    }

    
    // MARK: Button Actions
    @objc
    private func didTapLogOut() {
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            
            // log out the user
            UserDefaults.standard.set(nil, forKey: "firstName")
            UserDefaults.standard.set(nil, forKey: "lastName")
            UserDefaults.standard.set(nil, forKey: "email")
            UserDefaults.standard.set(nil, forKey: "profilePictureURL")
            
            AuthManager.shared.signOut { [weak self] success in
                
                if success {
                    // go to sign in
                    let vc = SignInViewController()
                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .fullScreen
                    SceneDelegate.shared.window?.rootViewController = vc
                    self?.present(navVC, animated: true)
                    
                } else {
                    
                    ProgressHUD.showError("Error")
                }
            }
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
        
    }

    
}// class ends

// MARK: Table View Delegate and Datasource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .secondarySystemBackground
        
        cell.textLabel?.text = "Privacy Policy"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            guard let url = URL(string: "https://www.facebook.com/help/messenger-app/408883583307426") else {return}
            
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true)
        }
    }
    
    
}

