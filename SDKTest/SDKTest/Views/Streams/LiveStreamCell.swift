import Foundation
import UIKit
import MycrocastSDK

/**
 This view element represents a single live stream for a single streamer that is currently online from your club
 This is used in the overview stackview showing all currently available streams.

 Hitting the play button will start the connection process to the stream, selecting any other place will navigate to
 the details view of this stream
 */
class LiveStreamCell: UIView {

    private let mainSpacing: CGFloat = 10

    private let logo: UIImageView = UIImageView()
    private let title: UILabel = UILabel()
    private let streamDescription: UILabel = UILabel()

    private let listener: LabelWithHint = LabelWithHint(true)
    private let genre: LabelWithHint = LabelWithHint(true)
    private let language: LabelWithHint = LabelWithHint(false)

    private let playButton: PlayButton = PlayButton()
    private var stream: LiveStream?

    var cellCallback: ((LiveStream) -> ())?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        self.createViews()

        self.backgroundColor = Colors.lightBackground
        self.layer.cornerRadius = 15
    }

    func createViews() {
        self.logo.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.logo)

        self.logo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: mainSpacing).isActive = true
        self.logo.topAnchor.constraint(equalTo: self.topAnchor, constant: mainSpacing).isActive = true
        self.logo.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.logo.widthAnchor.constraint(equalToConstant: 50).isActive = true

        self.title.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(self.title)

        self.title.textColor = .white
        self.title.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        self.title.leadingAnchor.constraint(equalTo: self.logo.trailingAnchor, constant: mainSpacing).isActive = true
        self.title.topAnchor.constraint(equalTo: self.logo.topAnchor).isActive = true
        self.title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -mainSpacing).isActive = true

        self.streamDescription.textColor = .gray
        self.streamDescription.font = UIFont.systemFont(ofSize: 14)
        self.streamDescription.translatesAutoresizingMaskIntoConstraints = false;
        self.streamDescription.numberOfLines = 0
        self.streamDescription.lineBreakMode = .byWordWrapping
        self.addSubview(self.streamDescription)

        self.streamDescription.topAnchor.constraint(equalTo: self.title.bottomAnchor).isActive = true
        self.streamDescription.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
        self.streamDescription.trailingAnchor.constraint(equalTo: self.title.trailingAnchor, constant: mainSpacing).isActive = true

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wrapper)

        wrapper.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
        wrapper.trailingAnchor.constraint(equalTo: self.title.trailingAnchor).isActive = true
        wrapper.topAnchor.constraint(equalTo: self.streamDescription.bottomAnchor, constant: mainSpacing).isActive = true

        self.listener.updateHint(hint: "Listener")
        self.listener.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(self.listener)

        self.listener.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor).isActive = true
        self.listener.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -2).isActive = true
        self.listener.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: 2).isActive = true
        self.listener.widthAnchor.constraint(equalTo: wrapper.widthAnchor, multiplier: 0.33).isActive = true

        self.genre.updateHint(hint: "Genre")
        self.genre.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(self.genre)

        self.genre.leadingAnchor.constraint(equalTo: self.listener.trailingAnchor).isActive = true
        self.genre.topAnchor.constraint(equalTo: self.listener.topAnchor).isActive = true
        self.genre.widthAnchor.constraint(equalTo: self.listener.widthAnchor).isActive = true

        self.language.updateHint(hint: "Language")
        self.language.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(self.language)

        self.language.leadingAnchor.constraint(equalTo: self.genre.trailingAnchor).isActive = true
        self.language.topAnchor.constraint(equalTo: self.listener.topAnchor).isActive = true
        self.language.widthAnchor.constraint(equalTo: self.listener.widthAnchor).isActive = true

        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.playButton)

        self.playButton.centerXAnchor.constraint(equalTo: self.listener.centerXAnchor, constant: 10).isActive = true
        self.playButton.topAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: mainSpacing).isActive = true
        self.playButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -mainSpacing).isActive = true

        self.playButton.paused()
        self.playButton.callback = self.onPlayUpdate

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onCellClicked(_:)))
        self.addGestureRecognizer(gestureRecognizer)
    }

    /**
     Update the view after we received an update from the sdk that something changed,
     this could for example be the listener count etc
     - Parameter stream: - the stream with the new information
     */
    func updateView(stream: LiveStream) {

        self.stream = stream
        self.title.text = stream.streamer.streamerName
        self.streamDescription.text = stream.title

        self.listener.updateValue(value: String(stream.listeners))
        self.genre.updateValue(value: stream.genre)
        self.language.updateValue(value: stream.language.native)

        if (Mycrocast.shared.sessionControl.currentPlaying(streamId: stream.id)) {
            self.playButton.playing()
        } else {
            self.playButton.paused()
        }

        if let logo = stream.logo() {
            self.logo.downloaded(from: logo)
        }
    }

    private func onPlayUpdate(_ state: Bool) {
        if let stream = self.stream {
            if (state) {
                AppState.shared.audioState.play(stream)
                return;
            }
            AppState.shared.audioState.stop()
        }
    }

    @objc private func onCellClicked(_ gestureRecognizer: UITapGestureRecognizer) {
        if let stream = self.stream {
            self.cellCallback?(stream)
        }
    }
}
