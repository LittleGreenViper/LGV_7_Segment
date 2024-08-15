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
// MARK: - Common Protocol for the 7-Segment Structs -
/* ###################################################################################################################################### */
/**
 This just defines a couple of common properties.
 */
public protocol LGV_7_Segment_Protocol {
    /* ################################################################## */
    /**
     This is the display size. This is a mutable property.
     
     The display will be stretched to fill the size.
     */
    var size: CGSize { get set }

    /* ################################################################## */
    /**
     The value that determines the display. This is a mutable property.
     */
    var value: Int { get set }
}

/* ###################################################################################################################################### */
// MARK: - Seven-Segment Display CGPath Generator -
/* ###################################################################################################################################### */
/**
 This struct is a graphical representation of a classic "7-segment" LED/LCD display for a single digit.
 
 It does not provide diagonal segments, like displays that also render text characters. It just displays 0-F (0-15), and a single center segment (-).
 
 It also does not actually *display* anything. It just provides primitive `CGPath` paths for the segments. These need to be used by the calling context to render the display.
 
 It supplies 4 different paths:
 
 - The path for all of the "on" segments. You get this from the ``onSegments`` computed property.
 - The path for all of the "off" segments. You get this from the ``offSegments`` computed property.
 - A path that encompasses all of the segments, whether on or off. This can be used as a mask. You get this from the ``segmentMask`` computed property.
 - A simple rectangular path, for the outline of the display. You get this from the ``outline`` computed property.

 The paths are calculated in realtime, and reflect the value and size of the display.

 By default, the control calculates its layout, based on 250 display units wide, by 492 display units high.
 However, the size can be set to anything, and the paths will fill it (stretching, if necessary).
 
 There are two mutable properties for this struct:
 
 - ``size``: This is the actual size that the display is calculated to fill. It will cause stretching, if it is different from the 125:246 aspect ratio of the default size.
 - ``value``: This is an integer value, from -2, to 15.
 
     The value can be:
     
     - -2 is all off (blank). This is the default.
     - -1 is the negative sign (center bar only).
     - 0-15 are the hex values (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F).
 
 It is possible to get the default aspect ratio, using the ``defaultAspect`` computed property, and the current aspect, using the ``currentAspect`` computed property.
 */
public struct LGV_7_Segment: LGV_7_Segment_Protocol {
    /* ################################################################################################################################## */
    // MARK: Segment Description Enum
    /* ################################################################################################################################## */
    /**
     This enum represents each segment.
     */
    private enum _SegmentPath: CaseIterable {
        /* ############################################################## */
        /**
         The bar across the top
         */
        case top
        
        /* ############################################################## */
        /**
         The bar on the right side, at the top
         */
        case topRight
        
        /* ############################################################## */
        /**
         The bar on the right side, at the bottom
         */
        case bottomRight
        
        /* ############################################################## */
        /**
         The bar across the bottom
         */
        case bottom
        
        /* ############################################################## */
        /**
         The bar on the left side, at the bottom
         */
        case bottomLeft
        
        /* ############################################################## */
        /**
         The bar on the left side, at the top
         */
        case topLeft
        
        /* ############################################################## */
        /**
         The bar across the center
         */
        case center
        
        /* ############################################################## */
        /**
         This is an array of points that maps out the standard element shape.
         
         These are the outer elements.
         */
        private static let _c_g_StandardShapePoints: [CGPoint] = [
            CGPoint(x: 0, y: 4),
            CGPoint(x: 4, y: 0),
            CGPoint(x: 230, y: 0),
            CGPoint(x: 234, y: 4),
            CGPoint(x: 180, y: 58),
            CGPoint(x: 54, y: 58),
            CGPoint(x: 0, y: 4)
        ]
        
        /* ############################################################## */
        /**
         This maps out the center element, which is a slightly different shape.
         */
        private static let _c_g_CenterShapePoints: [CGPoint] = [
            CGPoint(x: 0, y: 34),
            CGPoint(x: 34, y: 0),
            CGPoint(x: 200, y: 0),
            CGPoint(x: 234, y: 34),
            CGPoint(x: 200, y: 68),
            CGPoint(x: 34, y: 68),
            CGPoint(x: 0, y: 34)
        ]
        
        /* ############################################################## */
        /**
         This array of points dictates the layout of the display.
         */
        private static let _c_g_viewOffsets: [_SegmentPath: CGPoint] = [
            .top: CGPoint(x: 8, y: 0),
            .topRight: CGPoint(x: 250, y: 8),
            .bottomRight: CGPoint(x: 250, y: 250),
            .bottom: CGPoint(x: 242, y: 492),
            .bottomLeft: CGPoint(x: 0, y: 484),
            .topLeft: CGPoint(x: 0, y: 242),
            .center: CGPoint(x: 8, y: 212)
        ]
        
        /* ############################################################## */
        /**
         Creates a path containing a segment shape.
         
         - parameter inSegment: This indicates which segment we want (Will affect rotation and position of shape).
         
         - returns: a new path, in the shape of the requested segment
         */
        private func _newSegmentShape(for inSegment: Self) -> CGPath? {
            var points: [CGPoint] = (.center == inSegment) ? Self._c_g_CenterShapePoints : Self._c_g_StandardShapePoints
            
            guard !points.isEmpty,
                  let startingPoint = points.popLast()
            else { return nil }
            
            // First, we draw the shape. We do this by cycling through the points (backwards, for efficiency), ending where we started.
            let path = CGMutablePath()
            
            path.move(to: startingPoint)
            
            while !points.isEmpty {
                guard let nextPoint = points.popLast() else { return nil }
                path.addLine(to: nextPoint)
            }
            
            path.addLine(to: startingPoint)
            
            // Now, we move and/or rotate the segment to be in the correct part of the display.
            
            var rotDiv: CGFloat = 0.0
            
            switch inSegment {
            case .topLeft, .bottomLeft:
                rotDiv = CGFloat(Double.pi / -2.0)
            case .topRight, .bottomRight:
                rotDiv = CGFloat(Double.pi / 2.0)
            case .bottom:
                rotDiv = -CGFloat(Double.pi)
            default:
                break
            }
            
            var transform = CGAffineTransform(rotationAngle: rotDiv)
            
            if let offset = Self._c_g_viewOffsets[inSegment] {
                var toOrigin: CGAffineTransform
                switch inSegment {
                case .bottom:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                case .topLeft:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                case .bottomLeft:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                case .topRight:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                case .bottomRight:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                default:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                }
                
                transform = transform.concatenating(toOrigin)
                
                return path.copy(using: &transform)
            }
            
            return nil
        }
        
        // MARK: Internal Interface
        
        /* ############################################################## */
        /**
         This calculates a new path, based on the standard size.
         */
        var path: CGPath? { _newSegmentShape(for: self) }
        
        /* ############################################################## */
        /**
         This returns the path, taking caches into account, as well as scaling to our display size.
         
         - parameter withCache: The cache dictionary. If it is not in here, we create one from scratch
         - parameter withSize: This is the entire display size. The path is transformed to fit in that size.
         - returns: A new path, scaled to fit in the size.
         */
        func path(withSize inSize: CGSize) -> CGPath? {
            let heightScale = inSize.height / LGV_7_Segment.c_g_displaySize.height
            let widthScale = inSize.width / LGV_7_Segment.c_g_displaySize.width
            var transform = CGAffineTransform(scaleX: widthScale, y: heightScale)
            return path?.copy(using: &transform)
        }
    }
    
    /* ################################################################## */
    /**
     This returns the segment enums that will be "on," for the current value.
     */
    private var _onSegments: [_SegmentPath] {
        var paths = [_SegmentPath]()
        
        switch value {
        case Values.minus.rawValue:
            paths = [.center]
            
        case 0:
            paths = [.top, .topLeft, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft]
            
        case 1:
            paths = [.topRight, .bottomRight]
            
        case 2:
            paths = [.top, .topRight, .bottomLeft, .center, .bottom]
            
        case 3:
            paths = [.top, .topRight, .bottomRight, .center, .bottom]
            
        case 4:
            paths = [.topLeft, .topRight, .bottomRight, .center]
            
        case 5:
            paths = [.top, .topLeft, .bottomRight, .center, .bottom]
            
        case 6:
            paths = [.top, .topLeft, .bottomLeft, .bottomRight, .center, .bottom]
            
        case 7:
            paths = [.top, .topRight, .bottomRight]
            
        case 8:
            paths = [.top, .topLeft, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft, .center]
            
        case 9:
            paths = [.top, .topLeft, .topRight, .bottomRight, .bottom, .topLeft, .center]
            
        case 10:
            paths = [.top, .topLeft, .topRight, .bottomRight, .bottomLeft, .topLeft, .center]
            
        case 11:
            paths = [.topLeft, .bottomLeft, .bottom, .bottomRight, .center]
            
        case 12:
            paths = [.topLeft, .bottomLeft, .bottom, .top]
            
        case 13:
            paths = [.topRight, .bottomRight, .bottom, .bottomLeft, .center]
            
        case 14:
            paths = [.topLeft, .bottomLeft, .bottom, .top, .center]
            
        case 15:
            paths = [.topLeft, .bottomLeft, .top, .center]
            
        default:
            break
        }
        
        return paths
    }
    
    // MARK: Public Interface
    
    /* ################################################################## */
    /**
     This is the default initializer.
     
     - parameter size: The display size. If omitted, the default calculation size (``c_g_displaySize``) will be used.
     - parameter value: An initial value. If not provided, -2 (all off) is used.
     */
    public init(size inSize: CGSize = CGSize(width: Self.c_g_displaySize.width, height: Self.c_g_displaySize.height), value inValue: Int = Values.off.rawValue) {
        size = inSize
        value = inValue
    }
    
    /* ################################################################################################################################## */
    // MARK: Special Values Enum
    /* ################################################################################################################################## */
    /**
     This enum allows us to use these as placeholders for -2 and -1.
     */
    public enum Values: Int {
        /* ############################################################## */
        /**
         All off.
         */
        case off = -2
        
        /* ############################################################## */
        /**
         Just the center bar.
         */
        case minus
    }
    
    // MARK: Public Static Constants

    /* ################################################################## */
    /**
     This is the size of the entire drawing area. The numbers are somewhat arbitrary, as the shapes will be cast into whatever context the user desires.
     */
    public static let c_g_displaySize = CGSize(width: 250, height: 492)
    
    // MARK: Public Mutable Properties

    /* ################################################################## */
    /**
     This is the display size. This is a mutable property.
     
     The display will be stretched to fill the size.
     */
    public var size: CGSize

    /* ################################################################## */
    /**
     The value that determines the display. This is a mutable property.
     
     - -2 is all off (blank). This is the default.
     - -1 is negative sign (center bar only).
     - 0-15 are the hex values (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F).
     
     > NOTE: This will crash, if a value is set outside the required range.
     */
    public var value: Int = Values.off.rawValue { didSet { precondition((-2..<16).contains(value), "-2 -> 15 only!") } }
}

/* ###################################################################################################################################### */
// MARK: Public Read-Only Computed Properties
/* ###################################################################################################################################### */
extension LGV_7_Segment {
    /* ################################################################## */
    /**
     This is the combined paths for all the "On" segments.
     
     > NOTE: If none are on (value -2), this will be an empty path.
     */
    public var onSegments: CGPath {
        _onSegments.reduce(into: CGMutablePath()) {
            if let path = $1.path(withSize: size) {
                $0.addPath(path)
            }
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the "Off" segments.
     
     > NOTE: If none are off (value 8), this will be an empty path.
     */
    public var offSegments: CGPath {
        _SegmentPath.allCases.filter({!_onSegments.contains($0)}).reduce(into: CGMutablePath()) {
            if let path = $1.path(withSize: size) {
                $0.addPath(path)
            }
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the segments (both "on" and "off").
     */
    public var segmentMask: CGPath {
        _SegmentPath.allCases.reduce(into: CGMutablePath()) {
            if let path = $1.path(withSize: size) {
                $0.addPath(path)
            }
        }
    }

    /* ################################################################## */
    /**
     This is the outline of the entire display.
     */
    public var outline: CGPath { CGPath(rect: CGRect(origin: .zero, size: size), transform: nil) }
    
    /* ################################################################## */
    /**
     This returns the default aspect, as single floating-point value.
     */
    public var defaultAspect: CGFloat { Self.c_g_displaySize.width / Self.c_g_displaySize.height }
    
    /* ################################################################## */
    /**
     This returns the current aspect, as single floating-point value.
     */
    public var currentAspect: CGFloat { size.width / size.height }
}
