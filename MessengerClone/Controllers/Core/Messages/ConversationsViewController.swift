//
//  ConversationsViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/28/22.
//

import UIKit
import ProgressHUD


class ConversationsViewController: UIViewController {

    
    // MARK: Attributes
    private var user: User?
    
    private var conversations = [Conversation]() 
    
    // MARK: UI Elements
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(ConversationsTableViewCell.self, forCellReuseIdentifier: ConversationsTableViewCell.identifier)
        return table
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "No messages"
        label.isHidden = true
        label.textColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "questionmark.bubble")
        imageView.tintColor = .secondarySystemBackground
        return imageView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        title = "Messages"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        
        // start new conversation
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapNewChat))
        
        addSubviews()
        setUpTableView()
        
        fetchConversations()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setFrames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: View Functions
    
    private func addSubviews() {
        
        view.addSubview(tableView)
        view.addSubview(label)
        view.addSubview(imageView)
    }
    
    private func setFrames() {
        
        // tableview
        tableView.frame = view.bounds
        
        // no messages label and image
        label.sizeToFit()
        label.frame = CGRect(x: 0, y: view.center.y + 50, width: label.width, height: label.height)
        label.center.x = view.center.x
        
        imageView.frame = CGRect(x: 0, y: label.top - 100, width: 100, height: 100)
        imageView.center.x = view.center.x
        
    }
    
    private func setUpTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createNewConversation(user: User) {
        
        let vc = ChatViewController(user: user)
        vc.isNewChat = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Button Actions
    @objc
    private func didTapNewChat() {
    
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.completion = { [weak self] user in
            
            self?.createNewConversation(user: user)
        }
        
        present(navVC, animated: true)
    }
    
    
    // MARK: Functions

    private func fetchConversations() {
        
        guard let user = user else {
            print("there is no user")
            return
        }
        
        DatabaseManager.shared.getAllConversations(for: user) { [weak self] result in
            
            switch result {
                
            case .failure(let error):
                
                print(error.localizedDescription)
                
            case .success(let conversations):
                
                if !conversations.isEmpty {
                    
                    self?.tableView.isHidden = true
                    self?.label.isHidden = false
                    self?.imageView.isHidden = false
                    return
                    
                } else {
                    
                    self?.tableView.isHidden = false
                    self?.label.isHidden = true
                    self?.imageView.isHidden = true
                    
                    self?.conversations = conversations
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                
            }
            
        }
    }

}


// MARK: TableView Delegate and DataSource
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    /// configuring each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.identifier, for: indexPath) as? ConversationsTableViewCell else {return UITableViewCell()}
        
        cell.configure(with: model)

        return cell
        
    }
    
    /// cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /// selecting cell chat
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let user = user else {return}
        
        // navigate to the chat conversation
        let vc = ChatViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}
