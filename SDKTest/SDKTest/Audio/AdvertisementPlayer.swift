import Foundation
import AVFoundation
import MycrocastSDK

/**
 Example class handling the audio play of an advertisement spot
 */
class AdvertisementPlayer {

    private var audioPlayer: AVPlayer?
    private var didPlayNotification: Any?

    /**
     Play an advertisement. An advertisement is just a remote url to be played.
     After the play has finished we notify the caller.
     his request an active audio session in case we do not have one yet

     - Parameters:
       - advertisement: the advertisement to play
       - onEnd: callback to execute when the play is done
     - Throws:
     */
    func playAd(advertisement: MycrocastAdvertisement, onEnd: @escaping (Bool) -> ()) throws {
        let url = URL(string: advertisement.audioFileUrl)
        guard let audioUrl = url else {
            onEnd(false)
            return;
        }
        self.audioPlayer = AVPlayer(url: audioUrl)
        self.audioPlayer?.automaticallyWaitsToMinimizeStalling = false

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
        try audioSession.setCategory(.playback)

        self.didPlayNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: nil, queue: nil) { notification in
            onEnd(true)
            NotificationCenter.default.removeObserver(self.didPlayNotification as Any)
        }
        self.audioPlayer?.play()
    }

    /**
     Stop playing the current advertisement, this could be due to changing to a different stream
     A current stream should not be pausable when an advertisement is playing
     */
    func stopPlaying() {
        if let player = self.audioPlayer {
            if (player.timeControlStatus == .playing) {
                player.pause()
                NotificationCenter.default.removeObserver(self.didPlayNotification as Any)
            }
        }
    }
}
