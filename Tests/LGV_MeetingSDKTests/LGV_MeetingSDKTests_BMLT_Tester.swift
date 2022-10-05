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
        guard let rootServerURL = LGV_MeetingSDK_BMLT.Transport.testingRootServerURL
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
    }
    
    /* ################################################################## */
    /**
     Test the fixed radius search.
     */
    func testFixedRadiusSearch() {
        setup()
        var expectation = XCTestExpectation(description: "Callback never occurred.")

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(0)
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 3000), refinements: []) { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(37, inData?.meetings.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
      
        expectation = XCTestExpectation(description: "Callback never occurred.")

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(8)
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 3000), refinements: [.string(searchString: "gratitude")]) { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(7, inData?.meetings.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     Test the auto radius search.
     */
    func testAutoRadiusSearch() {
        setup()

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(1)
        
        let expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 10, maxRadiusInMeters: 20000), refinements: []) { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(10, inData?.meetings.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
    }
    
    /* ################################################################## */
    /**
     Test the search, with the IDs of a few meetings.
     */
    func testIDSearch() {
        setup()
        let ids: [UInt64] = [432, 1185, 1184, 3704, 1751, 1792, 1968, 2147, 2180, 2341, 2344, 2434]

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(2)
        
        var expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: []) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(ids.count, inData?.meetings.count)
            XCTAssertTrue(inData?.meetings.allSatisfy({ ids.contains($0.id) }) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(5)
        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: [.weekdays([.tuesday, .wednesday])]) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(3, inData?.meetings.count)
            XCTAssertTrue(inData?.meetings.allSatisfy({ ids.contains($0.id) }) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(6)
        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: [.startTimeRange(TimeInterval(14 * 60 * 60)...TimeInterval(19 * 60 * 60))]) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(3, inData?.meetings.count)
            XCTAssertTrue(inData?.meetings.allSatisfy({ ids.contains($0.id) }) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(7)
        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: [.startTimeRange(TimeInterval(14 * 60 * 60)...TimeInterval(19 * 60 * 60)), .weekdays([.tuesday, .wednesday])]) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(1, inData?.meetings.count)
            XCTAssertTrue(inData?.meetings.allSatisfy({ ids.contains($0.id) }) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(2)
        
        expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .meetingID(ids: ids), refinements: [.distanceFrom(thisLocation: testLocationCenter)]) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(ids.count, inData?.meetings.count)
            XCTAssertTrue(inData?.meetings.allSatisfy({ ids.contains($0.id) }) ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.25)

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(2)
    }
    
    /* ################################################################## */
    /**
     Test the search with a giant response (32,000 meetings).
     */
    func testCompleteTomatoDatasetSearch() {
        setup()

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(3)
        
        let expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .none, refinements: []) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(32710, inData?.meetings.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    /* ################################################################## */
    /**
     Test the search with a quardrupled full dataset response (130,000 meetings).
     */
    func testFullMontySearch() {
        setup()

        (testSDK?.organization?.transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = getResponseFile(4)
        
        let expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .none, refinements: []) { inData, inError in
            guard nil == inError else {
                print("ID Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            XCTAssertEqual(130840, inData?.meetings.count)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
