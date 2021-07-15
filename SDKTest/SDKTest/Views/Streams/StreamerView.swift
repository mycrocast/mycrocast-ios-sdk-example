import Foundation
import UIKit
import MycrocastSDK

/**
 Example view of a streamer
 that could be extended to also include a stop/play button
 currently you see the header of the club, the name of the streamer,
 you can rate and see the number of listeners

 In this screen we subscribe to updates for the stream, update the view if the stream is updated
 and navigate back when the stream has ended.
 We can navigate to the chat for this stream from this view

 We show the current status of the chat (joined, and if enabled or disabled) we can only now the status of the chat after
 we joined. This is more for the developer intended and should probably not be displayed in any real app
 */
class StreamerView: UIViewController, StreamsDelegate, ChatDelegate {

    private let header: UIImageView = UIImageView()
    private let streamerName: UILabel = UILabel()
    private let listener: UIButton = UIButton()
    private let listenerCount: UILabel = UILabel()

    private let likeButton: UIButton = UIButton()
    private let likeCount: UILabel = UILabel()

    private let dislikeButton: UIButton = UIButton()
    private let dislikeCount: UILabel = UILabel()

    private let chatContainer: UIView = UIView()
    private let chatText: UILabel = UILabel()
    private let chatStatus: UILabel = UILabel()
    private let chatOpened: UILabel = UILabel()

    private var streamDescription: DescriptionContaining?

    private var liveStream: LiveStream;

    init(liveStream: LiveStream) {
        self.liveStream = liveStream
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.createViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppDelegate.rootViewController = self

        // subscribe to receive updates for streams
        Mycrocast.shared.streams.addObserver(self)

        // we could have missed some updates as we unsubscribe on viewDidDisappear, therefore we
        // fetch the latest version from the sdk
        let stream = Mycrocast.shared.streams.getStream(streamId: self.liveStream.id)
        if let stream = stream {
            self.liveStream = stream
            self.updateView(stream: self.liveStream)

            if (Mycrocast.shared.chat.chatJoined(streamId: self.liveStream.id)) {
                self.chatOpened.text = "true"
                self.chatOpened.textColor = .green
                self.chatStatus.text = Mycrocast.shared.chat.getChatStatus(streamId: self.liveStream.id) == .enabled ? "enabled" :
                        "disabled"
                self.chatStatus.textColor = Mycrocast.shared.chat.getChatStatus(streamId: self.liveStream.id) == .enabled ? .green :
                        .red
            } else {
                self.chatOpened.text = "false"
                self.chatStatus.text =  "unknown"
                self.chatOpened.textColor = .red
            }
            return
        }

        // the stream is no longer available therefore we leave this view
        self.onStreamRemoved(stream: self.liveStream)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // clean unsubscribe to not receive updates anymore when the view disappears
        Mycrocast.shared.streams.removeObserver(self)
    }

    private func createViews() {

        self.view.backgroundColor = Colors.darkBackground
        self.header.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.header)

        self.header.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.header.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.header.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.header.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.header.heightAnchor.constraint(equalTo: self.header.widthAnchor, multiplier: 1 / 3).isActive = true

        if let headerUrl = self.liveStream.header() {
            self.header.downloaded(from: headerUrl)
        }

        self.streamerName.translatesAutoresizingMaskIntoConstraints = false
        self.streamerName.text = self.liveStream.streamer.streamerName
        self.streamerName.textColor = .white
        self.streamerName.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.view.addSubview(self.streamerName)

        self.streamerName.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: 0).isActive = true
        self.streamerName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        let lightWrapper = UIView()
        lightWrapper.layer.cornerRadius = 15
        lightWrapper.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        lightWrapper.backgroundColor = Colors.lightBackground
        lightWrapper.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(lightWrapper)
        lightWrapper.topAnchor.constraint(equalTo: self.streamerName.bottomAnchor, constant: 10).isActive = true
        lightWrapper.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        lightWrapper.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        lightWrapper.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let listenerWrapper = UIView()
        listenerWrapper.translatesAutoresizingMaskIntoConstraints = false

        lightWrapper.addSubview(listenerWrapper)
        listenerWrapper.leadingAnchor.constraint(equalTo: lightWrapper.leadingAnchor).isActive = true
        listenerWrapper.topAnchor.constraint(equalTo: lightWrapper.topAnchor, constant: 5).isActive = true
        listenerWrapper.widthAnchor.constraint(equalTo: lightWrapper.widthAnchor, multiplier: 0.33).isActive = true

        self.listener.tintColor = .white
        self.listener.setImage(MycrocastAssetProvider.listener(), for: .normal)
        self.listener.translatesAutoresizingMaskIntoConstraints = false
        listenerWrapper.addSubview(self.listener)
        self.listener.centerXAnchor.constraint(equalTo: listenerWrapper.centerXAnchor).isActive = true
        self.listener.topAnchor.constraint(equalTo: listenerWrapper.topAnchor).isActive = true
        self.listener.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.listener.widthAnchor.constraint(equalTo: self.listener.heightAnchor, multiplier: 1).isActive = true

        self.listenerCount.text = String(self.liveStream.listeners)
        self.listenerCount.textColor = .white
        self.listenerCount.translatesAutoresizingMaskIntoConstraints = false
        listenerWrapper.addSubview(self.listenerCount)
        self.listenerCount.centerXAnchor.constraint(equalTo: listenerWrapper.centerXAnchor).isActive = true
        self.listenerCount.topAnchor.constraint(equalTo: self.listener.bottomAnchor, constant: 5).isActive = true
        self.listenerCount.bottomAnchor.constraint(equalTo: listenerWrapper.bottomAnchor, constant: 0).isActive = true

        let likeWrapper = UIView()
        likeWrapper.translatesAutoresizingMaskIntoConstraints = false

        lightWrapper.addSubview(likeWrapper)
        likeWrapper.leadingAnchor.constraint(equalTo: listenerWrapper.trailingAnchor).isActive = true
        likeWrapper.topAnchor.constraint(equalTo: listenerWrapper.topAnchor).isActive = true
        likeWrapper.widthAnchor.constraint(equalTo: listenerWrapper.widthAnchor).isActive = true

        let like = MycrocastAssetProvider.like()
        self.likeButton.setImage(like, for: .normal)
        self.likeButton.tintColor = .white
        self.likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeWrapper.addSubview(self.likeButton)

        self.likeButton.centerXAnchor.constraint(equalTo: likeWrapper.centerXAnchor).isActive = true
        self.likeButton.topAnchor.constraint(equalTo: likeWrapper.topAnchor).isActive = true
        self.likeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor, multiplier: 1).isActive = true
        self.likeButton.isUserInteractionEnabled = false

        self.likeCount.text = String(self.liveStream.likes)
        self.likeCount.textColor = .white
        self.likeCount.translatesAutoresizingMaskIntoConstraints = false
        likeWrapper.addSubview(self.likeCount)

        self.likeCount.topAnchor.constraint(equalTo: self.likeButton.bottomAnchor, constant: 5).isActive = true
        self.likeCount.centerXAnchor.constraint(equalTo: likeWrapper.centerXAnchor).isActive = true
        self.likeCount.bottomAnchor.constraint(equalTo: likeWrapper.bottomAnchor).isActive = true

        let likeTouch = UITapGestureRecognizer(target: self, action: #selector(self.likePressed(_:)))
        likeWrapper.addGestureRecognizer(likeTouch)

        let dislikeWrapper = UIView()
        dislikeWrapper.translatesAutoresizingMaskIntoConstraints = false

        lightWrapper.addSubview(dislikeWrapper)
        dislikeWrapper.leadingAnchor.constraint(equalTo: likeWrapper.trailingAnchor).isActive = true
        dislikeWrapper.topAnchor.constraint(equalTo: likeWrapper.topAnchor).isActive = true
        dislikeWrapper.widthAnchor.constraint(equalTo: likeWrapper.widthAnchor).isActive = true

        let dislike = MycrocastAssetProvider.like()
        self.dislikeButton.tintColor = .white
        self.dislikeButton.setImage(dislike, for: .normal)
        self.dislikeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeWrapper.addSubview(self.dislikeButton)

        self.dislikeButton.centerXAnchor.constraint(equalTo: dislikeWrapper.centerXAnchor).isActive = true
        self.dislikeButton.topAnchor.constraint(equalTo: dislikeWrapper.topAnchor).isActive = true
        self.dislikeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        self.dislikeButton.widthAnchor.constraint(equalTo: dislikeButton.heightAnchor, multiplier: 1).isActive = true

        self.dislikeCount.text = String(self.liveStream.dislikes)
        self.dislikeCount.textColor = .white
        self.dislikeCount.translatesAutoresizingMaskIntoConstraints = false
        dislikeWrapper.addSubview(self.dislikeCount)

        self.dislikeCount.topAnchor.constraint(equalTo: self.dislikeButton.bottomAnchor, constant: 5).isActive = true
        self.dislikeCount.centerXAnchor.constraint(equalTo: dislikeWrapper.centerXAnchor).isActive = true
        self.dislikeCount.bottomAnchor.constraint(equalTo: dislikeWrapper.bottomAnchor).isActive = true

        let dislikeTouch = UITapGestureRecognizer(target: self, action: #selector(self.dislikePressed(_:)))
        dislikeWrapper.addGestureRecognizer(dislikeTouch)

        let topView: UIView

        if (self.liveStream as? LiveScoringStream) != nil {
            let scoringView = ScoringView()
            self.streamDescription = scoringView
            scoringView.translatesAutoresizingMaskIntoConstraints = false;
            lightWrapper.addSubview(scoringView)

            scoringView.topAnchor.constraint(equalTo: dislikeWrapper.bottomAnchor, constant: 10).isActive = true
            scoringView.leadingAnchor.constraint(equalTo: lightWrapper.leadingAnchor, constant: 10).isActive = true
            scoringView.trailingAnchor.constraint(equalTo: lightWrapper.trailingAnchor, constant: -10).isActive = true

            topView = scoringView

        } else {
            let description = GeneralDescription(10)
            self.streamDescription = description
            description.translatesAutoresizingMaskIntoConstraints = false;
            lightWrapper.addSubview(description)

            description.backgroundColor = Colors.darkBackground
            description.topAnchor.constraint(equalTo: dislikeWrapper.bottomAnchor, constant: 10).isActive = true
            description.leadingAnchor.constraint(equalTo: lightWrapper.leadingAnchor, constant: 10).isActive = true
            description.trailingAnchor.constraint(equalTo: lightWrapper.trailingAnchor, constant: -10).isActive = true

            topView = description
        }
        self.streamDescription?.update(stream: self.liveStream)

        self.chatContainer.backgroundColor = .red
        self.chatContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.chatContainer)

        self.chatContainer.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 5).isActive = true
        self.chatContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.chatContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        self.chatContainer.layer.cornerRadius = 5
        self.chatContainer.backgroundColor = Colors.darkBackground

        let chatTouch = UITapGestureRecognizer(target: self, action: #selector(self.chatClicked(_:)))
        self.chatContainer.addGestureRecognizer(chatTouch)

        self.chatText.translatesAutoresizingMaskIntoConstraints = false
        self.chatText.numberOfLines = 0
        self.chatText.lineBreakMode = .byWordWrapping
        self.chatContainer.addSubview(self.chatText)

        self.chatText.leadingAnchor.constraint(equalTo: self.chatContainer.leadingAnchor, constant: 5).isActive = true
        self.chatText.topAnchor.constraint(equalTo: self.chatContainer.topAnchor, constant: 5).isActive = true
        self.chatText.trailingAnchor.constraint(equalTo: self.chatContainer.trailingAnchor, constant: 5).isActive = true
        self.chatText.text = "Join the chat"
        self.chatText.textColor = .white
        self.chatText.textAlignment = .center
        self.chatText.font = .systemFont(ofSize: 20)

        let chatOpenedStatic = UILabel()
        chatOpenedStatic.translatesAutoresizingMaskIntoConstraints = false

        self.chatContainer.addSubview(chatOpenedStatic)
        chatOpenedStatic.topAnchor.constraint(equalTo: self.chatText.bottomAnchor, constant: 5).isActive = true
        chatOpenedStatic.leadingAnchor.constraint(equalTo: self.chatText.leadingAnchor, constant: 5).isActive = true
        chatOpenedStatic.bottomAnchor.constraint(equalTo: self.chatContainer.bottomAnchor, constant: -5).isActive = true
        chatOpenedStatic.font = .systemFont(ofSize: 10)
        chatOpenedStatic.text = "Chat joined: "
        chatOpenedStatic.textColor = .white

        self.chatOpened.translatesAutoresizingMaskIntoConstraints = false
        self.chatOpened.text = "false"

        self.chatContainer.addSubview(self.chatOpened)
        self.chatOpened.topAnchor.constraint(equalTo: self.chatText.bottomAnchor, constant: 5).isActive = true
        self.chatOpened.leadingAnchor.constraint(equalTo: chatOpenedStatic.trailingAnchor, constant: 5).isActive = true
        self.chatOpened.bottomAnchor.constraint(equalTo: self.chatContainer.bottomAnchor, constant: -5).isActive = true
        self.chatOpened.font = .systemFont(ofSize: 10)

        let chatStatusStatic = UILabel()
        chatStatusStatic.translatesAutoresizingMaskIntoConstraints = false
        self.chatContainer.addSubview(chatStatusStatic)

        self.chatStatus.translatesAutoresizingMaskIntoConstraints = false
        self.chatContainer.addSubview(self.chatStatus)

        chatStatusStatic.trailingAnchor.constraint(equalTo: self.chatStatus.leadingAnchor, constant: -5).isActive = true
        chatStatusStatic.topAnchor.constraint(equalTo: chatOpened.topAnchor).isActive = true
        chatStatusStatic.bottomAnchor.constraint(equalTo: chatOpened.bottomAnchor).isActive = true
        chatStatusStatic.font = .systemFont(ofSize: 10)
        chatStatusStatic.text = "Chat status: "
        chatStatusStatic.textColor = .white

        self.chatStatus.trailingAnchor.constraint(equalTo: chatContainer.trailingAnchor, constant: -5).isActive = true
        self.chatStatus.topAnchor.constraint(equalTo: chatOpened.topAnchor).isActive = true
        self.chatStatus.bottomAnchor.constraint(equalTo: chatOpened.bottomAnchor).isActive = true
        self.chatStatus.font = .systemFont(ofSize: 10)
    }

    /**
      A user hit the like button, therefore we send an update to the server
      The update from the server with the new numbers does not come directly but with the next update cycle
      therefore we adjust the numbers internally until the update arrives to show the user immediate feedback
     -Parameter gestureRecognizer:
     */
    @objc private func likePressed(_ gestureRecognizer: UITapGestureRecognizer) {
        let ratingError = Mycrocast.shared.rating.like(streamId: self.liveStream.id)
        if let error = ratingError {
            print(error)
        }
    }

    /**
     The user selected the dislike
     The update from the server with the new numbers does not come directly but with the next update cycle
     therefore we adjust the numbers internally until the update arrives to show the user immediate feedback
     - Parameter gestureRecognizer:
     */
    @objc private func dislikePressed(_ gestureRecognizer: UITapGestureRecognizer) {
        let ratingError = Mycrocast.shared.rating.dislike(streamId: self.liveStream.id)
        if let error = ratingError {
            print(error)
        }
    }

    /**
     Move to the chat of this stream
     - Parameter gestureRecognizer:
     */
    @objc private func chatClicked(_ gestureRecognizer: UITapGestureRecognizer) {
        let chatController = ChatController(self.liveStream.id)
        self.navigationController?.pushViewController(chatController, animated: true)
    }

    private func updateView(stream: LiveStream) {
        DispatchQueue.main.async {
            self.streamDescription?.update(stream: stream)

            self.listenerCount.text = String(stream.listeners)
            self.likeCount.text = String(stream.likes)
            self.dislikeCount.text = String(stream.dislikes)

            self.likeButton.tintColor = .white
            self.dislikeButton.tintColor = .white

            if (stream.myStreamRating == UserStreamRating.negative) {
                self.dislikeButton.tintColor = .blue
            }

            if (stream.myStreamRating == UserStreamRating.positive) {
                self.likeButton.tintColor = .blue
            }
        }
    }

    func onStreamAdded(stream: LiveStream) {
        // not of interest here
        // but could show an information about that a new stream is available
    }

    func onStreamUpdated(stream: LiveStream) {
        // has our current stream been updated?
        if (stream.id == self.liveStream.id) {
            self.liveStream = stream
            self.updateView(stream: stream)
        }
    }

    func onStreamRemoved(stream: LiveStream) {
        // has our stream been removed -> the streamer stopped
        // therefore we could move back or display something meaningful
        // we currently just leave the view

        if (stream.id == self.liveStream.id) {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func onMessage(_ message: Message) {
        // not of interest here
    }

    /**
     Update the state of the chatroom if the current stream is the stream for which the update occurred
     - Parameters:
       - streamId: the if of the stream from where the chatroom changed itself
       - status: the new status of the chatroom
     */
    func onChatStatusChanged(_ streamId: Int, status: ChatStatus) {
        if (self.liveStream.id == streamId) {
            DispatchQueue.main.async {
                self.chatStatus.text = status == .enabled ? "enabled" : "disabled"
            }
        }
    }
}
