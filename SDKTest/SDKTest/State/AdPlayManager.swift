import Foundation
import MycrocastSDK

protocol AdPlayStateChangeDelegate {
    func onAdPlayStarted()
    func onAdPlayFinished()
}

/**
 Example class of handling the logic of advertisements with playing the audio and displaying the banner
 */
class AdPlayManager {
    private let advertisementPlayer: AdvertisementPlayer;
    private var playing: Bool = false
    
    private var currentAdBanner: AdvertisementView?
    
    init(_ advertisementPlayer: AdvertisementPlayer) {
        self.advertisementPlayer = advertisementPlayer
    }

    /**
     Start playing an advertisement by start playing the audio and also display the corresponding visual
      ad banner
     - Parameters:
       - advertisement: the advertisement to be played
       - playCallback:  the callback to execute when the advertisement finished playing
     */
    func playAdvertisement(_ advertisement: MycrocastAdvertisement, playCallback: @escaping (Bool) ->()) {
        do {
            if (!self.playing) {
                Broadcaster.notify(AdPlayStateChangeDelegate.self) {
                    (delegate: AdPlayStateChangeDelegate) in
                    delegate.onAdPlayStarted()
                }
            }
            
            self.playing = true
            try self.advertisementPlayer.playAd(advertisement: advertisement, onEnd: playCallback)
            self.showAdBanner(advertisement)
        } catch  {
            print(error)
        }
    }

    /**
     Show the advertisement banner for the advertisement
     - Parameter advertisement: the advertisement for this banner
     */
    private func showAdBanner(_ advertisement: MycrocastAdvertisement) {
        DispatchQueue.main.async {
            self.currentAdBanner?.removeFromSuperview()
            self.currentAdBanner = AdvertisementView()
            self.currentAdBanner?.translatesAutoresizingMaskIntoConstraints = false
            
            let view = AppDelegate.rootViewController!.view!
            view.addSubview(self.currentAdBanner!)
            
            self.currentAdBanner?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.currentAdBanner?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.currentAdBanner?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            self.currentAdBanner?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            
            self.currentAdBanner?.display(advertisement)
        }
    }

    /**
     There are no more advertisements we want to play, therefore we inform the system that
      we are done and remove the current advertisement banner
     */
    func noMoreAds() {
        self.playing = false
        Broadcaster.notify(AdPlayStateChangeDelegate.self) {
            (delegate: AdPlayStateChangeDelegate) in
            delegate.onAdPlayFinished()
            }
        DispatchQueue.main.async {
            self.currentAdBanner?.removeFromSuperview()
        }
    }
}
