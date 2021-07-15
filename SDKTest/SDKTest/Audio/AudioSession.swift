import Foundation
import MycrocastSDK
import AVFoundation

/**
 Example class representing a single audio session, meaning the play of
 a stream.
 This class reacts on stream changes and advertisement plays
 */
class AudioSession: StreamSessionDelegate, AdvertisementDelegate {

    private let adPlayManager: AdPlayManager
    private let streamPlayer: StreamPlayer
    private let muteMusicPlayer: MuteMusicAudioPlayer

    private let sessionControl: SessionControl
    private let advertisements: Advertisements

    private let stream: LiveStream

    init(_ stream: LiveStream) {
        self.adPlayManager = AdPlayManager(AdvertisementPlayer())
        self.streamPlayer = StreamPlayer()
        self.muteMusicPlayer = MuteMusicAudioPlayer()

        self.sessionControl = Mycrocast.shared.sessionControl
        self.advertisements = Mycrocast.shared.advertisements
        self.stream = stream

        self.advertisements.addObserver(advertisementDelegate: self)
        self.sessionControl.addObserver(streamDelegate: self)

    }

    /**
     We are receiving session updates from the process of connecting to stop
     Currently this is only printed for debugging but could be used to inform the user in detail
     what the current state is
     - Parameter state:
     */
    func onSessionStateUpdate(_ state: SessionState) {
        print(state)
    }

    /**
     We received a new audio package, we just schedule it for play
     - Parameters:
       - data: the new audio package
       - duration: the duration of the audio package
     */
    func onAudioDataAvailable(data: AVAudioPCMBuffer, duration: Int) {
        self.streamPlayer.play(data)
    }

    /**
     We received a push that new advertisements are available, we play
     them until no further ads are present
     */
    func onAdvertisementAvailable() {
        if let advertisement = self.advertisements.getAdvertisement() {
            self.adPlayManager.playAdvertisement(advertisement) { success in
                self.onAdvertisementAvailable()
            }
        } else {
            self.adPlayManager.noMoreAds()
        }
    }

    /**
     The streamer muted himself, if this is the stream we are currently in progress of playing,
     we want to start playing the mute music
     otherwise we can ignore it here
     - Parameter stream: the stream where the streamer muted himself
     */
    func streamerMuted(_ stream: LiveStream) {
        if (self.stream.id == stream.id) {
            do {
                try self.muteMusicPlayer.playFromUrl(url: stream.muteMusicUrl)
            } catch {

            }
        }
    }

    /**
     The streamer unmuted himself, if this is the stream we are currently playing we stop playing the mute music
     otherwise we can ignore it
     - Parameter stream: the stream from which the streamer unmuted himself
     */
    func streamerUnMuted(_ stream: LiveStream) {
        if (self.stream.id == stream.id) {
            self.muteMusicPlayer.stop()
        }
    }

    /**
     We start the connection process to the live stream
      If the stream is currently muted we start playing the mute music
     */
    func play() {
        self.sessionControl.play(streamId: self.stream.id)
        if (self.stream.muted) {
            do {
                try self.muteMusicPlayer.playFromUrl(url: self.stream.muteMusicUrl)
            } catch {
            }
        }
    }

    /**
     We stop the audio stream
     */
    func stop() {
        self.sessionControl.stop()
        self.advertisements.removeObserver(advertisementDelegate: self)
        self.sessionControl.removeObserver(streamDelegate: self)
        self.muteMusicPlayer.stop()
    }

    /**
     Determine if the id of the passed stream is the id of the stream we are currently playing
     - Parameter stream: - the stream
     - Returns: true if we are currently playing the stream, false otherwise
     */
    func currentStream(_ stream: Int) -> Bool {
        return self.sessionControl.currentPlaying(streamId: stream)
    }

    /**
     An advertisement was clicked
     - Parameter ad: the ad that was clicked
     */
    func advertisementClicked(_ ad: MycrocastAdvertisement) {
        Mycrocast.shared.advertisements.onAdBannerClicked(self.stream, advertisement: ad)
    }
}
