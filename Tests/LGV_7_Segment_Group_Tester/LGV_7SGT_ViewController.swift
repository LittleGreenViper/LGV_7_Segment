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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Custom View for Displaying the Digit Set -
/* ###################################################################################################################################### */
/**
 */
class LGV_7SGT_DisplayView: UIView {
    /* ################################################################## */
    /**
     The controller that "owns" this instance.
     */
    @IBOutlet weak var myController: LGV_7SGT_ViewController?
    
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
    @IBInspectable var maskColor: UIColor = .label

    /* ################################################################## */
    /**
     The digit group
     */
    var digitSet: LGV_7_Segment_Group?
    
    /* ################################################################## */
    /**
     Called when the layout changes.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard let myController = myController,
              let viewWidth = myController.view?.bounds.size.width
        else { return }
        
        if 0 < myController.numberOfDigits,
           0 < viewWidth {
            var tempDigit = LGV_7_Segment_Group(numberOfDigits: myController.numberOfDigits, size: CGSize(width: 128, height: 128))
            let necessaryHeight = tempDigit.idealHeightFrom(width: viewWidth)
            let value = myController.value
            tempDigit = LGV_7_Segment_Group(numberOfDigits: myController.numberOfDigits,
                                           size: CGSize(width: viewWidth, height: necessaryHeight),
                                           numberBase: myController.numberBase,
                                           value: value,
                                           canShowNegative: 1 < myController.numberOfDigits,
                                           spacing: 4
            )
            
            digitSet = tempDigit
            
            myController.displayHeightAnchor?.constant = necessaryHeight
            
            let backLayer = CAShapeLayer()
            let offLayer = CAShapeLayer()
            let onLayer = CAShapeLayer()
            let maskLayer = CAShapeLayer()
            
            backLayer.frame = bounds
            offLayer.frame = bounds
            onLayer.frame = bounds
            maskLayer.frame = bounds

            backLayer.path = tempDigit.outline
            offLayer.path = tempDigit.offSegments
            onLayer.path = tempDigit.onSegments
            maskLayer.path = tempDigit.segmentMask
            
            backLayer.fillColor = backColor.cgColor
            offLayer.fillColor = offColor.cgColor
            onLayer.fillColor = onColor.cgColor
            maskLayer.strokeColor = UIColor.systemGray2.cgColor

            guard let selectedSegment = myController.displaySegmentedSwitch?.selectedSegmentIndex,
                  let selection = LGV_7SGT_ViewController.DisplayTypes(rawValue: selectedSegment)
            else { return }
            
            switch selection {
            case .all:
                layer.addSublayer(backLayer)
                layer.addSublayer(offLayer)
                layer.addSublayer(onLayer)
                
            case .onOnly:
                maskLayer.lineWidth = 0.5
                maskLayer.fillColor = UIColor.clear.cgColor
                layer.addSublayer(maskLayer)
                layer.addSublayer(onLayer)

            case .offOnly:
                maskLayer.lineWidth = 0.5
                maskLayer.fillColor = UIColor.clear.cgColor
                layer.addSublayer(maskLayer)
                layer.addSublayer(offLayer)

            case .outline:
                layer.addSublayer(backLayer)

            case .maskOnly:
                maskLayer.lineWidth = 0
                maskLayer.fillColor = maskColor.cgColor
                layer.addSublayer(maskLayer)
            }
        } else {
            myController.displayHeightAnchor?.constant = 0
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Displays Multiple Segments, And Controls -
/* ###################################################################################################################################### */
/**
 */
class LGV_7SGT_ViewController: UIViewController {
    /* ################################################################################################################################## */
    // MARK: Enumeration for the Display Type Segmented Switch
    /* ################################################################################################################################## */
    /**
     These are assignments for the integer indexes of the display segmented control.
     */
    enum DisplayTypes: Int {
        /* ############################################################## */
        /**
         Only display the control outline.
         */
        case outline
        
        /* ############################################################## */
        /**
         Only display the mask
         */
        case maskOnly
        
        /* ############################################################## */
        /**
         Only display on segments
         */
        case onOnly
        
        /* ############################################################## */
        /**
         Only display off segments
         */
        case offOnly
        
        /* ############################################################## */
        /**
         Display everything except the mask.
         */
        case all
    }
    
    /* ################################################################## */
    /**
     The label that displays the current value
     */
    @IBOutlet weak var valueDisplayLabel: UILabel?
    
    /* ################################################################## */
    /**
     A slider that affects the value shown on the display.
     */
    @IBOutlet weak var valueSlider: UISlider?
    
    /* ################################################################## */
    /**
     The digit display view
     */
    @IBOutlet weak var displayView: LGV_7SGT_DisplayView?
    
    /* ################################################################## */
    /**
     A segmented switch that affects the number of digits to display.
     */
    @IBOutlet weak var digitCountSegmentedSwitch: UISegmentedControl?
    
    /* ################################################################## */
    /**
     A segmented switch that affects what is displayed.
     */
    @IBOutlet weak var displaySegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     The height anchor for the display, which is changed to match the current number of digits, and the width of the display.
     */
    @IBOutlet weak var displayHeightAnchor: NSLayoutConstraint?
    
    /* ################################################################## */
    /**
     A segmented switch that affects the number base of the digits.
     */
    @IBOutlet weak var numberBaseSegmentedSwitch: UISegmentedControl?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_7SGT_ViewController {
    var displayType: DisplayTypes {
        get {
            guard let ds = displaySegmentedSwitch,
                  let type = DisplayTypes(rawValue: ds.selectedSegmentIndex)
            else { return .outline }
            
            return type
        }
        
        set { displaySegmentedSwitch?.selectedSegmentIndex = newValue.rawValue }
    }
    
    /* ################################################################## */
    /**
     The selected base for the digits. This reads and sets the base switch.
     */
    var numberBase: LGV_7_Segment_Group.NumberBase {
        get {
            guard let index = numberBaseSegmentedSwitch?.selectedSegmentIndex,
                  let enumeration = LGV_7_Segment_Group.NumberBase(rawValue: index)
            else { return .decimal }
            
            return enumeration
        }
        
        set {
            numberBaseSegmentedSwitch?.selectedSegmentIndex = newValue.rawValue
            numberBaseSegmentedSwitch?.sendActions(for: .valueChanged)
        }
    }
    
    /* ################################################################## */
    /**
     Returns the number of digits being displayed (including the negative sign).
     */
    var numberOfDigits: Int {
        get { digitCountSegmentedSwitch?.selectedSegmentIndex ?? 0 }
        
        set {
            guard (0..<(digitCountSegmentedSwitch?.numberOfSegments ?? 0)).contains(newValue) else { return }
            digitCountSegmentedSwitch?.selectedSegmentIndex = newValue
        }
    }
    
    /* ################################################################## */
    /**
     Returns the number of digits being displayed (without the negative sign).
     */
    var numberOfNumericalDigits: Int { numberOfDigits - 1 < numberOfDigits ? 1 : 0 }
    
    /* ################################################################## */
    /**
     This is the value of the digit group.
     */
    var value: Int {
        get { Int(valueSlider?.value ?? 0) }
        set {
            guard let valueSlider = valueSlider else { return }
            
            let tempVal = max(valueSlider.minimumValue, min(valueSlider.maximumValue, Float(newValue)))
            
            valueSlider.setValue(tempVal, animated: true)
            valueSlider.sendActions(for: .valueChanged)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_7SGT_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let digitCountSegmentedSwitch = digitCountSegmentedSwitch else { return }

        for index in 0..<digitCountSegmentedSwitch.numberOfSegments {
            digitCountSegmentedSwitch.setTitle(String(format: "SLUG-COUNT-%d", index).localizedVariant, forSegmentAt: index)
        }
        
        for index in 0..<(displaySegmentedSwitch?.numberOfSegments ?? 0) {
            displaySegmentedSwitch?.setTitle(String(format: "SLUG-SWITCH-%d", index).localizedVariant, forSegmentAt: index)
        }
        
        for index in 0..<(numberBaseSegmentedSwitch?.numberOfSegments ?? 0) {
            numberBaseSegmentedSwitch?.setTitle(String(format: "SLUG-BASE-%d", index).localizedVariant, forSegmentAt: index)
        }

        guard let slider = valueSlider else { return }
        
        digitCountSegmentedSwitchChanged(digitCountSegmentedSwitch)
        setHiddenStates()
        valueSliderChanged(slider)
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_7SGT_ViewController {
    /* ################################################################## */
    /**
     Creates a digit group, based on the current screen setting.
     */
    func setDigitGroup() {
        displayView?.setNeedsLayout()
    }

    /* ################################################################## */
    /**
     Hides or shows the value label and value slider.
     */
    func setHiddenStates() {
        valueSlider?.isHidden = 0 == numberOfDigits || .outline == displayType || .maskOnly == displayType
        valueDisplayLabel?.isHidden = 0 == numberOfDigits || .outline == displayType || .maskOnly == displayType
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_7SGT_ViewController {
    /* ################################################################## */
    /**
     Called when the value slider changes.
     
     - parameter inSlider: The slider that changed.
     */
    @IBAction func valueSliderChanged(_ inSlider: UISlider) {
        let intValue = Int(round(inSlider.value))
        inSlider.value = Float(intValue)
        valueDisplayLabel?.text = String(intValue)
        setDigitGroup()
    }

    /* ################################################################## */
    /**
     Called when the segmented switch for the number of digits changes.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func digitCountSegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        valueSlider?.isEnabled = 0 < inSwitch.selectedSegmentIndex
        valueDisplayLabel?.isHidden = 0 == inSwitch.selectedSegmentIndex

        switch inSwitch.selectedSegmentIndex {
        case 1:
            valueSlider?.minimumValue = Float(0)
            valueSlider?.maximumValue = Float(15)

        case 2:
            valueSlider?.minimumValue = Float(-15)
            valueSlider?.maximumValue = Float(15)

        case 3:
            valueSlider?.minimumValue = Float(-31)
            valueSlider?.maximumValue = Float(31)

        case 4:
            valueSlider?.minimumValue = Float(-255)
            valueSlider?.maximumValue = Float(255)

        case 5:
            valueSlider?.minimumValue = Float(-4095)
            valueSlider?.maximumValue = Float(4095)

        default:
            valueSlider?.minimumValue = Float(0)
            valueSlider?.maximumValue = Float(0)
        }
        
        setHiddenStates()

        valueSlider?.value = Float(0)
        valueSlider?.sendActions(for: .valueChanged)
        displayView?.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Called when the segmented switch for the display changes.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func displaySegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        setHiddenStates()
        displayView?.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     The number base segmented switch was hit.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func numberBaseSegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        valueSlider?.sendActions(for: .valueChanged)
    }
}
