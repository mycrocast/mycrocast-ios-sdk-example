import Foundation
import UIKit
import MycrocastSDK

/**
 This controller represent the chat for a single stream.
 It consist of an input field to enter a chat message, a button to send it and a tableview containing all the
 chat messages

 If the chat was disabled by the streamer, we provide this information instead of showing the actual chat
 This class is part of the example to show how to use the Chat part of the mycrocast SDK
 */
class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChatDelegate {

    private let chatTable: UITableView
    private let input: UITextField
    private let sender: UIButton
    private let chatStatus: UILabel

    private let streamId: Int
    private let chat: Chat

    private var chatMessages: [Message] = []

    init(_ streamId: Int) {
        self.chatTable = UITableView(frame: .zero, style: .plain)
        self.input = UITextField(frame: .zero)
        self.sender = UIButton(frame: .zero)
        self.chat = Mycrocast.shared.chat
        self.chatStatus = UILabel(frame: .zero)
        self.streamId = streamId

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Colors.lightBackground

        self.sender.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.sender)
        self.sender.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5).isActive = true
        self.sender.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        self.sender.setTitle("Send", for: .normal)
        self.sender.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.sender.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.sender.addTarget(self, action: #selector(sendChat), for: .touchUpInside)

        self.input.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.input)
        self.input.centerYAnchor.constraint(equalTo: self.sender.centerYAnchor).isActive = true
        self.input.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.input.trailingAnchor.constraint(equalTo: self.sender.leadingAnchor, constant: -10).isActive = true
        self.input.backgroundColor = .white
        self.input.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.input.placeholder = "Enter chat message"
        self.input.layer.cornerRadius = 5

        self.chatTable.register(ChatCell.self, forCellReuseIdentifier: ChatCell.IDENTIFIER)
        self.chatTable.translatesAutoresizingMaskIntoConstraints = false
        self.chatTable.backgroundColor = Colors.lightBackground
        self.chatTable.estimatedRowHeight = 85
        self.chatTable.rowHeight = UITableView.automaticDimension
        self.chatTable.delegate = self
        self.chatTable.dataSource = self

        self.view.addSubview(self.chatTable)

        self.chatTable.topAnchor.constraint(equalTo: self.sender.bottomAnchor, constant: 15).isActive = true
        self.chatTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.chatTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.chatTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        self.chatTable.backgroundColor = .clear

        self.chatStatus.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.chatStatus)

        self.chatStatus.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75).isActive = true
        self.chatStatus.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.chatStatus.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.chatStatus.isHidden = true
        self.chatStatus.text = "Chat is disabled by the streamer"
        self.chatStatus.textColor = .white

        self.checkIfChatJoined()
    }

    /**
       We check if we have already joined (opened) the chat previously otherwise we join the chat
       We need to be in the chat to receive updates for the chat and also we need to have joined to receive the last messages
       and the state of the chat
     */
    private func checkIfChatJoined() {
        if !self.chat.chatJoined(streamId: self.streamId) {
            self.chat.joinChat(streamId: self.streamId) { messages, chatStatus, error in
                if let error = error {

                } else {
                    self.chatMessages.append(contentsOf: messages)
                    DispatchQueue.main.async {
                        self.chatTable.reloadData()
                    }

                    self.onChatStatusChanged(self.streamId, status: chatStatus)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We subscribe for updates to the chat so that we can display them again
        self.chat.addObserver(delegate: self)
        // we clear everything and get the internal chat messages because we could have missed
        // messages when this view was closed and we did unsubscribe from the observer
        // the internal messages are only received when we joined the chat
        self.chatMessages.removeAll()
        self.chatMessages.append(contentsOf: chat.getChatMessages(streamId: self.streamId)) // get internal messages
        DispatchQueue.main.async {
            self.chatTable.reloadData()
            // update the status of the chat in case we missed an update
            self.onChatStatusChanged(self.streamId, status: self.chat.getChatStatus(streamId: self.streamId))
        }

        AppDelegate.rootViewController = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // unsubscribe again as this view will close
        self.chat.removeObserver(delegate: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
      We send a chat message if the text input is not empty
      We could be blocked by the streamer, we get this information in the response to the message
      We can either display this to the user or not
     */
    @objc private func sendChat() {
        if let message = self.input.text {
            self.input.text = ""
            self.input.resignFirstResponder()
            self.chat.sendChatMessage(streamId: self.streamId, message: message) { success, error in
                // success is false in case you are blocked by the streamer
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.IDENTIFIER, for: indexPath) as! ChatCell
        let message = self.chatMessages[indexPath.row]

        cell.update(message)
        return cell
    }

    /**
     After we subscribed to the observer we receive here new chat message
     This update is called for all currently open chats, therefore we need to check if this messages belongs
     to our current stream
     - Parameter message: the new chat message
     */
    func onMessage(_ message: Message) {
        if (self.streamId != message.streamId) {
            return
        }
        self.chatMessages.append(message)
        DispatchQueue.main.async {
            self.chatTable.reloadData()
        }
    }

    /**
     After we subscribed to the observer we receive here updates for the chat status in general,
      this can be that the streamer decided to disable or enable the chat
      Because we get this update for each currently open chat, we need to check if this change is for our currently shown
      chat
     - Parameters:
       - streamId: id of the stream where the status update happened
       - status:   the new status of the chat
     */
    func onChatStatusChanged(_ streamId: Int, status: ChatStatus) {
        if (self.streamId != streamId) {
            return
        }

        DispatchQueue.main.async {
            self.chatTable.isHidden = status == .disabled
            self.input.isHidden = status == .disabled
            self.sender.isHidden = status == .disabled
            self.chatStatus.isHidden = status == .enabled
        }
    }
}
