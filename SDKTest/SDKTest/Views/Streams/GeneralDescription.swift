
import Foundation
import AVKit
import MycrocastSDK

protocol DescriptionContaining {
    func update(stream: LiveStream)
}

/**
 This view represents the details view of a general stream, meaning that
 during the stream creation the streamer did not select a scoring stream

 This view consist of the from the streamer provided title and description
 */
class GeneralDescription: UIView, DescriptionContaining {
    private let title: UILabel = UILabel()
    private let streamDescription: UILabel = UILabel()

    init(_ cornerRadius: Int) {
        super.init(frame: .zero)
        self.createViews(cornerRadius)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createViews(_ cornerRadius: Int) {

        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.backgroundColor = Colors.darkBackground

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .gray
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        descriptionLabel.text = "Description"

        self.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true

        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.textColor = .white

        self.addSubview(self.title)
        self.title.text = "title"
        self.title.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15).isActive = true
        self.title.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        self.title.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true

        self.streamDescription.translatesAutoresizingMaskIntoConstraints = false
        self.streamDescription.textColor = .white
        self.streamDescription.numberOfLines = 0
        self.streamDescription.lineBreakMode = .byWordWrapping

        self.addSubview(self.streamDescription)
        self.streamDescription.text = "description"
        self.streamDescription.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: 5).isActive = true
        self.streamDescription.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        self.streamDescription.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true
        self.streamDescription.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    func update(stream: LiveStream) {
        self.title.text = stream.title
        self.streamDescription.text = stream.description
    }
}