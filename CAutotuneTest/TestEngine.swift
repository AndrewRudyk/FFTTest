//
//  TestEngine.swift
//  CAutotuneTest
//
//  Created by Rudyk Andrey on 21.02.22.
//

import Foundation
import AVFoundation
import Accelerate

class TestEngine {
    
    private var audioEngine = AVAudioEngine()
    private var audioPlayer = AVAudioPlayerNode()
    
    func start() {

        try? AVAudioSession.sharedInstance().setCategory(.playback)

        let audioUrl = Bundle.main.url(forResource: "demo1", withExtension: "m4a")!
//        let audioUrl = Bundle.main.url(forResource: "1.C4_261.63hz", withExtension: "mp3")!
        let audioFile = try! AVAudioFile(forReading: audioUrl)

        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputUrl = documentURL.appendingPathComponent("output.caf")
        let outputFile = try! AVAudioFile(forWriting: outputUrl, settings: audioPlayer.outputFormat(forBus: 0).settings)
        
        audioEngine.attach(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)

        audioPlayer.installTap(onBus: 0, bufferSize: 4096, format: nil) { buffer, time in
            // way 1 - from Cfiles folder
//            instantiateAutotalentInstance(44100)
            
            
            // way 2
//            self.processAudioData(buffer: buffer)
            
            
            // way 3
//            let bin = FFTTap.FFTSetupForBinCount(binCount: .fourThousandAndNintySix)
            let bin = FFTTap.FFTSetupForBinCount(binCount: .twoThousandAndFortyEight)
            let fftData = FFTTap.performFFT(buffer: buffer, fftSetupForBinCount: bin)
            print("---------------------------")
//            print(fftData)
//            let newData = fftData.filter{$0 >= 0.1}
            let newData = fftData.compactMap { number in
                return number >= 0.1 ? number : 0
            }
            print(newData)
            
            let inversedFftData = FFTTap.inverseFFT(fftData: newData)
            let newBuffer = Self.createPCMBuffer(inversedFftData)
            
            try? outputFile.write(from: newBuffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        audioPlayer.play()
    }
    
    func stop() {
        audioEngine.stop()
        audioPlayer.stop()
        audioPlayer.removeTap(onBus: 0)
    }
    
    
    // MARK: - Helpers
    static func createPCMBuffer(_ signal: [Float]) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(signal.count))
        guard let channelData = buffer?.floatChannelData else { return buffer! }
        
        for i in 0..<signal.count {
            channelData[0][i] = signal[i]
        }
        
        buffer?.frameLength = (buffer?.frameCapacity)!
        
        return buffer!
    }
    
    
    
    // MARK: - from
    // https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
    private var prevRMSValue : Float = 0.3
    //fft setup object for 1024 values going forward (time domain -> frequency domain)
    private let fftSetup = vDSP_DFT_zop_CreateSetup(nil, 1024, vDSP_DFT_Direction.FORWARD)

    private func processAudioData(buffer: AVAudioPCMBuffer){
        guard let channelData = buffer.floatChannelData?[0] else {return}
        let frames = buffer.frameLength
        
        //rms
        let rmsValue = SignalProcessing.rms(data: channelData, frameLength: UInt(frames))
        let interpolatedResults = SignalProcessing.interpolate(current: rmsValue, previous: prevRMSValue)
        prevRMSValue = rmsValue
        
        //pass values to the audiovisualizer for the rendering
//        for rms in interpolatedResults {
//            audioVisualizer.loudnessMagnitude = rms
//        }
        
        //fft
        let fftMagnitudes =  SignalProcessing.fft(data: channelData, setup: fftSetup!)

//        audioVisualizer.frequencyVertices = fftMagnitudes
    }
}

