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
// MARK: - Tab Controller Class -
/* ###################################################################################################################################### */
/**
 This manages the tab bar of the app. It also presents the displayed NavBar.
 */
class LGV_MeetingSDK_Test_Harness_TabController: UITabBarController {
    /* ################################################################################################################################## */
    // MARK: Tab Index Enum
    /* ################################################################################################################################## */
    /**
     These Represent our tabs.
     */
    enum TabIndexes: Int {
        /* ############################################################## */
        /**
         The Map Search Tab
         */
        case search
        
        /* ############################################################## */
        /**
         The Search Results Tab
         */
        case results
    }
    
    /* ################################################################## */
    /**
     The Search Bar Button Item.
     */
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController {
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
extension LGV_MeetingSDK_Test_Harness_TabController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setColorsTo(normal: UIColor(named: "AccentColor"), selected: .lightGray, background: .clear)
        viewControllers?.forEach {
            $0.tabBarItem?.accessibilityHint = $0.tabBarItem?.title?.accessibilityLocalizedVariant
            $0.tabBarItem?.title = $0.tabBarItem?.title?.localizedVariant
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        setTabBarEnablement()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController {
    /* ################################################################## */
    /**
     Determines whether or not the results tab should be enabled.
     */
    func setTabBarEnablement() {
        if (searchData?.meetings ?? []).isEmpty {
            tabBar.items?[TabIndexes.results.rawValue].isEnabled = false
            if TabIndexes.results.rawValue == selectedIndex {
                selectedIndex = TabIndexes.search.rawValue
            }
        } else {
            tabBar.items?[TabIndexes.results.rawValue].isEnabled = true
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController {
    /* ################################################################## */
    /**
     Called when the search bar button item has been hit.
     
     - parameter: ignored.
     */
    @IBAction func searchBarButtonItemHit(_: Any) {
    }
}
