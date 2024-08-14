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
        
        let digitWidth = (inSize.width - ((CGFloat(inNumberOfDigits) - 1) * inSpacingInDisplayUnits)) / CGFloat(inNumberOfDigits)
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
        let maxDigitalPlaces = tempDigits.count - (inCanShowNegative ? 1 : 0) // How many digit places we have to work with.
        let maxValue = Int(pow(Double(inNumberBase.base), Double(maxDigitalPlaces))) - 1
        let minValue = inCanShowNegative ? -maxValue : 0
        value = min(maxValue, max(minValue, inValue))
        _setToValue()
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
        let digitWidth = CGFloat(digits.count) * (inHeight * defaultAspect)
        
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
     This is the outline of the entire display.
     */
    public var outline: CGPath {
        guard !digits.isEmpty else { return CGMutablePath() }
        var x = CGFloat(0)
        var index = digits.count
        return digits.reduce(into: CGMutablePath()) {
            let transform = CGAffineTransform(translationX: x, y: 0)
            index -= 1
            x += $1.size.width + (0 == index ? 0 : spacingInDisplayUnits)
            $0.addPath($1.outline, transform: transform)
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the "On" segments.
     
     > NOTE: If none are on (value -2), this will be an empty path.
     */
    public var onSegments: CGPath {
        guard !digits.isEmpty else { return CGMutablePath() }
        var x = CGFloat(0)
        var index = digits.count
        return digits.reduce(into: CGMutablePath()) {
            let transform = CGAffineTransform(translationX: x, y: 0)
            index -= 1
            x += $1.size.width + (0 == index ? 0 : spacingInDisplayUnits)
            $0.addPath($1.onSegments, transform: transform)
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the "Off" segments.
     
     > NOTE: If none are off (value 8), this will be an empty path.
     */
    public var offSegments: CGPath {
        guard !digits.isEmpty else { return CGMutablePath() }
        var x = CGFloat(0)
        var index = digits.count
        return digits.reduce(into: CGMutablePath()) {
            let transform = CGAffineTransform(translationX: x, y: 0)
            index -= 1
            x += $1.size.width + (0 == index ? 0 : spacingInDisplayUnits)
            $0.addPath($1.offSegments, transform: transform)
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the segments (both "on" and "off").
     */
    public var segmentMask: CGPath {
        guard !digits.isEmpty else { return CGMutablePath() }
        var x = CGFloat(0)
        var index = digits.count
        return digits.reduce(into: CGMutablePath()) {
            let transform = CGAffineTransform(translationX: x, y: 0)
            index -= 1
            x += $1.size.width + (0 == index ? 0 : spacingInDisplayUnits)
            $0.addPath($1.segmentMask, transform: transform)
        }
    }
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
     Awkward function, but it works.
     
     // TODO: Make this cleverer
     */
    private mutating func _setToValue() {
        guard !digits.isEmpty else { return }

        var tempValue = UInt64(abs(value))
        
        for index in 0..<digits.count {
            digits[index].value = LGV_7_Segment.Values.off.rawValue
        }
        
        var digitValues: [Int] = []
        
        if 0 == tempValue {
            digits[digits.count - 1].value = 0
            if showLeadingZeroes {
                for index in (canShowNegative ? 1 : 0)..<(digits.count - 1) {
                    digits[index].value = 0
                }
            }
        } else {
            let numericalDigits = canShowNegative ? digits.count - 1 : digits.count
            
            switch numberBase {
            case .binary:
                while 0 < tempValue {
                    let overTwo = (tempValue / 2) * 2
                    let underTwo = Int(tempValue - overTwo)
                    digitValues.append(underTwo)
                    tempValue /= 2
                }
            case .octal:
                while 0 < tempValue {
                    let overEight = (tempValue / 8) * 8
                    let underEight = Int(tempValue - overEight)
                    digitValues.append(underEight)
                    tempValue /= 8
                }
            case .decimal:
                while 0 < tempValue {
                    let overTen = (tempValue / 10) * 10
                    let underTen = Int(tempValue - overTen)
                    digitValues.append(underTen)
                    tempValue /= 10
                }
            case .hex:
                while 0 < tempValue {
                    let overSixteen = (tempValue / 16) * 16
                    let underSixteen = Int(tempValue - overSixteen)
                    digitValues.append(underSixteen)
                    tempValue /= 16
                }
            }
            
            var currentDigit = numericalDigits - digitValues.count + (canShowNegative ? 1 : 0)
            
            digitValues.reversed().forEach {
                digits[currentDigit].value = $0
                currentDigit += 1
            }

            if showLeadingZeroes {
                for index in 0..<(digits.count - digitValues.count) {
                    digits[index].value = 0
                }
            }
            
            currentDigit = showLeadingZeroes ? 0 : (digits.count - digitValues.count) - 1
            if 0 <= currentDigit,
               canShowNegative {
                digits[currentDigit].value = 0 > value ? LGV_7_Segment.Values.minus.rawValue : LGV_7_Segment.Values.off.rawValue
            }
        }
    }
}
