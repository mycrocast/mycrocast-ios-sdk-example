import Foundation
import UIKit

import MycrocastSDK


/**
 This is a single chat cell (visual representation of a single chat message)
 Based on who has written the message we display it right or left and in a different color for the name
 of the sender.
 Selecting the cell will open a context menu where the user can report the message
 */
class ChatCell: UITableViewCell {

    public static let IDENTIFIER: String = "chat"

    private let messageContainer = UIView()
    private let message = UILabel()
    private let author = UILabel()
    private let time = UILabel()

    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?

    private var chatMessage: Message?

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.createInitialLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func createInitialLayout() {
        self.contentView.backgroundColor = Colors.lightBackground

        self.messageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.messageContainer.backgroundColor = Colors.darkBackground
        self.messageContainer.layer.cornerRadius = 15
        self.messageContainer.layer.borderWidth = 1
        self.messageContainer.layer.borderColor = Colors.lightGrey.cgColor

        self.contentView.addSubview(messageContainer)

        self.message.translatesAutoresizingMaskIntoConstraints = false
        self.message.numberOfLines = 0
        self.message.lineBreakMode = .byWordWrapping
        self.message.textColor = .white
        self.message.font = .systemFont(ofSize: 15)

        self.messageContainer.addSubview(self.message)

        self.message.topAnchor.constraint(equalTo: self.messageContainer.topAnchor, constant: 5).isActive = true
        self.message.trailingAnchor.constraint(equalTo: self.messageContainer.trailingAnchor, constant: -5).isActive = true
        self.message.leadingAnchor.constraint(equalTo: self.messageContainer.leadingAnchor, constant: 5).isActive = true
        self.message.bottomAnchor.constraint(equalTo: self.messageContainer.bottomAnchor, constant: -5).isActive = true

        self.author.translatesAutoresizingMaskIntoConstraints = false
        self.author.font = .systemFont(ofSize: 12)
        self.contentView.addSubview(self.author)
        self.author.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        self.author.leadingAnchor.constraint(equalTo: self.message.leadingAnchor, constant: 5).isActive = true

        self.time.translatesAutoresizingMaskIntoConstraints = false
        self.time.textColor = Colors.lightGrey
        self.time.font = .systemFont(ofSize: 10)
        self.contentView.addSubview(self.time)

        self.time.topAnchor.constraint(equalTo: self.author.topAnchor).isActive = true
        self.time.bottomAnchor.constraint(equalTo: self.author.bottomAnchor).isActive = true
        self.time.trailingAnchor.constraint(equalTo: self.messageContainer.trailingAnchor, constant: -10).isActive = true

        self.messageContainer.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.8).isActive = true
        self.messageContainer.topAnchor.constraint(equalTo: self.author.bottomAnchor, constant: -1).isActive = true
        self.messageContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        self.rightConstraint = self.messageContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor)
        self.leftConstraint = self.messageContainer.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCellClicked(_:)))
        self.addGestureRecognizer(gestureRecognizer)
    }

    /**
     Open the context menu to allow the user to report a chat message if the message is not from myself
     - Parameter recognizer:
     */
    @objc private func onCellClicked(_ recognizer: UITapGestureRecognizer) {
        if (self.chatMessage?.getSender() == .myself) {
            return
        }

        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)

        let reportAction = UIAlertAction(title: "Report", style: .default) { action in
            if let chatMessage = self.chatMessage {
                let rootView = AppDelegate.rootViewController?.view

                let reportView = ChatReport(chatMessage)
                reportView.translatesAutoresizingMaskIntoConstraints = false

                rootView!.addSubview(reportView)
                reportView.topAnchor.constraint(equalTo: rootView!.safeAreaLayoutGuide.topAnchor, constant: -5).isActive = true
                reportView.leadingAnchor.constraint(equalTo: rootView!.leadingAnchor).isActive = true
                reportView.trailingAnchor.constraint(equalTo: rootView!.trailingAnchor).isActive = true
                reportView.bottomAnchor.constraint(equalTo: rootView!.safeAreaLayoutGuide.bottomAnchor).isActive = true
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)

        AppDelegate.rootViewController?.present(optionMenu, animated: true)
    }

    /**
     Update the view with the new content of the message
     Based on the sender of the message we adjust the layout
     - Parameter message: the new message
     */
    func update(_ message: Message) {
        self.rightConstraint?.isActive = false
        self.leftConstraint?.isActive = false

        let sender = message.getSender()
        switch sender {
        case .streamer:
            self.author.textColor = Colors.streamerChatName
            self.rightConstraint?.isActive = true
        case .myself:
            self.author.textColor = Colors.chatName
            self.leftConstraint?.isActive = true
        case .other:
            self.author.textColor = Colors.chatName
            self.rightConstraint?.isActive = true
        }

        self.author.text = message.senderName
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.medium
        self.time.text = formatter.string(from: message.creationTime)
        self.message.text = message.message

        self.chatMessage = message
    }
}