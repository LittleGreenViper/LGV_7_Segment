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
// MARK: - Seven-Segment Display CGPath Generator -
/* ###################################################################################################################################### */
/**
 This struct is a graphical representation of a classic "7-segment" LED/LCD display for a single digit.
 
 It does not provide slanted segments, like displays that also have text charatcers. It just displays 0-F (0-15), and a single center segment (-).
 
 It also does not actually *display* anything. It just provides primitive CoreGraphics paths for the segment.
 */
struct LGV_7_Segment {
    /* ################################################################## */
    /**
     This is the size of the entire drawing area. The numbers are somewhat arbitrary, as the shapes will be cast into whatever context the user desires.
     */
    private static let _c_g_displaySize = CGSize(width: 250, height: 492)
    
    /* ################################################################################################################################## */
    // MARK: Segment Description Enum
    /* ################################################################################################################################## */
    /**
     This enum represents each segment.
     */
    enum SegmentPath: Hashable, CaseIterable {
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
        private static let _c_g_viewOffsets: [SegmentPath: CGPoint] = [
            .top: CGPoint(x: 8, y: 0),
            .topRight: CGPoint(x: 192, y: 8),
            .bottomRight: CGPoint(x: 192, y: 250),
            .bottom: CGPoint(x: 8, y: 434),
            .bottomLeft: CGPoint(x: 0, y: 250),
            .topLeft: CGPoint(x: 0, y: 8),
            .center: CGPoint(x: 8, y: 212)
        ]
        
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
         */
        var path: CGPath? { Self._newSegmentShape(for: self) }
        
        /* ############################################################## */
        /**
         */
        func path(withCache inCache: [SegmentPath: CGPath]) -> CGPath? { inCache[self] ?? path }

        /* ############################################################## */
        /**
         Creates a path containing a segment shape.
         
         - parameter inSegment: This indicates which segment we want (Will affect rotation and selection of shape).
         
         - returns: a new path, in the shape of the requested segment
         */
        private static func _newSegmentShape(for inSegment: Self) -> CGPath? {
            var points: [CGPoint] = (.center == inSegment) ? _c_g_CenterShapePoints : _c_g_StandardShapePoints
            
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
            case .topLeft:
                rotDiv = CGFloat(Double.pi / -2.0)
            case .bottomLeft:
                rotDiv = CGFloat(Double.pi / -2.0)
            case .topRight:
                rotDiv = CGFloat(Double.pi / 2.0)
            case .bottomRight:
                rotDiv = CGFloat(Double.pi / 2.0)
            case .bottom:
                rotDiv = -CGFloat(Double.pi)
            default:
                break
            }

            var transform = CGAffineTransform(rotationAngle: rotDiv)
            
            let bounds = CGRect(origin: .zero, size: LGV_7_Segment._c_g_displaySize)
            
            if let offset = _c_g_viewOffsets[inSegment] {
                var toOrigin: CGAffineTransform
                switch inSegment {
                case .bottom:
                    toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                case .topLeft:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
                case .bottomLeft:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: -bounds.origin.y + offset.y)
                case .topRight:
                    toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                case .bottomRight:
                    toOrigin = CGAffineTransform(translationX: -bounds.origin.x + offset.x, y: -bounds.origin.y + offset.y)
                default:
                    toOrigin = CGAffineTransform(translationX: offset.x, y: offset.y)
                }
                
                transform = transform.concatenating(toOrigin)
                
                return path.copy(using: &transform)
            }
            
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     This caches the paths. We build this at init time.
     */
    private let _segmentCache: [SegmentPath: CGPath] = SegmentPath.allCases.reduce(into: [SegmentPath: CGPath]()) { $0[$1] = $1.path }
    
    /* ################################################################## */
    /**
     This returns the segment enums that will be "on," for the current value.
     */
    private var _onSegments: [SegmentPath] {
        var paths = [SegmentPath]()
        
        switch value {
        case -1:
            paths = [.center]
            
        case 0:
            paths = [.topLeft, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft]
            
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
            paths = [.topLeft, .topRight, .bottomRight, .bottom, .bottomLeft, .topLeft, .center]

        case 9:
            paths = [.topLeft, .topRight, .bottomRight, .bottom, .topLeft, .center]

        case 10:
            paths = [.topLeft, .topRight, .bottomRight, .bottomLeft, .topLeft, .center]

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

    /* ################################################################## */
    /**
     This is the combined paths for all the "On" segments.
     
     > NOTE: If none are on (value -2), this will be an empty path.
     */
    var onSegments: CGPath {
        return _onSegments.reduce(into: CGMutablePath()) {
            if let path = $1.path(withCache: _segmentCache) {
                $0.addPath(path)
            }
        }
    }

    /* ################################################################## */
    /**
     This is the combined paths for all the "Off" segments.
     
     > NOTE: If none are off (value 8), this will be an empty path.
     */
    var offSegments: CGPath {
        return SegmentPath.allCases.filter({!_onSegments.contains($0)}).reduce(into: CGMutablePath()) {
            if let path = $1.path(withCache: _segmentCache) {
                $0.addPath(path)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the outline of the entire display.
     */
    var outline: CGPath { CGPath(rect: CGRect(origin: .zero, size: Self._c_g_displaySize), transform: nil) }
    
    /* ################################################################## */
    /**
     The value that determines the display. This is the only mutable property.
     
     -2 is all off (blank). This is the default.
     -1 is negative sign (center bar only).
     0-15 are the hex values (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F).
     
     > NOTE: This will crash, if a value is set outside the required range.
     */
    var value: Int = -2 { didSet { precondition((-2..<16).contains(value), "-2 -> 15 only!") } }
}
