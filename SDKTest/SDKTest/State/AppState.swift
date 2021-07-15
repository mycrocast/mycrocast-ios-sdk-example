import Foundation
import MycrocastSDK

/**
 Example app state containing the audio state and also receiving
 any mycrocast sdk errors, the errors are only printed and could be processed further if required
 */
class AppState: ErrorReceiving {

    static let shared = AppState()

    var audioState: AudioState

    private init() {
        self.audioState = AudioState()

        Mycrocast.shared.sessionControl.addObserver(errorDelegate: self)
    }

    deinit {
        Mycrocast.shared.sessionControl.removeObserver(errorDelegate: self)
    }

    func onMycrocastError(_ error: MycrocastError) {
        print(error)
    }
}
