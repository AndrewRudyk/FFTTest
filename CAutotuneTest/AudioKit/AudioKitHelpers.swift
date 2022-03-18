//
//  AudioKitHelpers.swift
//  CAutotuneTest
//
//  Created by Rudyk Andrey on 17.03.22.
//

import AudioToolbox
import AVFoundation
import CoreAudio
import Accelerate

public extension DSPSplitComplex {
    /// Initialize a DSPSplitComplex with repeating values for real and imaginary splits
    ///
    /// - Parameters:
    ///   - initialValue: value to set elements to
    ///   - count: number of real and number of imaginary elements
    init(repeating initialValue: Float, count: Int) {
        let real = [Float](repeating: initialValue, count: count)
        let realp = UnsafeMutablePointer<Float>.allocate(capacity: real.count)
        realp.assign(from: real, count: real.count)

        let imag = [Float](repeating: initialValue, count: count)
        let imagp = UnsafeMutablePointer<Float>.allocate(capacity: imag.count)
        imagp.assign(from: imag, count: imag.count)

        self.init(realp: realp, imagp: imagp)
    }

    /// Initialize a DSPSplitComplex with repeating values for real and imaginary splits
    ///
    /// - Parameters:
    ///   - repeatingReal: value to set real elements to
    ///   - repeatingImag: value to set imaginary elements to
    ///   - count: number of real and number of imaginary elements
    init(repeatingReal: Float, repeatingImag: Float, count: Int) {
        let real = [Float](repeating: repeatingReal, count: count)
        let realp = UnsafeMutablePointer<Float>.allocate(capacity: real.count)
        realp.assign(from: real, count: real.count)

        let imag = [Float](repeating: repeatingImag, count: count)
        let imagp = UnsafeMutablePointer<Float>.allocate(capacity: imag.count)
        imagp.assign(from: imag, count: imag.count)

        self.init(realp: realp, imagp: imagp)
    }

    func deallocate() {
        realp.deallocate()
        imagp.deallocate()
    }
}
