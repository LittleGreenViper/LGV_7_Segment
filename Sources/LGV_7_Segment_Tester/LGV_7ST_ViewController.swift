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

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 This was cribbed [from this SO answer](https://stackoverflow.com/a/33003217/879365)
 */
extension NSLayoutConstraint {
    /* ################################################################## */
    /**
     Change multiplier constraint.
     
     It does this, by deactivating the current constraint, creating a new constraint, based on the current one, then activating and returning that.

     - parameter multiplier: This is the new multiplier value for the new constraint.
     - returns: A new constraint, with the multiplier value changed.
    */
    func setMultiplier(multiplier inMult: CGFloat) -> NSLayoutConstraint {
        guard let firstItem = firstItem else { return self }
        
        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: inMult,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 This is a basic view, displaying the seven-segment generator.
 */
class LGV_7ST_DisplaySegment: UIView {
    /* ################################################################## */
    /**
     The color to use for "on" segments.
     */
    @IBInspectable var onColor: UIColor = .systemOrange

    /* ################################################################## */
    /**
     The color to use for "off" segments.
     */
    @IBInspectable var offColor : UIColor = .systemGray.withAlphaComponent(0.75)

    /* ################################################################## */
    /**
     The color to use for the "container."
     */
    @IBInspectable var backColor: UIColor = .blue

    /* ################################################################## */
    /**
     The color to use for the "mask" outline.
     */
    @IBInspectable var allColor: UIColor = .label

    /* ################################################################## */
    /**
     The line width to use for the "mask" outline.
     */
    @IBInspectable var allLineWidthInDisplayUnits: CGFloat = 3

    /* ################################################################## */
    /**
     The initial value.
     */
    @IBInspectable var value: Int = -2 { didSet { setNeedsLayout() } }

    /* ################################################################## */
    /**
     The instance of our struct, used to calculate the paths.
     */
    var segmentDisplay = LGV_7_Segment()
    
    /* ################################################################## */
    /**
     Called when the view layout is changed/set.
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
        
        allLayer.strokeColor = allColor.cgColor
        allLayer.lineWidth = allLineWidthInDisplayUnits
        allLayer.fillColor = UIColor.clear.cgColor

        layer.addSublayer(allLayer)
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
    @IBOutlet weak var valueDisplayLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var aspectSlider: UISlider?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var aspectConstraint: NSLayoutConstraint?
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        valueDisplayLabel?.text = String(displaySegment?.value ?? -1)
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func valueChanged(_ inSlider: UISlider) {
        let newValue = max(-2, min(15, Int(round(inSlider.value))))
        valueDisplayLabel?.text = String(newValue)
        inSlider.value = Float(newValue)
        displaySegment?.value = newValue
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func aspectSliderChanged(_ inSlider: UISlider) {
        let idealAspect = LGV_7_Segment.c_g_displaySize.width / LGV_7_Segment.c_g_displaySize.height
        let midpoint = (inSlider.maximumValue - inSlider.minimumValue) / 2
        let spread = CGFloat(midpoint) + 2 // The +2 prevents the annoying "snap" in portrait mode.
        let valueToUse = 3 < abs(midpoint - inSlider.value) ? max(inSlider.minimumValue + 1, inSlider.value) : midpoint + 1   // This gives it a "snap detent" in the middle.
        inSlider.value = valueToUse
        let aspectMultiplier = CGFloat(valueToUse - inSlider.minimumValue) / spread
        
        aspectConstraint = aspectConstraint?.setMultiplier(multiplier: idealAspect * aspectMultiplier)
    }
}
