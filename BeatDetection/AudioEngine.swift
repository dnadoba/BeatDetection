//
//  AudioEngine.swift
//  BeatDetection
//
//  Created by David Nadoba on 12.06.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import AVFoundation
import Foundation
import aubio
import Combine

class AudioEngine {
    let audioEngine = AVAudioEngine()
    let bpmSubject = CurrentValueSubject<Float, Never>(0)
    let onsetSubject = PassthroughSubject<(), Never>()
    
    func start() throws {
        
        let inputNode = audioEngine.inputNode
        let bus = 0
        
        let win_size: uint_t = 1024 * 2 //1024 * 8 // window size
        let hop_size: uint_t = win_size/4 // hop size
        let samplerate: uint_t = 44100 // samplerate
        // create some vectors
        let input = new_fvec(hop_size) // input buffer
        let pitch_out = new_fvec(1) // output candidates
        let tempo_out = new_fvec(1) // output candidates
        
        let pitch_o = new_aubio_pitch ("default", win_size, hop_size, samplerate);
        let tempo_o = new_aubio_tempo("default", win_size, hop_size, samplerate);
        print(inputNode.inputFormat(forBus: bus))
        
        var ringBuffer = Array<Float>()
        ringBuffer.reserveCapacity(.init(win_size))
        
        inputNode.installTap(onBus: bus, bufferSize: UInt32(hop_size), format: inputNode.inputFormat(forBus: bus)) {
            (buffer: AVAudioPCMBuffer, time: AVAudioTime) -> Void in
            guard let bufferPointer = buffer.floatChannelData?[0] else { return }
            
            for index in 0..<Int(buffer.frameLength) {
                ringBuffer.append(bufferPointer[index])
            }
            
            
            while ringBuffer.count >= Int(hop_size) {
                // copy audio buffer to buffer that aubio can use
                for index in 0..<Int(hop_size) {
                    input?.pointee.data[index] = ringBuffer[index]
                }
                ringBuffer.removeFirst(Int(hop_size))
                
                aubio_tempo_do(tempo_o, input, tempo_out)
                aubio_pitch_do(pitch_o, input, pitch_out)
                //print("out \(pitch_out!.pointee.data[0])")
                if (tempo_out!.pointee.data[0] != 0) {
                print("beat at \(aubio_tempo_get_last_ms(tempo_o))ms, \(aubio_tempo_get_last_s(tempo_o))s, frame \(aubio_tempo_get_last(tempo_o)), \(aubio_tempo_get_bpm(tempo_o)) bpm with confidence \(aubio_tempo_get_confidence(tempo_o))")
                    let bpm = aubio_tempo_get_bpm(tempo_o)
                    DispatchQueue.main.async {
                        self.bpmSubject.send(bpm)
                        self.onsetSubject.send(())
                    }
                }
            }
            
//            print("Lenght: \(length)")
//            print(buffer.frameLength, length)
//            print(sum)
            
           
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}
