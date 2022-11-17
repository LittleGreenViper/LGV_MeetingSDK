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
import MapKit

/* ###################################################################################################################################### */
// MARK: Static Int Functions
/* ###################################################################################################################################### */
extension Int {
    /* ################################################################## */
    /**
     This adjusts the selection to match the week start (localization).
     
     - parameter inWeekdayIndex: The 0-based index of the selected weekday, in the current locale.
     
     - returns: The adjusted weekday index, in the 0 = Sunday locale.
     */
    static func normalizeWeekdayIndex(_ inWeekdayIndex: Int) -> Int {
        var weekdayIndex = (inWeekdayIndex - 1) + Calendar.current.firstWeekday
        
        if 6 < weekdayIndex {
            weekdayIndex -= 7
        }
        
        return weekdayIndex
    }
    
    /* ################################################################## */
    /**
     This adjusts the selection to match the week start (localization).
     
     - parameter inWeekdayIndex: The 0-based index of the selected weekday, in the 0 = Sunday locale.
     
     - returns: The adjusted weekday index, with 0 being the week start day.
     */
    static func localizeWeedayIndex(_ inWeekdayIndex: Int) -> Int {
        var weekdayIndex = Calendar.current.firstWeekday + inWeekdayIndex
        
        if 7 < weekdayIndex {
            weekdayIndex -= 7
        }
        
        return weekdayIndex - 1
    }
}

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
// MARK: - Special Region Validator -
/* ###################################################################################################################################### */
extension MKCoordinateRegion {
    /* ################################################################## */
    /**
    This comes directly from [this gist](https://gist.github.com/AJMiller/0def0fd492a09ca22fee095c4526cf68).
    
    Returns true, if the region is considered "valid."
     */
    var isValid: Bool {
        let latitudeCenter = self.center.latitude
        let latitudeNorth = self.center.latitude + self.span.latitudeDelta/2
        let latitudeSouth = self.center.latitude - self.span.latitudeDelta/2

        let longitudeCenter = self.center.longitude
        let longitudeWest = self.center.longitude - self.span.longitudeDelta/2
        let longitudeEast = self.center.longitude + self.span.longitudeDelta/2

        let topLeft = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeWest)
        let topCenter = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeCenter)
        let topRight = CLLocationCoordinate2D(latitude: latitudeNorth, longitude: longitudeEast)

        let centerLeft = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeWest)
        let centerCenter = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeCenter)
        let centerRight = CLLocationCoordinate2D(latitude: latitudeCenter, longitude: longitudeEast)

        let bottomLeft = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeWest)
        let bottomCenter = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeCenter)
        let bottomRight = CLLocationCoordinate2D(latitude: latitudeSouth, longitude: longitudeEast)

        return  CLLocationCoordinate2DIsValid(topLeft) &&
            CLLocationCoordinate2DIsValid(topCenter) &&
            CLLocationCoordinate2DIsValid(topRight) &&
            CLLocationCoordinate2DIsValid(centerLeft) &&
            CLLocationCoordinate2DIsValid(centerCenter) &&
            CLLocationCoordinate2DIsValid(centerRight) &&
            CLLocationCoordinate2DIsValid(bottomLeft) &&
            CLLocationCoordinate2DIsValid(bottomCenter) &&
            CLLocationCoordinate2DIsValid(bottomRight) ?
              true :
              false
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
     This describes one Root Server entity.
     */
    typealias RootServerEntity = (name: String, rootURL: String)
}

/* ###################################################################################################################################### */
// MARK: Class Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     This reads in the Root Server list JSON file, slaps the tOMATO server URL to the beginning, sorts the rest by name, and returns it as an Array.
     */
    class var rootServerList: [RootServerEntity] {
        var ret = [RootServerEntity]()
        if let filepath = Bundle.main.path(forResource: "rootServerList", ofType: "json") {
            if let data = (try? String(contentsOfFile: filepath))?.data(using: .utf8),
               let main_object = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
                main_object.forEach {
                    if let name = $0["name"],
                       let rootURL = $0["rootURL"] {
                        ret.append(RootServerEntity(name: name, rootURL: rootURL))
                    }
                }
            }
        }
        
        ret = ret.sorted { $0.name < $1.name }
        
        ret.insert(RootServerEntity(name: "SLUG-TOMATO-SERVER-NAME".localizedVariant, rootURL: "SLUG-TOMATO-SERVER-URL".localizedVariant), at: 0)
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns the currently selected Root Server entity.
     */
    class var currentRootServer: RootServerEntity? { rootServerList.first { $0.rootURL == LGV_MeetingSDK_Test_Harness_Prefs().serverURLString } }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     This is used to refer back to the main tab view controller.
     The "@objc" lets it be overridden.
     */
    @objc var tabController: LGV_MeetingSDK_Test_Harness_TabController? { tabBarController as? LGV_MeetingSDK_Test_Harness_TabController }

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

/* ###################################################################################################################################### */
// MARK: Override Targets
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     Called when the search bar button item has been hit.
     
     - parameter inBarButtonItem: The bar button.
     */
    @objc func searchBarButtonItemHit(_ inBarButtonItem: UIBarButtonItem) { }
}

/* ###################################################################################################################################### */
// MARK: UIPopoverPresentationControllerDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_ViewController: UIPopoverPresentationControllerDelegate {
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
