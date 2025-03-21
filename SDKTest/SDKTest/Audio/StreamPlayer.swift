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
    private let ratio: Double

    init() {
        self.audioEngine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()
        do {
            self.outputFormat = self.audioEngine.mainMixerNode.outputFormat(forBus: 0)
            self.inputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 48000, channels: AVAudioChannelCount(1), interleaved: false)!

            self.converter = AVAudioConverter(from: inputFormat, to: outputFormat)!
            self.ratio =   outputFormat.sampleRate / inputFormat.sampleRate

            configureAudioSession()

            self.audioEngine.attach(self.playerNode)
            self.audioEngine.connect(self.playerNode, to: self.audioEngine.mainMixerNode, format: nil)
            self.audioEngine.prepare()
            try self.audioEngine.start()
            self.playerNode.prepare(withFrameCount: AVAudioFrameCount(960))
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
        let capacity = 960 * self.ratio
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: self.outputFormat, frameCapacity: AVAudioFrameCount(capacity))!

        var error: NSError? = nil
       let result =  self.converter.convert(to: outputBuffer, error: &error) { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        outputBuffer.frameLength = AVAudioFrameCount(capacity)
        
        self.playerNode.scheduleBuffer(outputBuffer)
        self.playerNode.play()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setPreferredSampleRate(48000)
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
    
    func setVolume(volume: Float) {
        self.playerNode.volume = volume
    }
}
