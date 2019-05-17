//
//  Decoder.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import UIKit
import CoreGraphics

class Decoder {
    
    //----------------------------------------------------------------------
    
    //Creating main variables for decryption
    private var current_shift: Int = 0
    private var bitsCharacter: UInt32 = 0
    private var data: String?
    private var step: UInt32 = 0
    private var length: UInt32 = 0
  
    //----------------------------------------------------------------------
    
    //Main public function to decode an UIImage (returns a String)
    public func decode(image: UIImage) -> String? {
    
        message_to_debugger(message: "Started decryption #00")
    
    if hasData(in: image),
        let string = self.data, String(string.prefix(Defaults.data_prefix.count)) == Defaults.data_prefix && String(string.suffix(Defaults.data_suffix.count)) == Defaults.data_suffix {
        message_to_debugger(message: "Started first if #01")
            let endIndex = string.index(string.endIndex, offsetBy: -Defaults.data_suffix.count)
            let startIndex = string.index(string.startIndex, offsetBy: Defaults.data_prefix.count)
      
            if let data = Data(base64Encoded: String(string[startIndex..<endIndex])) {
                message_to_debugger(message: "Successfully decrypted #02")
                return String(data: data, encoding: .utf8)
            } else {
                message_to_debugger(message: "Returned nil value #03")
                return nil
            }
      
    } else {
        message_to_debugger(message: "Returned nil value #04")
        return nil
        }
    }
    //----------------------------------------------------------------------
    
    private func hasData(in image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else {
            message_to_debugger(message: "Returned false #05")
            return false }
        let width = cgImage.width
        let height = cgImage.height
        let size = width * height
    
        let pixelPointer = calloc(size, MemoryLayout<UInt32>.size)
    
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), CGBitmapInfo.byteOrder32Big]
    
        guard let canvas = CGContext(data: pixelPointer, width: width, height: height, bitsPerComponent: Defaults.bits_per_component, bytesPerRow: Defaults.bytes_per_pixel * width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            message_to_debugger(message: "Returned false #06")
            return false }
    
        canvas.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
        guard let pointer = pixelPointer else {
            message_to_debugger(message: "Returned false #07")
            return false }
    
        searchData(in: pointer, size: size)

        message_to_debugger(message: "Returned self.hasData #08")
        return self.hasData()
    }

    //----------------------------------------------------------------------
    
    private func searchData(in pixels: UnsafeMutableRawPointer, size: Int) {
        reset()
    
        var pixelPosition = 0
    
        let pixelArray = Array(UnsafeBufferPointer(start: pixels.assumingMemoryBound(to: UInt32.self), count: size))

        while pixelPosition < Defaults.size_of_info_lenght {
            self.getData(pixel: pixelArray[pixelPosition])
            pixelPosition += 1
        }
    
        reset()
    
        let pixelsToHide = Int(self.length) * Defaults.bits_per_component
    
        let ratio = (size - Int(pixelPosition)) / pixelsToHide
    
        let salt = ratio
    

        while pixelPosition <= size {
            getData(pixel: pixelArray[pixelPosition])
            pixelPosition += salt
      
            if (self.data?.suffix(Defaults.data_suffix.count) ?? "") == Defaults.data_suffix {
                break
            }
        }
    }
  
    private func getData(pixel: UInt32) {
        getData(color: Utilities.Color(pixel, shift: Utilities.color_to_step(step: self.step).rawValue))
    }
    
    private func getData(color: UInt32) {
        if self.current_shift == 0 {
            let bit: UInt32 = color & 1
            self.bitsCharacter = (bit << self.current_shift) | UInt32(self.bitsCharacter)
      
            if self.step < Defaults.size_of_info_lenght {
                getLength()
            } else {
                getCharacter()
            }
      
            self.current_shift = Defaults.initial_shift
        } else {
            let bit: UInt32 = color & 1
            self.bitsCharacter = (bit << self.current_shift) | UInt32(self.bitsCharacter)
            self.current_shift -= 1
        }
    
        self.step += 1
    }
  
    private func getLength() {
        self.length = Utilities.add_bits(number1: self.length, number2: UInt32(self.bitsCharacter), shift: Int(self.step) % (Defaults.bits_per_component - 1))
    
        self.bitsCharacter = 0
    }
  
    private func getCharacter() {
        let character = String(format: "%c", arguments: [self.bitsCharacter])
    
        self.bitsCharacter = 0
    
        if let data = self.data {
            self.data = "\(data)\(character)"
        } else {
            self.data = character
        }
    }
  
    private func hasData() -> Bool {
        return (self.data?.count ?? 0) > 0
            && String(self.data?.prefix(Defaults.data_prefix.count) ?? "") == Defaults.data_prefix
            && String(self.data?.suffix(Defaults.data_suffix.count) ?? "") == Defaults.data_suffix
    }
  
    private func reset() {
        self.current_shift = Defaults.initial_shift
        self.bitsCharacter = 0
    }
    
    //----------------------------------------------------------------------
    
    
    private func message_to_debugger(message: String){
        
        print("Decoder" + ": " + message)
        
    }
    
    //----------------------------------------------------------------------
}
