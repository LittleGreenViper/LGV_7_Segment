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

import UIKit
import LGV_7_Segment

class LGV_7ST_DisplaySegment: UIView {
    /* ################################################################## */
    /**
     */
    @IBInspectable var onColor: UIColor = .systemOrange

    /* ################################################################## */
    /**
     */
    @IBInspectable var offColor : UIColor = .systemGray.withAlphaComponent(0.75)

    /* ################################################################## */
    /**
     */
    @IBInspectable var backColor: UIColor = .blue

    /* ################################################################## */
    /**
     */
    @IBInspectable var value: Int = -2 { didSet { setNeedsLayout() } }

    /* ################################################################## */
    /**
     */
    var segmentDisplay = LGV_7_Segment()
    
    /* ################################################################## */
    /**
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard (-2..<16).contains(value) else { return }
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        segmentDisplay.size = frame.size
        segmentDisplay.value = value
        
        let backLayer = CAShapeLayer()
        let offLayer = CAShapeLayer()
        let onLayer = CAShapeLayer()
        let allLayer = CAShapeLayer()
        
        backLayer.frame = bounds
        offLayer.frame = bounds
        onLayer.frame = bounds
        allLayer.frame = bounds

        backLayer.path = segmentDisplay.outline
        offLayer.path = segmentDisplay.offSegments
        onLayer.path = segmentDisplay.onSegments
        allLayer.path = segmentDisplay.allSegments
        
        backLayer.fillColor = backColor.cgColor
        offLayer.fillColor = offColor.cgColor
        onLayer.fillColor = onColor.cgColor
        
        layer.addSublayer(backLayer)
        layer.addSublayer(offLayer)
        layer.addSublayer(onLayer)
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 */
class LGV_7ST_ViewController: UIViewController {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var displaySegment: LGV_7ST_DisplaySegment?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var valueSlider: UISlider?
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func valueChanged(_ inControl: UISlider) {
        let newValue = max(-2, min(15, Int(round(inControl.value))))
        inControl.value = Float(newValue)
        displaySegment?.value = newValue
    }
}
