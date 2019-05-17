//
//  Defaults.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import Foundation

//Default structure of the different components of the encoding and decoding classes
struct Defaults {
    
    
    static let initial_shift = 7
    
    //Each pixel is defined by 4 bytes (8 * 4 = 32 bits)
    static let bytes_per_pixel = 4
    
    //The number of bits to use for each component of a pixel in memory
    static let bits_per_component = 8
    
    //UTF-8 encodings, which will be used in our Swift project, are by default between 1 and 4 bytes
    static let bytes_of_length = 4
  
    //Data to begin and end the message with
    static let data_prefix = "<m>"
    static let data_suffix = "</m>"
  
    //The size of info
    static var size_of_info_lenght: Int {
        return bytes_of_length * bits_per_component
    }
  
    //Minimum number of pixels required to encode the message
    static var min_pixels_to_message: Int {
        return (data_prefix.count + data_suffix.count) * bits_per_component
    }
  
    //Final minimum number of pixels required
    static var min_pixels: Int {
        return size_of_info_lenght + min_pixels_to_message
    }
  
}
