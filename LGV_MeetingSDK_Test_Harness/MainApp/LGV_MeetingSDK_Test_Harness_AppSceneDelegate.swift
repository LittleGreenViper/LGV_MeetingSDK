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
// MARK: - Main Scene and App Delegate Class -
/* ###################################################################################################################################### */
/**
 We combine both the app delegate and the scene delegate, because we're not getting fancy.
 */
@main
class LGV_MeetingSDK_Test_Harness_AppSceneDelegate: UIResponder {
    /* ################################################################## */
    /**
     The required window property.
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     This allows us to specify, and receive, a search.
     */
    var searchData: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
}

/* ###################################################################################################################################### */
// MARK: Computed Class Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_AppSceneDelegate {
    /* ################################################################## */
    /**
     Convenience accessor for the app delegate instance.
     */
    static var appDelegateInstance: LGV_MeetingSDK_Test_Harness_AppSceneDelegate? { UIApplication.shared.delegate as? LGV_MeetingSDK_Test_Harness_AppSceneDelegate }
}

/* ###################################################################################################################################### */
// MARK: UIApplicationDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_AppSceneDelegate: UIApplicationDelegate {
    /* ################################################################## */
    /**
     Sets up the Window Scene, and connects it to the session.
     
     - parameter inScene: The scene instance.
     - parameter willConnectTo: The session that the scene will connect to
     - parameter options: Any connection options.
     */
    func scene(_ inScene: UIScene, willConnectTo: UISceneSession, options: UIScene.ConnectionOptions) {
        guard nil == (inScene as? UIWindowScene) else { return }
    }

    /* ################################################################## */
    /**
     Called when the application has finished setup.
     
     - parameter: The application instance
     - parameter didFinishLaunchingWithOptions: Any options in the launch.
     
     - returns: True, always.
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
}

/* ###################################################################################################################################### */
// MARK: UIWindowSceneDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_AppSceneDelegate: UIWindowSceneDelegate {
    /* ################################################################## */
    /**
     Returns the default scene config.
     
     - parameter: The application instance
     - parameter configurationForConnecting: The connecting session
     - parameter options: Any options
     
     - returns: the default scene config.
     */
    func application(_: UIApplication, configurationForConnecting inConnectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: inConnectingSceneSession.role)
    }
}
