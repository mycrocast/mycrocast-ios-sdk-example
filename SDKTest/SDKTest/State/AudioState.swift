import Foundation
import MycrocastSDK

/**
 Example class representing the audio state of the app.
 From here we start to play the stream, and react to any stream changes.
 If the stream we are currently playing is ending, we clear the audio play
 */
class AudioState: StreamsDelegate {
    var audioSession: AudioSession?

    init() {
        Mycrocast.shared.streams.addObserver(self)
    }

    deinit {
        Mycrocast.shared.streams.removeObserver(self)
    }

    func play(_ stream: LiveStream) {
        if let session = self.audioSession {
            session.stop()
            self.audioSession = nil
        }
        self.audioSession = AudioSession(stream)
        self.audioSession?.play()
    }

    func advertisementClicked(_ ad: MycrocastAdvertisement) {
        if let session = self.audioSession {
            session.advertisementClicked(ad)
        }
    }

    func stop() {
        if let session = self.audioSession {
            session.stop()
            self.audioSession = nil
        }
    }

    func onStreamAdded(stream: LiveStream) {
    }

    func onStreamUpdated(stream: LiveStream) {
    }

    func onStreamRemoved(stream: LiveStream) {
        if let session = self.audioSession {
            if (session.currentStream(stream.id)) {
                session.stop()
                self.audioSession = nil
            }
        }
    }
}
