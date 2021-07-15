import Foundation
import UIKit
import MycrocastSDK

/**
 This view represents the details view of a stream where the streamer selected the scoring mode
 In this mode the streamer provides 2 team names and can adjust the score for both teams at any given time

 This example view display both team names and the score in addition to the title and description provided by the streamer
 */
class ScoringView: UIView, DescriptionContaining {
    private let homeTeamName: UILabel = UILabel()
    private let homeTeamScore: UILabel = UILabel()

    private let guestTeamName: UILabel = UILabel()
    private let guestTeamScore: UILabel = UILabel()

    private let generalDescription: GeneralDescription = GeneralDescription(0)

    init() {
        super.init(frame: .zero)
        self.createViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createViews() {

        let scoringWrapper = UIView()
        scoringWrapper.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scoringWrapper)

        scoringWrapper.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scoringWrapper.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scoringWrapper.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true

        let homeWrapper = UIView()
        homeWrapper.translatesAutoresizingMaskIntoConstraints = false
        scoringWrapper.addSubview(homeWrapper)

        homeWrapper.topAnchor.constraint(equalTo: scoringWrapper.topAnchor).isActive = true
        homeWrapper.bottomAnchor.constraint(greaterThanOrEqualTo: scoringWrapper.bottomAnchor, constant: 5).isActive = true
        homeWrapper.leadingAnchor.constraint(equalTo: scoringWrapper.leadingAnchor, constant: 5).isActive = true
        homeWrapper.widthAnchor.constraint(equalTo: scoringWrapper.widthAnchor, multiplier: 0.4).isActive = true

        self.homeTeamName.translatesAutoresizingMaskIntoConstraints = false
        self.homeTeamName.textAlignment = .center
        self.homeTeamName.text = "home team"
        self.homeTeamName.textColor = .white

        homeWrapper.addSubview(self.homeTeamName)
        self.homeTeamName.topAnchor.constraint(equalTo: homeWrapper.topAnchor, constant: 5).isActive = true
        self.homeTeamName.leadingAnchor.constraint(equalTo: homeWrapper.leadingAnchor).isActive = true
        self.homeTeamName.trailingAnchor.constraint(equalTo: homeWrapper.trailingAnchor).isActive = true

        self.homeTeamScore.translatesAutoresizingMaskIntoConstraints = false
        self.homeTeamScore.textColor = .white
        self.homeTeamScore.textAlignment = .center
        self.homeTeamScore.text = "0"

        homeWrapper.addSubview(self.homeTeamScore)
        self.homeTeamScore.topAnchor.constraint(equalTo: self.homeTeamName.bottomAnchor, constant: 5).isActive = true
        self.homeTeamScore.bottomAnchor.constraint(greaterThanOrEqualTo: scoringWrapper.bottomAnchor, constant: 0).isActive = true
        self.homeTeamScore.leadingAnchor.constraint(equalTo: homeWrapper.leadingAnchor).isActive = true
        self.homeTeamScore.trailingAnchor.constraint(equalTo: homeWrapper.trailingAnchor).isActive = true

        let guestWrapper = UIView()
        guestWrapper.translatesAutoresizingMaskIntoConstraints = false
        scoringWrapper.addSubview(guestWrapper)

        guestWrapper.topAnchor.constraint(equalTo: scoringWrapper.topAnchor).isActive = true
        guestWrapper.bottomAnchor.constraint(greaterThanOrEqualTo: scoringWrapper.bottomAnchor, constant: 5).isActive = true
        guestWrapper.trailingAnchor.constraint(equalTo: scoringWrapper.trailingAnchor, constant: 5).isActive = true
        guestWrapper.widthAnchor.constraint(equalTo: scoringWrapper.widthAnchor, multiplier: 0.4).isActive = true

        self.guestTeamName.translatesAutoresizingMaskIntoConstraints = false
        self.guestTeamName.textColor = .white
        self.guestTeamName.textAlignment = .center
        self.guestTeamName.text = "guest team"

        guestWrapper.addSubview(self.guestTeamName)
        self.guestTeamName.topAnchor.constraint(equalTo: guestWrapper.topAnchor, constant: 5).isActive = true
        self.guestTeamName.leadingAnchor.constraint(equalTo: guestWrapper.leadingAnchor).isActive = true
        self.guestTeamName.trailingAnchor.constraint(equalTo: guestWrapper.trailingAnchor).isActive = true

        self.guestTeamScore.translatesAutoresizingMaskIntoConstraints = false
        self.guestTeamScore.textColor = .white
        self.guestTeamScore.textAlignment = .center
        self.guestTeamScore.text = "0"

        guestWrapper.addSubview(self.guestTeamScore)
        self.guestTeamScore.topAnchor.constraint(equalTo: self.guestTeamName.bottomAnchor, constant: 5).isActive = true
        self.guestTeamScore.bottomAnchor.constraint(equalTo: scoringWrapper.bottomAnchor).isActive = true
        self.guestTeamScore.leadingAnchor.constraint(equalTo: guestWrapper.leadingAnchor).isActive = true
        self.guestTeamScore.trailingAnchor.constraint(equalTo: guestWrapper.trailingAnchor).isActive = true

        let dividerWrapper = UIView()
        dividerWrapper.translatesAutoresizingMaskIntoConstraints = false

        scoringWrapper.addSubview(dividerWrapper)
        dividerWrapper.topAnchor.constraint(equalTo: homeWrapper.topAnchor).isActive = true
        dividerWrapper.leadingAnchor.constraint(equalTo: homeWrapper.trailingAnchor).isActive = true
        dividerWrapper.trailingAnchor.constraint(equalTo: guestWrapper.leadingAnchor).isActive = true
        dividerWrapper.bottomAnchor.constraint(equalTo: scoringWrapper.bottomAnchor, constant: 5).isActive = true

        let divider = UILabel()
        divider.text = "-"
        divider.textColor = .white
        divider.font = UIFont.systemFont(ofSize: 40)
        divider.translatesAutoresizingMaskIntoConstraints = false

        dividerWrapper.addSubview(divider)
        divider.centerXAnchor.constraint(equalTo: dividerWrapper.centerXAnchor).isActive = true
        divider.centerYAnchor.constraint(equalTo: dividerWrapper.centerYAnchor).isActive = true

        self.generalDescription.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.generalDescription)

        self.generalDescription.leadingAnchor.constraint(equalTo: scoringWrapper.leadingAnchor).isActive = true
        self.generalDescription.trailingAnchor.constraint(equalTo: scoringWrapper.trailingAnchor).isActive = true
        self.generalDescription.topAnchor.constraint(equalTo: scoringWrapper.bottomAnchor, constant: 5).isActive = true
        self.generalDescription.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }

    func update(stream: LiveStream) {
        if let scoring = stream as? LiveScoringStream {
            self.homeTeamScore.text = String(scoring.homeTeam.score)
            self.homeTeamName.text = scoring.homeTeam.name

            self.guestTeamName.text = scoring.guestTeam.name
            self.guestTeamScore.text = String(scoring.guestTeam.score)

            self.generalDescription.update(stream: stream)
        }
    }
}