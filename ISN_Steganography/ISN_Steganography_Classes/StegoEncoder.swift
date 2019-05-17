//
//  Encoder.swift
//  SwiftStego
//
//  Created by Brian Hans on 1/13/18.
//  Copyright © 2018 BrianHans. All rights reserved.
//

import UIKit
import CoreGraphics

public class StegoEncoder {
  
  public static let `default`: StegoEncoder = StegoEncoder()
  
  public func encode(image: UIImage, string: String) throws -> UIImage {
    guard let cgImage = image.cgImage else { throw StegoError.invalidImage }
    let width = cgImage.width
    let height = cgImage.height
    let size = width * height
    
    let pixels = calloc(size, MemoryLayout<UInt32>.size)
    
    if size >= Defaults.minPixels {
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), CGBitmapInfo.byteOrder32Big]
      
      guard let context = CGContext(data: pixels, width: width, height: height, bitsPerComponent: Defaults.bitsPerComponent, bytesPerRow: Defaults.bytesPerPixel * width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { throw StegoError.coreGraphicsFailed }
      
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

      guard let pixelPointer = pixels else { throw StegoError.coreGraphicsFailed }
      
      let pixelArray = pixelPointer.bindMemory(to: UInt32.self, capacity: size)
      
      try self.hide(string: string, in: pixelArray, size: size)
      
      if let newImage = context.makeImage() {
        return UIImage(cgImage: newImage)
      } else {
        throw StegoError.unknown
      }
    } else {
      throw StegoError.imageToSmall
    }
  }
  
  
  // MARK: Private functions
  
  private func hide(string: String, in pixels: UnsafeMutablePointer<UInt32>, size: Int) throws {
    guard let message = messageToHide(string: string) else { throw StegoError.unableToEncodeData }
    var length = message.length
    
    if length <= INT_MAX && (length * Defaults.bitsPerComponent) < (size - Defaults.sizeOfInfoLength) {
      reset()
      
      let data = NSData(bytes: &length, length: Defaults.bytesOfLength)
      
      let lengthDataInfo = NSString(data: data as Data, encoding: String.Encoding.ascii.rawValue) ?? ""
      
      var pixelPosition: Int = 0
      
      self.dataToHide = lengthDataInfo
      
      while pixelPosition < Defaults.sizeOfInfoLength {
        pixels[pixelPosition] = self.newPixel(pixel: pixels[pixelPosition])
        pixelPosition += 1
      }
      
      reset()
      
      let pixelsToHide = message.length * Defaults.bitsPerComponent
      
      self.dataToHide = message
      
      let ratio = (size - pixelPosition) / pixelsToHide
      
      let salt = ratio
      
      while pixelPosition <= size {
        pixels[pixelPosition] = self.newPixel(pixel: pixels[pixelPosition])
        pixelPosition += salt
      }
    }
  }
  
  private func newPixel(pixel: UInt32) -> UInt32 {
    let color = self.newColor(color: pixel)
    self.step += 1
    return color
  }
  
  private func newColor(color: UInt32) -> UInt32 {
    if self.dataToHide.length > self.currentCharacter {
      let asciiCode = UInt32(self.dataToHide.character(at: self.currentCharacter))
      let shiftedBits = asciiCode >> self.currentShift
      
      if currentShift == 0 {
        currentShift = Defaults.initalShift
        currentCharacter += 1
      } else {
        currentShift -= 1
      }
      
      return Utilities.NewPixel(pixel: color, shiftedBits: shiftedBits, shift: Utilities.ColorToStep(step: self.step).rawValue)
    }
    
    return color
  }
  
  private func reset() {
    self.currentShift = Defaults.initalShift
    self.currentCharacter = 0
  }
  
  private func messageToHide(string: String) -> NSString? {
    let data = string.data(using: .utf8)
    guard let base64String = data?.base64EncodedString() else { return nil }
    return NSString(format: "%@%@%@", Defaults.dataPrefix, base64String, Defaults.dataSuffix)
  }
  
  // MARK: Private variables
  
  private var currentShift: Int = Defaults.initalShift
  private var currentCharacter: Int = 0
  private var step: UInt32 = 0
  private var dataToHide: NSString = ""
}
