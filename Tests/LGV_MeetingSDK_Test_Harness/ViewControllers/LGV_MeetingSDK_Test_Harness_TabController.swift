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
import CoreLocation

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
     This holds the actual SDK instance that we're testing.
     */
    var sdk: LGV_MeetingSDK_BMLT?
    
    /* ################################################################## */
    /**
     This will hold our location manager.
     */
    private var _locationManager: CLLocationManager?
    
    /* ################################################################## */
    /**
     This is the center of the last location-based search. Nil, if the last search was not location-based.
     */
    static var currentLocation: CLLocationCoordinate2D?

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
        overrideUserInterfaceStyle = .light
        delegate = self
        // Sets the tab bar colors (I like to be different).
        setColorsTo(normal: UIColor(named: "AccentColor"), selected: .white, background: .clear)
        
        // Localize the names of the tabs.
        viewControllers?.forEach {
            $0.tabBarItem?.accessibilityHint = $0.tabBarItem?.title?.accessibilityLocalizedVariant
            $0.tabBarItem?.title = $0.tabBarItem?.title?.localizedVariant
        }
        
        startLookingUpMyLocation()
    }
    
    /* ################################################################## */
    /**
     Called when the view is about to appear.
     
     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        loadState()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController {
    /* ################################################################## */
    /**
     Establishes a new instance of the BMLT SDK, at the given Root Server URI.
     
     - parameter inRootServerURLString: The string representation of the root server to be used.
     */
    func setSDKToThisRootServerURL(_ inRootServerURLString: String) {
        if let rootServerURL = URL(string: inRootServerURLString) {
            searchData?.meetings = []
            sdk = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
            setTabBarEnablement()
            mapViewController?.updateScreen()
        }
    }
    
    /* ################################################################## */
    /**
     Determines whether or not the results tab should be enabled.
     This also sets the search enablement (almost always allowed).
     */
    func setTabBarEnablement() {
        searchBarButtonItem?.isEnabled = isSearchButtonEnabled
        
        tabBar.items?[TabIndexes.results.rawValue].isEnabled = isSearchResultsTabEnabled
        
        if !isSearchResultsTabEnabled,
           TabIndexes.results.rawValue == selectedIndex {
            selectedIndex = TabIndexes.search.rawValue
        }
        
        saveState()
    }
    
    /* ################################################################## */
    /**
     Saves the current search state.
     */
    func saveState() {
        guard let rootServerURLString = sdk?.rootServerURLString,
              !rootServerURLString.isEmpty
        else { return }
        
        LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString = rootServerURLString
    }
    
    /* ################################################################## */
    /**
     Loads the saved search state.
     */
    func loadState() {
        let rootServerURLString = LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString
        
        guard !rootServerURLString.isEmpty else { return }
        
        // Set up our SDK.
        setSDKToThisRootServerURL(rootServerURLString)

        mapViewController?.updateScreen()
        setTabBarEnablement()
    }
    
    /* ################################################################## */
    /**
     This simply starts looking for where the user is at.
     */
    func startLookingUpMyLocation() {
        _locationManager?.stopUpdatingLocation()
        Self.currentLocation = nil
        _locationManager = CLLocationManager()
        _locationManager?.delegate = self
        _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager?.startUpdatingLocation()
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
            self?.appDelegateInstance?.searchData = inSearchResults as? LGV_MeetingSDK_BMLT.Data_Set
            self?.mapViewController?.isBusy = false
            self?.setTabBarEnablement()
            if !(inSearchResults?.meetings ?? []).isEmpty {
                self?.selectedIndex = TabIndexes.results.rawValue
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the search bar button item has been hit.
     
     - parameter inView: The bar button.
     */
    @IBAction func searchBarButtonItemHit(_ inBarButtonItem: UIBarButtonItem) {
        mapViewController?.recalculateSearchParameters()
        if let popoverController = storyboard?.instantiateViewController(identifier: "LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController") as? LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
            popoverController.modalPresentationStyle = .popover
            popoverController.tabController = self
            popoverController.popoverPresentationController?.barButtonItem = inBarButtonItem
            popoverController.popoverPresentationController?.delegate = self
            popoverController.popoverPresentationController?.permittedArrowDirections = [.up]
            
            present(popoverController, animated: true)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UITabBarControllerDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController: UITabBarControllerDelegate {
    /* ################################################################## */
    /**
     Called when the tab bar changes selection.
     
     - parameter The Tab Bar Controller: ignored.
     - parameter didSelect: The new selection.
     */
    func tabBarController( _: UITabBarController, didSelect: UIViewController ) {
        setTabBarEnablement()
    }
}

/* ###################################################################################################################################### */
// MARK: UIPopoverPresentationControllerDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController: UIPopoverPresentationControllerDelegate {
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way.
     
     - parameter for: The presentation controller we're talking about.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController) -> UIModalPresentationStyle { .none }
    
    /* ################################################################## */
    /**
     Called to ask if there's any possibility of this being displayed in another way (when the screen is rotated).
     
     - parameter for: The presentation controller we're talking about.
     - parameter traitCollection: The traits, describing the new orientation.
     - returns: No way, Jose.
     */
    func adaptivePresentationStyle(for: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle { .none }
}

/* ###################################################################################################################################### */
// MARK: CLLocationManagerDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_TabController: CLLocationManagerDelegate {
    /* ################################################################## */
    /**
     Callback to handle found locations.
     
     - parameter inManager: The Location Manager object that had the event.
     - parameter didUpdateLocations: an array of updated locations.
     */
    func locationManager(_ inManager: CLLocationManager, didUpdateLocations inLocations: [CLLocation]) {
        inManager.stopUpdatingLocation()
        for location in inLocations where 1.0 > location.timestamp.timeIntervalSinceNow {
            Self.currentLocation = location.coordinate
            break
        }
        _locationManager = nil
    }
}
