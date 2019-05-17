//
//  Encoder.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import UIKit
import CoreGraphics

class Encoder {
    
    //----------------------------------------------------------------------
    
    //Encoding variables
    private var current_shift: Int = Defaults.initial_shift
    private var current_character: Int = 0
    private var step: UInt32 = 0
    private var data_to_hide: NSString = ""
  
    //----------------------------------------------------------------------
    
    //Main public function to encode a String in an UIImage (returns an UIImage)
    //Inputs: the original image and the text to hide
    //Outputs: the new image with the text hidden in the pixels
    
    func encode(image: UIImage, data: String) -> UIImage? {
        
        //Create a Core Graphic Image (cgImage) (also named BitMap Image)
        guard let cg_image = image.cgImage else {
            message_to_debugger(message: "Returned nil #00")
            return nil }
        
        //Width, height and size
        let width = cg_image.width
        let height = cg_image.height
        let size = width * height
    
        //Create a pointer to the destination in memory where the drawing is to be rendered
        let pixels = calloc(size, MemoryLayout<UInt32>.size)
    
        //Create an empty image
        var processed_image: UIImage?
    
        //Start the encryption
        if size >= Defaults.min_pixels {
            
            //Define The color space to use for the bitmap context as RGB
            let color_space = CGColorSpaceCreateDeviceRGB()
            
            //Create our component information for the bitmap
            let bitmap_info: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue), CGBitmapInfo.byteOrder32Big]
      
            //Create our bitmap context, else exit main function
            guard let context = CGContext(data: pixels, width: width, height: height, bitsPerComponent: Defaults.bits_per_component, bytesPerRow: Defaults.bytes_per_pixel * width, space: color_space, bitmapInfo: bitmap_info.rawValue) else {
                message_to_debugger(message: "Returned nil #02")
                return nil }
      
            //Draw the initial image in the context
            context.draw(cg_image, in: CGRect(x: 0, y: 0, width: width, height: height))

            //Create a copy of the pointer, else exit main function
            guard let pixel_pointer = pixels else {
                message_to_debugger(message: "Returned nil #03")
                return nil }
      
            //Bind the memory to a typed pointer with a UInt32 type (with the capacity as the size)
            let pixel_array = pixel_pointer.bindMemory(to: UInt32.self, capacity: size)
            
            //Try to hide the image and return an error if could not
            let error = self.hide_data(data: data, in: pixel_array, size: size)
      
            //If there is no error, create and return a cg_image from the pixel data in a bitmap graphics context into new_image
            if error == nil, let new_image = context.makeImage(){
                processed_image = UIImage(cgImage: new_image)
            } else {
        
            }
      
            //Draw context
            context.draw(cg_image, in: CGRect(x: 0, y: 0, width: width, height: height))
      
        } else {
      
        }
    
        //Retrun the processed image
        message_to_debugger(message: "Returned processed_image #04")
        return processed_image
    }
  
    //----------------------------------------------------------------------
    
    //Hide the data in the image's pixels (the created array in the public function).
    private func hide_data(data: String, in pixels: UnsafeMutablePointer<UInt32>, size: Int) -> Error? {
        
        guard let message = message_to_hide(string: data) else { return NSError() } // TODO: return better error
        var length = message.length
    
        if length <= INT_MAX && (length * Defaults.bits_per_component) < (size - Defaults.size_of_info_lenght) {
            reset()
      
            let data = NSData(bytes: &length, length: Defaults.bytes_of_length)
      
            let length_data_info = NSString(data: data as Data, encoding: String.Encoding.ascii.rawValue) ?? ""
      
            var pixel_position: Int = 0
      
            self.data_to_hide = length_data_info
      
            while pixel_position < Defaults.size_of_info_lenght {
                pixels[pixel_position] = self.new_pixel(pixel: pixels[pixel_position])
                pixel_position += 1
            }
      
            reset()
      
            let pixels_to_hide = message.length * Defaults.bits_per_component
      
            self.data_to_hide = message
      
            let ratio = (size - pixel_position) / pixels_to_hide
      
            let salt = ratio
      
            while pixel_position <= size {
                pixels[pixel_position] = self.new_pixel(pixel: pixels[pixel_position])
                pixel_position += salt
            }
            
        } else {
      
            message_to_debugger(message: "SEEMS THE MESSAGE IS TOO LONG OR THE PICTURE TOO SMALL #5")
    
        }
        
        return nil
    
    }
  
    //----------------------------------------------------------------------
    
    //
    private func new_pixel(pixel: UInt32) -> UInt32 {
        let color = self.new_color(color: pixel)
        self.step += 1
        return color
    }
    
    //----------------------------------------------------------------------
  
    
    private func new_color(color: UInt32) -> UInt32 {
        if self.data_to_hide.length > self.current_character {
            let asciiCode = UInt32(self.data_to_hide.character(at: self.current_character))
            let shifted_bits = asciiCode >> self.current_shift
      
            if current_shift == 0 {
                current_shift = Defaults.initial_shift
                current_character += 1
            } else {
                current_shift -= 1
            }
      
            return Utilities.new_pixel(pixel: color, shifted_bits: shifted_bits, shift: Utilities.color_to_step(step: self.step).rawValue)
        }
    
        return color
        
    }
  
    //----------------------------------------------------------------------
    
    private func reset() {
        self.current_shift = Defaults.initial_shift
        self.current_character = 0
    }
  
    //----------------------------------------------------------------------
    
    private func message_to_hide(string: String) -> NSString? {
        let data = string.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else { return nil }
        return NSString(format: "%@%@%@", Defaults.data_prefix, base64String, Defaults.data_suffix)
    }
    
    //----------------------------------------------------------------------
    
    private func message_to_debugger(message: String){
        print("Encoder" + ": " + message)
    }
    
}

//--------------------------------------------------------------------------
