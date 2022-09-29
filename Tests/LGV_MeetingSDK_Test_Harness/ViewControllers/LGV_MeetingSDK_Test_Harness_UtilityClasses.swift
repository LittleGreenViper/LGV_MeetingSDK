/*
 © Copyright 2022, Little Green Viper Software Development LLC
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
import LGV_MeetingSDK
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Special Switch That Has A Thumb That Changes Color -
/* ###################################################################################################################################### */
/**
 This switch will change its thumb color to the "on" color, when it is off.
 */
class LGV_MeetingSDK_Test_Harness_CustomUISwitch: UISwitch {
    /* ################################################################## */
    /**
     This stores the original thumb color, to be set, when the switch is on.
     */
    var originalThumbColor: UIColor?
    
    /* ################################################################## */
    /**
     This stores the original on color, to be set, when the switch is on.
     */
    var originalOnColor: UIColor?
    
    /* ################################################################## */
    /**
     Called when the control is set up.
     We use this to register a callback.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        if nil == originalThumbColor {
            originalThumbColor = thumbTintColor
        }
        addTarget(self, action: #selector(respondToSelection(_:)), for: .valueChanged)
        respondToSelection(self)
    }
    
    /* ################################################################## */
    /**
     This callback switches the color of the thumb, between white (when on), and the thumb color (when off).
     */
    @objc func respondToSelection(_ inSwitch: LGV_MeetingSDK_Test_Harness_CustomUISwitch) {
        if inSwitch.isOn {
            inSwitch.thumbTintColor = originalThumbColor
            inSwitch.onTintColor = UIColor(named: "AccentColor")
        } else {
            inSwitch.thumbTintColor = UIColor(named: "AccentColor")
        }
        setNeedsDisplay()
    }
}

/* ###################################################################################################################################### */
// MARK: - Base View Controller Class -
/* ###################################################################################################################################### */
/**
 This is a base class for each of the tab view controllers.
 */
class LGV_MeetingSDK_Test_Harness_Base_ViewController: UIViewController {
    /* ################################################################## */
    /**
     Convenience accessor for the app delegate instance.
     */
    var appDelegateInstance: LGV_MeetingSDK_Test_Harness_AppSceneDelegate? { LGV_MeetingSDK_Test_Harness_AppSceneDelegate.appDelegateInstance }
    
    /* ################################################################## */
    /**
     This allows us to specify, and receive, a search.
     */
    var searchData: LGV_MeetingSDK_BMLT.Data_Set? { appDelegateInstance?.searchData }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     We use this to set the navbar title (from the tab item).
     
     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        tabBarController?.navigationItem.title = tabBarItem?.title
    }
}
