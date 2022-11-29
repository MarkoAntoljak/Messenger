//
//  ConversationsTableViewCell.swift
//  MessengerClone
//
//  Created by Marko Antoljak on 11/29/22.
//

import UIKit
import SDWebImage

class ConversationsTableViewCell: UITableViewCell {
    
    // MARK: Attributes
    /// cell identifier
    public static let identifier = "ConversationsTableViewCell"
    
    // MARK: UI Elements
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Sir John Ive"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Hello, how are you?"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "24/12/2022"
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var profilePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.height / 2
        imageView.image = UIImage(systemName: "person.circle")
        return imageView
    }()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        backgroundColor = .systemBackground
        layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(profilePicture)
        
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // profile picture
        profilePicture.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        profilePicture.center.y = contentView.center.y
        
        // name label
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: profilePicture.right + 10, y: 15, width: nameLabel.width, height: nameLabel.height)
        
        // message label
        messageLabel.sizeToFit()
        messageLabel.frame = CGRect(x: profilePicture.right + 10, y: nameLabel.bottom, width: messageLabel.width, height: messageLabel.height)
        
        //date label
        dateLabel.sizeToFit()
        dateLabel.frame = CGRect(x: contentView.right - (dateLabel.width) - 10, y: 0, width: dateLabel.width, height: dateLabel.height)
        dateLabel.center.y = contentView.center.y
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        messageLabel.text = nil
        profilePicture.image = nil
    }
    
    // MARK: Functions
    public func configure(with model: Conversation) {
        
        messageLabel.text = model.latestMessage.text
        dateLabel.text = model.latestMessage.date
        nameLabel.text = model.name
        
        // set image
        let path = "users/\(model.otherUserEmail)/profilePhoto.png"
        
        StorageManager.shared.downloadProfilePictureURL(path: path) { [weak self] result in
            
            switch result {
                
            case .failure(let error):
                print(error.localizedDescription)
                
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.profilePicture.sd_setImage(with: url)
                }
        
            }
        }
    }
    
    // MARK: Actions
    
    


}
