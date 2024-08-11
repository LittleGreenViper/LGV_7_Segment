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
     These are assignments for the integer indexes of the segmented control.
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
        
        let max = (displaySegmentedSwitch?.numberOfSegments ?? 0)
        
        for index in 0..<max {
            displaySegmentedSwitch?.setTitle(String(format: "SLUG-SWITCH-%d", index).localizedVariant, forSegmentAt: index)
        }
        
        guard let slider = valueSlider else { return }
        
        digitCountSegmentedSwitchChanged(digitCountSegmentedSwitch)
        valueSliderChanged(slider)
    }

    /* ################################################################## */
    /**
     Called when the value slider changes.
     
     - parameter inSlider: The slider that changed.
     */
    @IBAction func valueSliderChanged(_ inSlider: UISlider) {
        let intValue = Int(round(inSlider.value))
        inSlider.value = Float(intValue)
        valueDisplayLabel?.text = String(intValue)
    }

    /* ################################################################## */
    /**
     Called when the segmented switch for the number of digits changes.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func digitCountSegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        valueSlider?.isEnabled = 0 < inSwitch.selectedSegmentIndex
        valueDisplayLabel?.isHidden = 0 == inSwitch.selectedSegmentIndex
        
        valueSlider?.value = Float(0)

        switch inSwitch.selectedSegmentIndex {
        case 1:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            valueSlider?.minimumValue = Float(0)
            valueSlider?.maximumValue = Float(15)

        case 2:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            valueSlider?.minimumValue = Float(-15)
            valueSlider?.maximumValue = Float(15)

        case 3:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            valueSlider?.minimumValue = Float(-31)
            valueSlider?.maximumValue = Float(31)

        case 4:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            valueSlider?.minimumValue = Float(-255)
            valueSlider?.maximumValue = Float(255)

        case 5:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            valueSlider?.minimumValue = Float(-4095)
            valueSlider?.maximumValue = Float(4095)

        default:
            valueSlider?.isEnabled = false
            valueDisplayLabel?.isHidden = true
            valueSlider?.minimumValue = Float(0)
            valueSlider?.maximumValue = Float(0)
        }
        
        valueSlider?.sendActions(for: .valueChanged)
    }

    /* ################################################################## */
    /**
     Called when the segmented switch for the display changes.
     
     - parameter inSwitch: The switch that changed.
     */
    @IBAction func displaySegmentedSwitchChanged(_ inSwitch: UISegmentedControl) {
        switch inSwitch.selectedSegmentIndex {
        case DisplayTypes.outline.rawValue:
            valueSlider?.isEnabled = false
            valueDisplayLabel?.isHidden = true
            
        case DisplayTypes.maskOnly.rawValue:
            valueSlider?.isEnabled = false
            valueDisplayLabel?.isHidden = true
            
        case DisplayTypes.onOnly.rawValue:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            
        case DisplayTypes.offOnly.rawValue:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            
        case DisplayTypes.all.rawValue:
            valueSlider?.isEnabled = true
            valueDisplayLabel?.isHidden = false
            
        default:
            break
        }
        
        displayView?.setNeedsLayout()
    }
}
