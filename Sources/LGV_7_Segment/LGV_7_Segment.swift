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
// MARK: - Private CGPoint Extension For Rotating Points -
/* ###################################################################################################################################### */
fileprivate extension CGPoint {
    /* ################################################################## */
    /**
     Rotate this point around a given point, by an angle given in degrees.
     
     - parameters:
        - around: Another point, that is the "fulcrum" of the rotation.
        - byDegrees: The rotation angle, in degrees. 0 is no change. - is counter-clockwise, + is clockwise.
     - returns: The transformed point.
     */
    func _rotated(around inCenter: CGPoint, byDegrees inDegrees: CGFloat) -> CGPoint { _rotated(around: inCenter, byRadians: (inDegrees * .pi) / 180) }
    
    /* ################################################################## */
    /**
     This was inspired by [this SO answer](https://stackoverflow.com/a/35683523/879365).
     Rotate this point around a given point, by an angle given in radians.
     
     - parameters:
        - around: Another point, that is the "fulcrum" of the rotation.
        - byDegrees: The rotation angle, in radians. 0 is no change. - is counter-clockwise, + is clockwise.
     - returns: The transformed point.
     */
    func _rotated(around inCenter: CGPoint, byRadians inRadians: CGFloat) -> CGPoint {
        let dx = x - inCenter.x
        let dy = y - inCenter.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + inRadians
        let x = inCenter.x + radius * cos(newAzimuth)
        let y = inCenter.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 */
struct LGV_7_Segment {
    /* ################################################################################################################################## */
    // MARK: 
    /* ################################################################################################################################## */
    /**
     */
    enum SegmentPath: Hashable {
        /* ############################################################## */
        /**
         This is an array of points that maps out the standard element shape.
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
         This is the size of the entire drawing area.
         */
        private static let _c_g_displaySize = CGSize(width: 250, height: 492)

        /* ############################################################## */
        /**
         */
        case top
        
        /* ############################################################## */
        /**
         */
        case topRight
        
        /* ############################################################## */
        /**
         */
        case bottomRight
        
        /* ############################################################## */
        /**
         */
        case bottom
        
        /* ############################################################## */
        /**
         */
        case bottomLeft
        
        /* ############################################################## */
        /**
         */
        case topLeft
        
        /* ############################################################## */
        /**
         */
        case center
        
        /* ############################################################## */
        /**
         */
        var path: CGPath? {
            nil
        }
    }
    
    /* ################################################################## */
    /**
     */
}
