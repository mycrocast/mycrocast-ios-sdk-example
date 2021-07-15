import Foundation
import AVFoundation;

/**
 This is an example class of playing the live audio stream.
 The live audio stream data is received in AVAUDIOPCMBuffer with 48000khz and 16 pcm data and 960 frames of data
 And played with an AVAudioPlayerNode and AVAudioEngine

 The StreamPlayer reacts on updates for advertisement plays and sets the volume to zero when an advertisement is
 started and afterwards resets the volume to the previous level
 */
public class StreamPlayer: AdPlayStateChangeDelegate {

    private let audioEngine: AVAudioEngine
    private let playerNode: AVAudioPlayerNode
    private let converter: AVAudioConverter

    private let inputFormat: AVAudioFormat
    private let outputFormat: AVAudioFormat

    init() {
        self.audioEngine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
        do {
            let _ = self.audioEngine.mainMixerNode
            self.outputFormat = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
            self.inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 48000, channels: AVAudioChannelCount(1), interleaved: false)!

            self.converter = AVAudioConverter(from: inputFormat, to: outputFormat)!
            configureAudioSession()

            self.audioEngine.attach(self.playerNode)
            self.audioEngine.connect(self.playerNode, to: self.audioEngine.mainMixerNode, format: nil)
            self.audioEngine.prepare()
            try self.audioEngine.start()
        } catch {
            print("Player error: \(error)")
        }

        Broadcaster.register(AdPlayStateChangeDelegate.self, observer: self)
    }

    deinit {
        Broadcaster.unregister(AdPlayStateChangeDelegate.self, observer: self)
    }

    /**
     Schedule the play of a single buffer of data
     - Parameter buffer:
     */
    func play(_ buffer: AVAudioPCMBuffer) {
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: self.outputFormat, frameCapacity: 960)!

        self.converter.convert(to: outputBuffer, error: nil) { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        self.playerNode.scheduleBuffer(outputBuffer)
        self.playerNode.play()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }

    /**
     An advertisement play started, therefore we reduce the volume to zero
     */
    func onAdPlayStarted() {
        self.playerNode.volume = 0
    }

    /**
     Advertisement finished, restore volume to hear the streamer again
     */
    func onAdPlayFinished() {
        self.playerNode.volume = 1
    }
}
