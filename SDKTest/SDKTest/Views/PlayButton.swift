import Foundation
import UIKit
import MycrocastSDK

/**
 Just a helper visual class displaying a button with some margin and
 an icon provided by the mycrocast sdk
 */
class PlayButton: UIView {

    private let playImage: UIImage = MycrocastAssetProvider.play()
    private let pauseImage: UIImage = MycrocastAssetProvider.pause()

    private let playButton: UIImageView = UIImageView()
    private let action: UILabel = UILabel()

    private var isPlaying: Bool = false
    public var callback: ((Bool) -> ())?

    init() {
        super.init(frame: .zero)

        self.createViews()
        self.layer.cornerRadius = 20
        self.backgroundColor = Colors.darkBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createViews() {
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.image = self.playImage
        self.playButton.tintColor = .white
        self.addSubview(self.playButton)

        self.playButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        self.playButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
        self.playButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
        self.playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.playButton.widthAnchor.constraint(equalTo: self.playButton.heightAnchor, multiplier: 1).isActive = true

        self.action.textColor = .white
        self.action.font = UIFont.systemFont(ofSize: 20)
        self.action.textAlignment = .center
        self.action.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.action)
        self.action.leadingAnchor.constraint(equalTo: self.playButton.trailingAnchor, constant: 5).isActive = true
        self.action.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        self.action.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.action.widthAnchor.constraint(equalToConstant: 60).isActive = true

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        self.addGestureRecognizer(gestureRecognizer)
    }

    @objc func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if (self.isPlaying) {
            self.paused()
        } else {
            self.playing()
        }
        self.callback?(self.isPlaying)
    }

    func playing() {
        self.playButton.image = self.pauseImage
        self.action.text = "Pause"
        self.isPlaying = true
    }

    func paused() {
        self.playButton.image = self.playImage
        self.action.text = "Play"
        self.isPlaying = false
    }
}
