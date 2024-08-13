/*
 © Copyright 2024, Little Green Viper Software Development LLC
 LICENSE:
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import CoreGraphics

/* ###################################################################################################################################### */
// MARK: - UInt64 Extension -
/* ###################################################################################################################################### */
/**
 This extension will add a new set of capabilities to the native UInt64 data type.
 */
fileprivate extension UInt64 {
    /* ################################################################## */
    /**
     This method allows us to mask a discrete bit range within the number, and return its value as a 64-bit unsigned Int.
     
     For example, if we have the hex number 0xF30 (3888 decimal, or 111100110000 binary), we can mask parts of it to get masked values, like so:
     ```
        // 111100110000 (Value, in binary)
     
        // 111111111111 (Mask, in binary)
        let wholeValue = 3888.maskedValue(firstPlace: 0, runLength: 12)     // Returns 3888
        // 111111110000
        let lastByte = 3888.maskedValue(firstPlace: 4, runLength: 8)        // Returns 243
        // 000000000011
        let lowestTwoBits = 3888.maskedValue(firstPlace: 0, runLength: 2)   // Returns 0
        // 000000111100
        let middleTwelve = 3888.maskedValue(firstPlace: 2, runLength: 4)    // Returns 12
        // 000111100000
        let middleNine = 3888.maskedValue(firstPlace: 5, runLength: 4)      // Returns 9
        // 011111111111
        let theFirstElevenBits = 3888.maskedValue(firstPlace: 0, runLength: 11) // Returns 1840
        // 111111111110
        let theLastElevenBits = 3888.maskedValue(firstPlace: 1, runLength: 11)  // Returns 1944
        // 000000110000
        let lowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 4, runLength: 2)          // Returns 3
        // 000001100000
        let secondToLowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 5, runLength: 2)  // Returns 1
        // 000011000000
        let thirdFromLowestTwoBitsOfTheSecondHalfOfTheFirstByte = 3888.maskedValue(firstPlace: 6, runLength: 2) // Returns 0
     ```
     This is useful for interpeting bitfields, such as the OBD DTS response.
     
     This is BIT-based, not BYTE-based, and assumes the number is in a linear (bigendian) format, in which the least significant bit is the rightmost one (position one).
     In reality, this doesn't matter, as the language takes care of transposing byte order.
     
     Bit 1 is the least signficant (rightmost) bit in the value. The maximum value for `firstPlace` is 64.
     Run Length means the selected (by `firstPlace`) first bit, and leftward (towards more significant bits). It includes the first bit.
     
     The UInt64 variant of this is the "main" one.
     
     - prerequisites:
        - The sum of `firstPlace` and `runLength` cannot exceed the maximum size of a UInt64.

     - parameters:
        - firstPlace: The 1-based (1 is the first bit) starting position for the mask.
        - runLength: The inclusive (includes the starting place) number of bits to mask. If 0, then the return will always be 0.
     
     - returns: An Unsigned Int, with the masked value.
     */
    func _maskedValue(firstPlace inFirstPlace: UInt, runLength inRunLength: UInt) -> UInt64 {
        let maxRunLength = UInt(64)
        guard (inFirstPlace + inRunLength) <= maxRunLength,
              0 < inRunLength else { return 0 }   // Shortcut, if they aren't looking for anything.
        // The first thing we do, is shift the main value down to the start of our mask.
        let shifted = UInt64(self >> inFirstPlace)
        // We make a mask quite simply. We just shift down a "full house."
        let mask = UInt64(0xFFFFFFFFFFFFFFFF) >> (maxRunLength - inRunLength)
        // By masking out anything not in the run length, we return a value.
        return shifted & UInt64(mask)
    }
}

/* ###################################################################################################################################### */
// MARK: - Seven-Segment Display Group CGPath Generator -
/* ###################################################################################################################################### */
/**
 */
public struct LGV_7_Segment_Group {
    /* ################################################################################################################################## */
    // MARK: Number Base Enum
    /* ################################################################################################################################## */
    /**
     This enumeration defines which number base the group will use.
     */
    public enum NumberBase: Int {
        /* ############################################################## */
        /**
         Base 2
         */
        case binary
        
        /* ############################################################## */
        /**
         Base 8
         */
        case octal
        
        /* ############################################################## */
        /**
         Base 10
         */
        case decimal
        
        /* ############################################################## */
        /**
         Base 16
         */
        case hex
        
        /* ############################################################## */
        /**
         Returns the base.
         */
        public var base: Int {
            switch self {
            case .binary:
                return 2
                
            case .octal:
                return 8
                
            case .decimal:
                return 10
                
            case .hex:
                return 16
            }
        }
        
        /* ############################################################## */
        /**
         Returns the maximum value per digit, for the current base.
         */
        public var maxValue: Int {
            switch self {
            case .binary:
                return 1
                
            case .octal:
                return 7
                
            case .decimal:
                return 9
                
            case .hex:
                return 15
            }
        }
    }
    
    /* ################################################################## */
    /**
     The overall size of the digit display. The individual digits are calculated from this, including the spacing.
     */
    public let size: CGSize
    
    /* ################################################################## */
    /**
     These are the digit instances.
     */
    public var digits: [LGV_7_Segment]

    /* ################################################################## */
    /**
     This is the number base of the group.
     */
    public let numberBase: NumberBase
    
    /* ################################################################## */
    /**
     The spacing between the digits.
     */
    public let spacingInDisplayUnits: CGFloat
    
    /* ################################################################## */
    /**
     True, if the group can show negative numbers. Cannot be true for only one digit (or no digit).
     */
    public var canShowNegative: Bool { didSet { canShowNegative = canShowNegative && 1 < digits.count } }
    
    /* ################################################################## */
    /**
     True, if the group can show leading zeroes. Cannot be true for only one digit (or no digit).
     */
    public var showLeadingZeroes: Bool { didSet { showLeadingZeroes = showLeadingZeroes && 1 < digits.count } }

    /* ################################################################## */
    /**
     The overall value of the digit group. This is clipped to the current setup (base, negative, and number of digits).
     */
    public var value: Int {
        didSet {
            let maxDigitalPlaces = digits.count - (canShowNegative ? 1 : 0) // How many digit places we have to work with.
            let maxValue = Int(pow(Double(numberBase.base), Double(maxDigitalPlaces))) - 1
            let minValue = canShowNegative ? -maxValue : 0
            value = min(maxValue, max(minValue, value))
            _setToValue()
        }
    }
    
    /* ################################################################## */
    /**
     Default initializer
     
     - parameter numberOfDigits: This is the number of *numerical* digits (ones showing numbers). If `canShowNegative` is true, then one extra digit will prefix the set. Required.
     - parameter size: The overall size of the control. The digits are sized to fit inside it. Required.
     - parameter numberBase: The numerical base of the display. Default is hexadecimal.
     - parameter value: The numerical value (will be clipped to fit the number of digits, base, and whether or not negative numbers can be shown). Default is 0.
     - parameter canShowNegative: True, if the group can show negative numbers (will result in an additional digit at the front). Default is false.
     - parameter showLeadingZeroes: True, if the group fills leading digits with 0. Default is false.
     - parameter spacing: This is the number of display units, between digits. Ignored, if only one digit. Default is 0.
     */
    public init(numberOfDigits inNumberOfDigits: Int,
                size inSize: CGSize,
                numberBase inNumberBase: NumberBase = .hex,
                value inValue: Int = 0,
                canShowNegative inCanShowNegative: Bool = false,
                showLeadingZeroes inShowLeadingZeroes: Bool = false,
                spacing inSpacingInDisplayUnits: CGFloat = 0
    ) {
        var tempDigits = [LGV_7_Segment]()
        
        let digitWidth = (inSize.width - (CGFloat(inNumberOfDigits) * inSpacingInDisplayUnits)) / CGFloat(inNumberOfDigits)
        let digitSize = CGSize(width: digitWidth, height: inSize.height)

        for _ in 0..<inNumberOfDigits {
            tempDigits.append(LGV_7_Segment(size: digitSize))
        }
        
        digits = tempDigits
        numberBase = inNumberBase
        size = inSize
        canShowNegative = inCanShowNegative
        showLeadingZeroes = inShowLeadingZeroes
        spacingInDisplayUnits = inSpacingInDisplayUnits
        value = inValue
    }
}

/* ###################################################################################################################################### */
// MARK: Public Instance Methods
/* ###################################################################################################################################### */
extension LGV_7_Segment_Group {
    /* ################################################################## */
    /**
     This returns the "ideal" width for this group, based on a fixed height.
     
     - parameter height: The height to be used as the fixed axis.
     */
    public func idealWidthFrom(height inHeight: CGFloat) -> CGFloat {
        guard !digits.isEmpty else { return 0 }
        
        let defaultAspect = LGV_7_Segment.c_g_displaySize.width / LGV_7_Segment.c_g_displaySize.height
        let digitWidth = CGFloat(digits.count) * (inHeight / defaultAspect)
        
        return digitWidth + (spacingInDisplayUnits * (CGFloat(digits.count) - 1))
    }
    
    /* ################################################################## */
    /**
     This returns the "ideal" height for this group, based on a fixed width.
     
     - parameter width: The width to be used as the fixed axis.
     */
    public func idealHeightFrom(width inWidth: CGFloat) -> CGFloat {
        guard !digits.isEmpty else { return 0 }
        
        let eachDigitWidth = (CGFloat(inWidth) / CGFloat(digits.count)) - (spacingInDisplayUnits * (CGFloat(digits.count) - 1))
        
        return eachDigitWidth / (LGV_7_Segment.c_g_displaySize.width / LGV_7_Segment.c_g_displaySize.height)
    }
    
    /* ################################################################## */
    /**
     This is the combined paths for all the "On" segments.
     
     > NOTE: If none are on (value -2), this will be an empty path.
     */
    public var onSegments: CGPath {
        digits.reduce(into: CGMutablePath()) { $0.addPath($1.onSegments) }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the "Off" segments.
     
     > NOTE: If none are off (value 8), this will be an empty path.
     */
    public var offSegments: CGPath {
        digits.reduce(into: CGMutablePath()) { $0.addPath($1.offSegments) }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the segments (both "on" and "off").
     */
    public var segmentMask: CGPath {
        digits.reduce(into: CGMutablePath()) { $0.addPath($1.segmentMask) }
    }

    /* ################################################################## */
    /**
     This is the outline of the entire display.
     */
    public var outline: CGPath { digits.reduce(into: CGMutablePath()) { $0.addPath($1.outline) } }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods.
/* ###################################################################################################################################### */
extension LGV_7_Segment_Group {
    /* ################################################################## */
    /**
     This returns the internal frame of a single digit (as indexed).
     
     - parameter for: The 0-based index of the digit (0 is leftmost).
     - returns: The frame for the digit.
     */
    private func _frame(for inIndex: Int) -> CGRect {
        guard !digits.isEmpty,
              (0..<digits.count).contains(inIndex)
        else { return .zero }
        
        let size = digits[inIndex].size
        let digitWidth = (size.width - (CGFloat(digits.count) * spacingInDisplayUnits)) / CGFloat(digits.count)
        let digitHeight = size.height
        let xOrigin = CGFloat(inIndex) * (spacingInDisplayUnits + digitWidth)
        return CGRect(origin: CGPoint(x: xOrigin, y: 0), size: CGSize(width: digitWidth, height: digitHeight))
    }
    
    /* ################################################################## */
    /**
     */
    private mutating func _setToValue() {
        guard !digits.isEmpty else { return }

        let isNegative = 0 > value
        var value = UInt64(abs(value))
        
        for index in 0..<digits.count {
            digits[index].value = LGV_7_Segment.Values.off.rawValue
        }
        
        var digitValues: [Int] = []
        
        var firstPlace = UInt(0)
        
        switch numberBase {
        case .binary:
            while firstPlace < 64 {
                let temp = Int(value._maskedValue(firstPlace: firstPlace, runLength: 1))
                firstPlace += 1
                digitValues.append(temp)
            }
        case .octal:
            while firstPlace < 64 {
                let temp = Int(value._maskedValue(firstPlace: firstPlace, runLength: 3))
                firstPlace += 3
                digitValues.append(temp)
            }
        case .decimal:
            while 0 < value {
                let overTen = (value / 10) * 10
                let underTen = Int(value - overTen)
                digitValues.append(underTen)
                value /= 10
            }
        case .hex:
            while firstPlace < 64 {
                let temp = Int(value._maskedValue(firstPlace: firstPlace, runLength: 4))
                firstPlace += 4
                digitValues.append(temp)
            }
        }
        
        guard digitValues.count <= digits.count else { return }
        
        var currentDigit = digits.count - 1
        digitValues.reversed().forEach {
            if !canShowNegative || 1 < currentDigit {
                digits[currentDigit].value = $0
                currentDigit -= 1
            }
        }
        
        if showLeadingZeroes {
            while 1 < currentDigit {
                digits[currentDigit].value = 0
                currentDigit -= 1
            }
        }
        
        if canShowNegative {
            digits[currentDigit].value = isNegative ? LGV_7_Segment.Values.minus.rawValue : LGV_7_Segment.Values.off.rawValue
        }
    }
}
