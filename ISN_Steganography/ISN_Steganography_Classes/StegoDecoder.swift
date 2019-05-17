//
//  Decoder.swift
//  SwiftStego
//
//  Created by Brian Hans on 1/13/18.
//  Copyright © 2018 BrianHans. All rights reserved.
//

import UIKit
import CoreGraphics

public class StegoDecoder {

  public static let `default` = StegoDecoder()
  
  public func decode(image: UIImage) throws -> String? {
    if try hasData(in: image), let string = self.data {
      guard String(string.prefix(Defaults.dataPrefix.count)) == Defaults.dataPrefix
        && String(string.suffix(Defaults.dataSuffix.count)) == Defaults.dataSuffix else {
          throw StegoError.invalidImage
      }
      
      let endIndex = string.index(string.endIndex, offsetBy: -Defaults.dataSuffix.count)
      let startIndex = string.index(string.startIndex, offsetBy: Defaults.dataPrefix.count)
      
      if let data = Data(base64Encoded: String(string[startIndex..<endIndex])) {
        return String(data: data, encoding: .utf8)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  // MARK: Private functions
  
  private func hasData(in image: UIImage) throws -> Bool {
    guard let cgImage = image.cgImage else { throw StegoError.invalidImage }
    let width = cgImage.width
    let height = cgImage.height
    let size = width * height
    
    let pixelPointer = calloc(size, MemoryLayout<UInt32>.size)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), CGBitmapInfo.byteOrder32Big]
    
    guard let context = CGContext(data: pixelPointer, width: width, height: height, bitsPerComponent: Defaults.bitsPerComponent, bytesPerRow: Defaults.bytesPerPixel * width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { throw StegoError.coreGraphicsFailed }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let pointer = pixelPointer else { throw StegoError.coreGraphicsFailed }
    
    do {
      try searchData(in: pointer, size: size)
      return self.hasData()
    } catch {
      return false
    }
  }
  
  private func searchData(in pixels: UnsafeMutableRawPointer, size: Int) throws {
    reset()
    
    var pixelPosition = 0
    
    let pixels = pixels.bindMemory(to: UInt32.self, capacity: size)

    while pixelPosition < Defaults.sizeOfInfoLength {
      self.getData(pixel: pixels[pixelPosition])
      pixelPosition += 1
    }
    
    guard self.length > 0 else { throw StegoError.invalidImage }
    
    reset()
    
    let pixelsToHide = Int(self.length) * Defaults.bitsPerComponent
    
    let salt = (size - Int(pixelPosition)) / pixelsToHide

    guard self.length > 0 else { throw StegoError.invalidImage }
    
    while pixelPosition <= size {
      getData(pixel: pixels[pixelPosition])
      pixelPosition += salt
      
      if (self.data?.suffix(Defaults.dataSuffix.count) ?? "") == Defaults.dataSuffix {
        break
      }
    }
  }
  
  private func getData(pixel: UInt32) {
    getData(color: Utilities.Color(pixel, shift: Utilities.ColorToStep(step: self.step).rawValue))
  }
  
  private func getData(color: UInt32) {
    if self.currentShift == 0 {
      let bit: UInt32 = color & 1
      self.bitsCharacter = (bit << self.currentShift) | UInt32(self.bitsCharacter)
      
      if self.step < Defaults.sizeOfInfoLength {
        getLength()
      } else {
        getCharacter()
      }
      
      self.currentShift = Defaults.initalShift
    } else {
      let bit: UInt32 = color & 1
      self.bitsCharacter = (bit << self.currentShift) | UInt32(self.bitsCharacter)
      self.currentShift -= 1
    }
    
    self.step += 1
  }
  
  private func getLength() {
    self.length = Utilities.AddBits(number1: self.length, number2: UInt32(self.bitsCharacter), shift: Int(self.step) % (Defaults.bitsPerComponent - 1))
    
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
    && String(self.data?.prefix(Defaults.dataPrefix.count) ?? "") == Defaults.dataPrefix
    && String(self.data?.suffix(Defaults.dataSuffix.count) ?? "") == Defaults.dataSuffix
  }
  
  private func reset() {
    self.currentShift = Defaults.initalShift
    self.bitsCharacter = 0
  }
  
  
  // MARK: Private variables
  
  private var currentShift: Int = 0
  private var bitsCharacter: UInt32 = 0
  private var data: String?
  private var step: UInt32 = 0
  private var length: UInt32 = 0
}
