//
//  Utilities.swift
//  ISN_Steganography
//
//  Created by Jaafar Rammal on 3/20/18.
//  Copyright © 2018 Jaafar Rammal. All rights reserved.
//

import Foundation

struct Utilities {
    
    static func Mask8(_ x: UInt32) -> UInt32{
        return x & 0xFF
    }
  
    static func Color(_ x: UInt32, shift: Int) -> UInt32 {
        return Mask8(x >> (8 * UInt32(shift)))
    }
  
    static func add_bits(number1: UInt32, number2: UInt32, shift: Int) -> UInt32 {
        return (number1 | Mask8(number2) << (8 * UInt32(shift)))
    }
  
    static func new_pixel(pixel: UInt32, shifted_bits: UInt32, shift: Int) -> UInt32 {
        let bit = (shifted_bits & 1) << (8 * UInt32(shift))
        let color_and_not = (pixel & ~(1 << (8 * UInt32(shift))))
        return color_and_not | bit
    }
  
    static func color_to_step(step: UInt32) -> pixel_color {
        if step % 3 == 0 {
            return .blue;
        } else if step % 2 == 0 {
            return .green;
        } else {
            return .red;
        }
    }
}


enum pixel_color: Int {
  case red = 0, green, blue
}
