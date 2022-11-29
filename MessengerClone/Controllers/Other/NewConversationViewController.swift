//
//  NewConversationViewController.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/29/22.
//

import UIKit

class NewConversationViewController: UIViewController {

    // MARK: Attributes
    /// array of all the users
    private var users = [User]()
    /// array of filtered users
    private var results = [User]()
    
    private var hasFetched = false
    
    public var completion: ((User) -> ())?
    
    // MARK: UI Elements
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        searchBar.backgroundColor = .secondarySystemBackground
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.hidesWhenStopped = true
        return loader
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results"
        label.font = .systemFont(ofSize: 22)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    // MARK: Viewcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        // navigation bar
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        // add subviews
        view.addSubview(tableView)
        view.addSubview(loader)
        view.addSubview(noResultsLabel)
        
        // delegates
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // table view
        tableView.frame = CGRect(x: 0, y: searchBar.height, width: view.width, height: view.height - searchBar.height)
        
        // no results label
        noResultsLabel.sizeToFit()
        noResultsLabel.center = view.center
        
        loader.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        loader.center = view.center
    }
    
    
    // MARK: Button actions
    @objc
    private func didTapClose() {

        self.dismiss(animated: true)
        
    }


}

// MARK: TableView Delegate and DataSource
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let resultname = users[indexPath.row].fullName
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = resultname
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async { [weak self] in
            
            self?.dismiss(animated: true)
            self?.completion?(user)
            
        }
    }
    
}

// MARK: Search Bar Delegate
extension NewConversationViewController: UISearchBarDelegate {
    
    // when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        guard let searchedText = searchBar.text, !searchedText.replacingOccurrences(of: " ", with: "").isEmpty else {
            print("return")
            return}
    
        // reseting array
        results.removeAll()
    
        loader.startAnimating()
        
        searchUsers(query: searchedText)
    }
    
    // searching users
    private func searchUsers(query: String) {
        
        if hasFetched {
            
            filterUsers(with: query)
            
        } else {
            
            DatabaseManager.shared.getAllUsersData { [weak self] result in
                
                switch result {
                    
                case .success(let users):
                    
                    self?.hasFetched = true
                    
                    self?.users = users
                    
                    self?.filterUsers(with: query)
                    
                    print(users)
                
                case .failure(let error):
                    
                    print(error)
                    
                }
            }
        }
        
    }// end of search users
    
    private func filterUsers(with searchedtext: String) {
        
        guard hasFetched else {return}
        
        let results: [User] = self.users.filter({
            
            return $0.fullName.lowercased().hasPrefix(searchedtext.lowercased())
        })
        
        self.results = results
        
        updateUI()
        
    }
    
    // updating UI based on search results
    private func updateUI() {
        
        DispatchQueue.main.async {
            
            if self.results.isEmpty {
                
                self.loader.stopAnimating()
                self.tableView.isHidden = true
                self.noResultsLabel.isHidden = false
                
            } else {
                
                self.loader.stopAnimating()
                self.tableView.isHidden = false
                self.noResultsLabel.isHidden = true
                
                self.tableView.reloadData()
            }
        }
    }
    
    
}
