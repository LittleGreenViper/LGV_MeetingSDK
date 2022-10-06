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
// MARK: - Base class for the "Live Server" BMLT Tests -
/* ###################################################################################################################################### */
/**
 This is a base class for the BMLT-specific "live server" tests.
 */
class LGV_MeetingSDKTests_BMLT_Base: XCTestCase {
    /* ################################################################################################################################## */
    // MARK: Class Setup
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The coordinates we'll use for our searches (Central Park, NYC).
     */
    let testLocationCenter = CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665)
    
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
     This is the worldwide "TOMATO" server aggregator.
     */
    let worldwideAggregatorServerURL = URL(string: "https://tomato.bmltenabled.org/main_server")
    
    /* ################################################################## */
    /**
     This is the URL for the server that actually handles the area we are testing.
     */
    let specificServerURL = URL(string: "https://bmlt.newyorkna.org/main_server/")
    
    /* ################################################################## */
    /**
     This tests the basic setup of the BMLT SDK class.
     
     - parameter useTomatoServer (OPTIONAL): If true (default is false), the worldwide TOMATO server will be used. Otherwise, the local New York-area server will be used.
     */
    func setup(useTomatoServer: Bool = false) {
        guard let rootServerURL = useTomatoServer ? worldwideAggregatorServerURL : specificServerURL
        else {
            XCTFail("This should not happen.")
            return
        }
        testSDK = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
        
        XCTAssert(testSDK?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssert(testSDK?.organization?.transport?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssertEqual(testSDK?.organization?.transport?.baseURL, rootServerURL)
    }
}
