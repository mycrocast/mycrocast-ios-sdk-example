import Foundation
import AVFoundation

/**
 Example class for playing the mute music.
 This music should be played as soon as the streamer muted himself and until the streamer
 unmutes again.
 The audio needs to be looped in case the mute phase is longer than the audio file
 The url to be played is included in the liveStream
 */
class MuteMusicAudioPlayer: AdPlayStateChangeDelegate {

    var audioLooper: AVPlayerLooper?;
    var queuePlayer: AVQueuePlayer?;

    init() {
        Broadcaster.register(AdPlayStateChangeDelegate.self, observer: self)
    }

    /**
     We start the play of the mute music from the provided url in a loop
     - Parameter url: the url from where to play from
     - Throws:
     */
    func playFromUrl(url: String) throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setActive(true)
        try audioSession.setCategory(.playback)

        if let url = URL(string: url) {
            let item = AVPlayerItem(url: url)
            self.queuePlayer = AVQueuePlayer(playerItem: item)
            self.audioLooper = AVPlayerLooper(player: queuePlayer!, templateItem: item)
            self.queuePlayer?.play()
        }
    }

    func stop() {
        self.queuePlayer?.pause();
        self.audioLooper = nil;
        self.queuePlayer = nil
        Broadcaster.unregister(AdPlayStateChangeDelegate.self, observer: self)
    }

    /**
     Reduce the volume of the audio as an advertisement play started
     */
    func onAdPlayStarted() {
        self.queuePlayer?.volume = 0
    }

    /**
     Increase volume of the audio again as the advertisement is done
     */
    func onAdPlayFinished() {
        self.queuePlayer?.volume = 1
    }
}