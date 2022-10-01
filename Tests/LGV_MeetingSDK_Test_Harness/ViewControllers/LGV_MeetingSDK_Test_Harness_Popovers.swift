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
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Base Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This provides a base substrate, for the popovers.
 */
class LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_ViewController { }

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     We use this to select Dark Mode (always), since the screens are forced Light Mode.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
}

/* ###################################################################################################################################### */
// MARK: - Set Server Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This popover allows selection of a new Root Server.
 */
class LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
    /* ################################################################## */
    /**
     The desired width of the popover (as wide as possible).
     */
    private static let _popoverWidth = CGFloat(30000)
    
    /* ################################################################## */
    /**
     The desired height of the popover.
     */
    private static let _popoverHeight = CGFloat(144)
    
    /* ################################################################## */
    /**
     This will be the Root Server selection Picker.
     */
    @IBOutlet weak var rootServerPickerView: UIPickerView?
    
    /* ################################################################## */
    /**
     This is our main Tab controller.
     */
    private weak var _tabController: LGV_MeetingSDK_Test_Harness_TabController?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController {
    /* ################################################################## */
    /**
     The index of the currently selected Root Server
     */
    var indexOfSelectedRootServer: Int {
        get {
            let selected = LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString
            
            for rootServerEntity in Self.rootServerList.enumerated() where rootServerEntity.element.rootURL == selected {
                return rootServerEntity.offset
            }
            
            return 0
        }
        
        set {
            LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString = Self.rootServerList[newValue].rootURL
            guard let rootURL = Self.currentRootServer?.rootURL else { return }
            
            _tabController?.setSDKToThisRootServerURL(rootURL)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController {
    /* ################################################################## */
    /**
     This is used to refer back to the main tab view controller.
     */
    override var tabController: LGV_MeetingSDK_Test_Harness_TabController? {
        get { _tabController }
        set { _tabController = newValue }
    }
    
    /* ################################################################## */
    /**
     The size that we'd like our popover to be.
     */
    override var preferredContentSize: CGSize {
        get { CGSize(width: Self._popoverWidth, height: Self._popoverHeight) }
        set { super.preferredContentSize = newValue }
    }
    
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        rootServerPickerView?.selectRow(indexOfSelectedRootServer, inComponent: 0, animated: true)
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: UIPickerViewDataSource {
    /* ################################################################## */
    /**
     The number of components (always 1)
     
     - parameter in: The picker view instance (ignored).
     
     - return: 1 (always)
     */
    func numberOfComponents(in: UIPickerView) -> Int { 1 }
    
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter numberOfRowsInComponent: The component we're checking (only one, so ignored).
     
     - returns: The number of rows (the number of Root Servers).
     */
    func pickerView(_: UIPickerView, numberOfRowsInComponent: Int) -> Int { Self.rootServerList.count }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter titleForRow: The row, for the selected Root Server.
     - parameter forComponent: The component we're checking (only one, so ignored).
     
     - returns: A String, with the URL title.
     */
    func pickerView(_: UIPickerView, titleForRow inRow: Int, forComponent: Int ) -> String? { Self.rootServerList[inRow].name }
    
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter titleForRow: The row, for the selected Root Server.
     - parameter forComponent: The component we're checking (only one, so ignored).
     */
    func pickerView(_: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        indexOfSelectedRootServer = inRow
    }
}

/* ###################################################################################################################################### */
// MARK: - Select Refinements Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This popover allows selection of refinements, before a search.
 */
class LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
}