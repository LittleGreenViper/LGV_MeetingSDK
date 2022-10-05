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
// MARK: - Basic "Live Server" BMLT Tests -
/* ###################################################################################################################################### */
/**
 This tests the BMLT SDK, but using a connection to the "live" TOMATO server.
 */
final class LGV_MeetingSDKTests_LiveServerBMLT_Basics: XCTestCase {
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
     The URL to use for the test organization.
     */
    let organizationTransportServerURL = URL(string: "https://tomato.bmltenabled.org/main_server")

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
        guard let rootServerURL = organizationTransportServerURL
        else {
            XCTFail("This should not happen.")
            return
        }
        testSDK = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
        
        XCTAssert(testSDK?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssert(testSDK?.organization?.transport?.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssertEqual(testSDK?.organization?.transport?.baseURL, rootServerURL)
    }
    
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
     This tests the basic setup of the BMLT SDK class.
     */
    func testSimpleAutoRadiusSearch() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")

        setup()

        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?

        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 10, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }

            searchResults = inData

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10)

        XCTAssertGreaterThanOrEqual(searchResults?.meetings.count ?? 0, 10)  // 10 is an approximate target. We may often get more.

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }

            searchResults = inData

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10)

        XCTAssertGreaterThanOrEqual(searchResults?.meetings.count ?? 0, 20)

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: 10), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }

            searchResults = inData

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 20)

        XCTAssertTrue(searchResults?.meetings.isEmpty ?? false)

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")

        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: 1000), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }

            searchResults = inData

            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)

        searchResults?.meetings.forEach {
            XCTAssertLessThanOrEqual($0.distanceInMeters, 1000)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: 1600), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        
        searchResults?.meetings.forEach {
            XCTAssertLessThanOrEqual($0.distanceInMeters, 1600)
        }
    }
    
    /* ################################################################## */
    /**
     This tests the basic setup of the BMLT SDK class.
     */
    func testSimpleFixedRadiusSearch() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        setup()
        
        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
    }
}
