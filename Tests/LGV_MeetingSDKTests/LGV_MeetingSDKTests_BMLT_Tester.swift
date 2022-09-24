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

import XCTest
import LGV_MeetingSDK
import CoreLocation

/* ###################################################################################################################################### */
// MARK: - BMLT Tests -
/* ###################################################################################################################################### */
/**
 This tests the BMLT SDK.
 */
final class LGV_MeetingSDKTests_BMLT_Tester: XCTestCase {
    /* ################################################################################################################################## */
    // MARK: Class Setup
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The organization key to use for the test organization.
     */
    let organizationKey: String = "BMLT"
    
    /* ################################################################## */
    /**
     The name to use for the test organization.
     */
    let organizationName: String = "BMLT-Enabled"
    
    /* ################################################################## */
    /**
     The description to use for the test organization.
     */
    let organizationDescription = "BMLT-Enabled is an independent, non-profit management entity for the Basic Meeting List Toolbox Initiative."
    
    /* ################################################################## */
    /**
     The URL to use for the test organization.
     */
    let organizationURL = URL(string: "https://bmlt.app")
    
    /* ################################################################## */
    /**
     This is the BMLT-specific instance.
     */
    var testSDK: LGV_MeetingSDK_BMLT?

    /* ################################################################## */
    /**
     This tests the basic setup of the BMLT SDK class.
     */
    func setup() {
        // This is a real URL for the TOMATO worldwide server. It's just here, for reference, if we need a real server, while developing: https://tomato.bmltenabled.org/main_server
        guard let rootServerURL = URL(string: "https://tomato.bmltenabled.org/main_server") // LGV_MeetingSDK_BMLT.Transport.testingRootServerURL
        else {
            XCTFail("This should not happen.")
            return
        }
        
        let testingOrganization = LGV_MeetingSDK_Generic_Organization(transport: LGV_MeetingSDK_BMLT.Transport(rootServerURL: rootServerURL),
                                                                      organizationKey: organizationKey,
                                                                      organizationName: organizationName,
                                                                      organizationDescription: organizationDescription,
                                                                      organizationURL: organizationURL
        )
        testSDK = LGV_MeetingSDK_BMLT(organization: testingOrganization)
        
        XCTAssert(testSDK?.organization === testingOrganization)
        XCTAssert(testSDK?.organization?.transport?.organization === testingOrganization)
    }

    /* ################################################################################################################################## */
    // MARK: Test Functions
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This tests the basic setup of the BMLT SDK class.
     */
    func testSetup() {
        setup()
        XCTAssert(testSDK?.organization?.sdkInstance === testSDK)
        XCTAssert(testSDK?.organization?.transport?.sdkInstance === testSDK)
        XCTAssert(testSDK?.organization?.transport is LGV_MeetingSDK_BMLT.Transport)
        XCTAssert(testSDK?.organization?.transport?.initiator is LGV_MeetingSDK_BMLT.Transport.Initiator)
        XCTAssert(testSDK?.organization?.transport?.initiator.parser is LGV_MeetingSDK_BMLT.Transport.Parser)
        XCTAssertEqual(testSDK?.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK?.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK?.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK?.organization?.organizationURL, organizationURL)
        XCTAssertEqual((testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.rootServerURL, LGV_MeetingSDK_BMLT.Transport.testingRootServerURL)
    }
    
    /* ################################################################## */
    /**
     */
    func testRadiusSearch() {
        setup()
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: CLLocationCoordinate2D(latitude: 34.23568825049199, longitude: -118.56374567190156), radiusInMeters: 1000), refinements: []) { inData, inError in
            print("\(inData.debugDescription), \(inError?.localizedDescription ?? "ERROR")")
        }
    }
}
