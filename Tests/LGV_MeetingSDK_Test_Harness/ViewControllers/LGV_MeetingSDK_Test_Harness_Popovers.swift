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
}

/* ###################################################################################################################################### */
// MARK: - Select Refinements Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This popover allows selection of refinements, before a search.
 */
class LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
}
