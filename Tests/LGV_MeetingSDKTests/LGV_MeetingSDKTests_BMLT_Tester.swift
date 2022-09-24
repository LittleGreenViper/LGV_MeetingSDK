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
     The coordinates we'll use for our searches.
     */
    let testLocationCenter = CLLocationCoordinate2D(latitude: 34.23568825049199, longitude: -118.56374567190156)
    
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
     This fetches the testing bundle.
     */
    var myBundle: Bundle { Bundle(for: type(of: self)) }
    
    /* ################################################################## */
    /**
     This fetches a JSON file from the bundle, specified by its index.
     
     - parameter inFileIndex: The 0-based index of the JSON file in the testing bundle.
    
     - returns: The JSON String, packaged as a Data instance. Nil, if an error.
     */
    func getResponseFile(_ inFileIndex: Int ) -> Data? {
        if let filepath = myBundle.path(forResource: "SearchResponse-\(String(format: "%02d", inFileIndex))", ofType: "json") {
            do {
                let jsonFile = try String(contentsOfFile: filepath)
                return jsonFile.data(using: .utf8)
            } catch {
            }
        }
        
        XCTFail("JSON File Not Found for \(inFileIndex)!")
        return nil
    }
    
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
        testSDK = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
        
        XCTAssert(testSDK?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssert(testSDK?.organization?.transport?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssertEqual(testSDK?.organization?.transport?.baseURL, rootServerURL)
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
        XCTAssert(testSDK?.organization?.transport?.initiator?.parser is LGV_MeetingSDK_BMLT.Transport.Parser)
        XCTAssertEqual(testSDK?.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK?.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK?.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK?.organization?.organizationURL, organizationURL)
//        XCTAssertEqual((testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.baseURL, LGV_MeetingSDK_BMLT.Transport.testingRootServerURL)
    }
    
    /* ################################################################## */
    /**
     Test the fixed radius search.
     */
    func testFixedRadiusSearch() {
        setup()
        let expectation = XCTestExpectation(description: "Callback never occurred.")

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(0)
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: []) { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            expectation.fulfill()
            
            print("Fixed Radius Meeting Search Complete.")
            print("\tCalling URL: \(inData?.extraInfo ?? "ERROR")")
            print("\tMeetings: \(String(describing: inData?.meetings))")
        }
        
        wait(for: [expectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     Test the auto radius search.
     */
    func testAutoRadiusSearch() {
        setup()
        let expectation = XCTestExpectation(description: "Callback never occurred.")

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(1)
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 10, maxRadiusInMeters: 20000), refinements: []) { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            expectation.fulfill()
            
            print("Auto Radius Meeting Search Complete.")
            print("\tCalling URL: \(inData?.extraInfo ?? "ERROR")")
            print("\tMeetings: \(String(describing: inData?.meetings))")
        }
        
        wait(for: [expectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     Test the auto radius search.
     */
    func testIDSearch() {
        setup()
        let expectation = XCTestExpectation(description: "Callback never occurred.")
        let ids: [UInt64] = [402,
                             403,
                             425,
                             428,
                             432,
                             433,
                             435,
                             439,
                             1184,
                             1185,
                             1189,
                             1190,
                             1191,
                             1192,
                             1198,
                             1202,
                             1751,
                             1766,
                             1783,
                             1788,
                             1789,
                             1792,
                             1795,
                             1881,
                             1968,
                             1970,
                             1973,
                             2030,
                             2034,
                             2035,
                             2040,
                             2063,
                             2077,
                             2107,
                             2140,
                             2147,
                             2152,
                             2153,
                             2180,
                             2190,
                             2324,
                             2326,
                             2328,
                             2330,
                             2331,
                             2333,
                             2334,
                             2335,
                             2336,
                             2339,
                             2341,
                             2342,
                             2344,
                             2345,
                             2346,
                             2358,
                             2391,
                             2421,
                             2423,
                             2425,
                             2430,
                             2431,
                             2434,
                             2435,
                             2437,
                             2441,
                             2448,
                             2451,
                             2506,
                             3704,
                             5397,
                             5494
                             ]

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(2)
        
        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: []) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            expectation.fulfill()
            
            print("ID Meeting Search Complete.")
            print("\tCalling URL: \(inData?.extraInfo ?? "ERROR")")
            print("\tMeetings: \(String(describing: inData?.meetings))")
        }
        
        wait(for: [expectation], timeout: 0.25)
    }
}
