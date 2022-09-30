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
    
    var sdk: LGV_MeetingSDK_BMLT?
    
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
    
    /* ################################################################## */
    /**
     Returns true, if the search button should be enabled.
     */
    var isSearchButtonEnabled: Bool { nil != sdk }
    
    /* ################################################################## */
    /**
     Returns true, if the search results tab should be enabled.
     */
    var isSearchResultsTabEnabled: Bool { !(searchData?.meetings ?? []).isEmpty }
    
    /* ################################################################## */
    /**
     Convenience accessor to the map view controller.
     */
    var mapViewController: LGV_MeetingSDK_Test_Harness_Map_ViewController? { viewControllers?[0] as? LGV_MeetingSDK_Test_Harness_Map_ViewController }
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
        if let rootServerURL = URL(string: "https://tomato.bmltenabled.org/main_server") {
            sdk = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
        }

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
        searchBarButtonItem?.isEnabled = isSearchButtonEnabled
        
        tabBar.items?[TabIndexes.results.rawValue].isEnabled = isSearchResultsTabEnabled
        
        if !isSearchResultsTabEnabled,
           TabIndexes.results.rawValue == selectedIndex {
            selectedIndex = TabIndexes.search.rawValue
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
     **NB:** This may not be called in the main thread.
     
     - parameter inSearchResults: The search results (if any).
     - parameter inError: The error (if any)
     */
    func searchCallbackHandler(_ inSearchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _ inError: Error?) {
        print("We need to do something with this!")
        print("Search Results: \(String(describing: inSearchResults))")
        print("\tError: \(String(describing: inError))")
        DispatchQueue.main.async { [weak self] in
            self?.mapViewController?.isBusy = false
            self?.setTabBarEnablement()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the search bar button item has been hit.
     
     - parameter: ignored.
     */
    @IBAction func searchBarButtonItemHit(_: Any) {
        guard let sdk = sdk,
              let searchData = searchData
        else { return }
        mapViewController?.isBusy = true
        sdk.meetingSearch(type: searchData.searchType, refinements: searchData.searchRefinements, completion: searchCallbackHandler)
    }
}
