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
    @IBInspectable var onColor: UIColor?

    /* ################################################################## */
    /**
     The color to use for "off" segments.
     */
    @IBInspectable var offColor : UIColor?

    /* ################################################################## */
    /**
     The color to use for the "container."
     */
    @IBInspectable var backColor: UIColor?

    /* ################################################################## */
    /**
     The color to use for the "mask" outline.
     */
    @IBInspectable var maskColor: UIColor?

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
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard let myController = myController,
              var viewWidth = myController.displayViewContainer?.bounds.size.width
        else { return }
        
        if 0 < myController.numberOfDigits,
           0 < viewWidth {
            myController.displayViewContainer?.isHidden = false
            var tempDigit = LGV_7_Segment_Group(numberOfDigits: myController.numberOfDigits, size: CGSize(width: 128, height: 128))
            var necessaryHeight = tempDigit.idealHeightFrom(width: viewWidth)
            if necessaryHeight > (myController.view.bounds.height / 2) {
                necessaryHeight = (myController.view.bounds.height / 2)
                viewWidth = tempDigit.idealWidthFrom(height: necessaryHeight)
            }
            let value = myController.value
            let state = myController.allStateSegmentedSwitch?.selectedSegmentIndex ?? 0
            tempDigit = LGV_7_Segment_Group(numberOfDigits: myController.numberOfDigits,
                                            size: CGSize(width: viewWidth, height: necessaryHeight),
                                            value: value,
                                            numberBase: myController.numberBase,
                                            canShowNegative: myController.canShowNegative,
                                            showLeadingZeroes: myController.hasLeadingZeroes,
                                            spacing: 4,
                                            allOff: 1 == state,
                                            allMinus: 2 == state
            )

            digitSet = tempDigit
            
            myController.displayHeightAnchor?.constant = necessaryHeight
            myController.displayWidthAnchor?.constant = viewWidth

            let backLayer = CAShapeLayer()
            let offLayer = CAShapeLayer()
            let onLayer = CAShapeLayer()
            let maskLayer = CAShapeLayer()
            
            backLayer.frame = bounds
            offLayer.frame = bounds
            onLayer.frame = bounds
            maskLayer.frame = bounds
            
            guard let selectedSegment = myController.displaySegmentedSwitch?.selectedSegmentIndex,
                  let selection = LGV_7SGT_ViewController.DisplayTypes(rawValue: selectedSegment)
            else { return }
            
            let onColor = onColor ?? .red
            let offColor = offColor ?? (.offOnly == selection ? .blue : .gray.withAlphaComponent(0.75))
            let backColor = backColor ?? .blue.withAlphaComponent(0.5)
            let maskColor = maskColor ?? .label

            backLayer.fillColor = backColor.cgColor
            offLayer.fillColor = offColor.cgColor
            onLayer.fillColor = onColor.cgColor
            maskLayer.strokeColor = UIColor.systemGray2.cgColor

            switch selection {
            case .all:
                backLayer.path = tempDigit.outline
                layer.addSublayer(backLayer)
                offLayer.path = tempDigit.offSegments
                layer.addSublayer(offLayer)
                onLayer.path = tempDigit.onSegments
                layer.addSublayer(onLayer)
                
            case .onOnly:
                maskLayer.lineWidth = 0.5
                maskLayer.fillColor = UIColor.clear.cgColor
                maskLayer.path = tempDigit.segmentMask
                layer.addSublayer(maskLayer)
                onLayer.path = tempDigit.onSegments
                layer.addSublayer(onLayer)

            case .offOnly:
                maskLayer.lineWidth = 0.5
                maskLayer.fillColor = UIColor.clear.cgColor
                maskLayer.path = tempDigit.segmentMask
                layer.addSublayer(maskLayer)
                offLayer.path = tempDigit.offSegments
                layer.addSublayer(offLayer)

            case .outline:
                backLayer.path = tempDigit.outline
                layer.addSublayer(backLayer)

            case .maskOnly:
                maskLayer.lineWidth = 0
                maskLayer.fillColor = maskColor.cgColor
                maskLayer.path = tempDigit.segmentMask
                layer.addSublayer(maskLayer)
            }
        } else {
            myController.displayViewContainer?.isHidden = true
        }

        super.layoutSubviews()
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
     This contains the display.
     */
    @IBOutlet weak var displayViewContainer: UIView?
    
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
     The width anchor for the display, which is changed to match the current number of digits, and the width of the display.
     */
    @IBOutlet weak var displayWidthAnchor: NSLayoutConstraint?

    /* ################################################################## */
    /**
     A segmented switch that affects the number base of the digits.
     */
    @IBOutlet weak var numberBaseSegmentedSwitch: UISegmentedControl?

    /* ################################################################## */
    /**
     The switch that controls whether or not leading zeroes are displayed.
     */
    @IBOutlet weak var leadingZeroesSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label is actually a button, and toggles the switch.
     */
    @IBOutlet weak var leadingZeroesLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The switch that controls whether or not negative values are allowed.
     */
    @IBOutlet weak var canShowNegativeSwitch: UISwitch?
    
    /* ################################################################## */
    /**
     The label is actually a button, and toggles the switch.
     */
    @IBOutlet weak var canShowNegativeLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     This switches between "all off," "all minus," and "normal" mode.
     */
    @IBOutlet weak var allStateSegmentedSwitch: UISegmentedControl?
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
        get { (digitCountSegmentedSwitch?.selectedSegmentIndex ?? 0) + 1 }
        
        set {
            guard (1..<(digitCountSegmentedSwitch?.numberOfSegments ?? 0)).contains(newValue) else { return }
            digitCountSegmentedSwitch?.selectedSegmentIndex = newValue - 1
        }
    }
    
    /* ################################################################## */
    /**
     Returns the number of digits being displayed (without the negative sign).
     */
    var numberOfNumericalDigits: Int { numberOfDigits - (canShowNegative ? 1 : 0) }
    
    /* ################################################################## */
    /**
     Returns true, if the display has leading zeroes.
     */
    var hasLeadingZeroes: Bool {
        get { leadingZeroesSwitch?.isOn ?? false }
        set { leadingZeroesSwitch?.isOn = newValue }
    }
    
    /* ################################################################## */
    /**
     Returns true, if the display can show negative numbers (the first digit is reserved for a minus sign).
     */
    var canShowNegative: Bool {
        get { 1 < numberOfDigits && (canShowNegativeSwitch?.isOn ?? false) }
        set { canShowNegativeSwitch?.isOn = newValue }
    }

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
        
        view?.overrideUserInterfaceStyle = .light
        
        leadingZeroesLabelButton?.setTitle(leadingZeroesLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        canShowNegativeLabelButton?.setTitle(canShowNegativeLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)

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
        
        for index in 0..<(allStateSegmentedSwitch?.numberOfSegments ?? 0) {
            allStateSegmentedSwitch?.setTitle(String(format: "SLUG-STATE-%d", index).localizedVariant, forSegmentAt: index)
        }

        guard let slider = valueSlider else { return }
        
        digitCountSegmentedSwitchChanged(digitCountSegmentedSwitch)
        enablements()
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
     Enables or disables various items.
     */
    func enablements() {
        valueSlider?.isEnabled = !(0 == numberOfDigits || .outline == displayType || .maskOnly == displayType)
        valueDisplayLabel?.isEnabled = !(0 == numberOfDigits || .outline == displayType || .maskOnly == displayType)
        canShowNegativeSwitch?.isEnabled = 1 < numberOfDigits && .outline != displayType && .maskOnly != displayType
        canShowNegativeLabelButton?.isEnabled = 1 < numberOfDigits && .outline != displayType && .maskOnly != displayType
        leadingZeroesSwitch?.isEnabled = 1 < numberOfDigits && .outline != displayType && .maskOnly != displayType && (!canShowNegative || 2 < numberOfDigits)
        leadingZeroesLabelButton?.isEnabled = 1 < numberOfDigits && .outline != displayType && .maskOnly != displayType
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
        
        enablements()
        
        canShowNegativeSwitch?.isEnabled = 1 < numberOfDigits
        canShowNegativeLabelButton?.isEnabled = 1 < numberOfDigits

        let maxVal = Int(pow(Double(numberBase.maxValue + 1), Double(numberOfNumericalDigits))) - 1
        let minVal = canShowNegative ? -maxVal : 0
        valueSlider?.minimumValue = Float(minVal)
        valueSlider?.maximumValue = Float(maxVal)
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
        enablements()
        displayView?.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     The number base segmented switch was hit.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func numberBaseSegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        let maxVal = Int(pow(Double(numberBase.maxValue + 1), Double(numberOfNumericalDigits))) - 1
        let minVal = canShowNegative ? -maxVal : 0
        valueSlider?.minimumValue = Float(minVal)
        valueSlider?.maximumValue = Float(maxVal)
        valueSlider?.value = Float(0)
        valueSlider?.sendActions(for: .valueChanged)
        displayView?.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Called when the button or the switch for leading zeroes changes.
     
     - parameter inControl: The button or switch that changed.
     */
    @IBAction func leadingZeroesSwitchChanged(_ inControl: UIControl) {
        if inControl is UIButton {
            leadingZeroesSwitch?.setOn(!(leadingZeroesSwitch?.isOn ?? true), animated: true)
            leadingZeroesSwitch?.sendActions(for: .valueChanged)
        } else {
            displayView?.setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the button or the switch for negative values changes.
     
     - parameter inControl: The button or switch that changed.
     */
    @IBAction func canShowNegativeSwitchChanged(_ inControl: UIControl) {
        if inControl is UIButton {
            canShowNegativeSwitch?.setOn(!(canShowNegativeSwitch?.isOn ?? true), animated: true)
            canShowNegativeSwitch?.sendActions(for: .valueChanged)
        } else {
            enablements()
            let maxVal = Int(pow(Double(numberBase.maxValue + 1), Double(numberOfNumericalDigits))) - 1
            let minVal = canShowNegative ? -maxVal : 0
            valueSlider?.minimumValue = Float(minVal)
            valueSlider?.maximumValue = Float(maxVal)
            valueSlider?.value = Float(0)
            valueSlider?.sendActions(for: .valueChanged)
            displayView?.setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     The switch for "all off," "all minus," and "normal" mode has changed.
     
     - parameter: ignored.
     */
    @IBAction func allStateSegmentedSwitchChanged(_: UISegmentedControl) {
        setDigitGroup()
    }
}
