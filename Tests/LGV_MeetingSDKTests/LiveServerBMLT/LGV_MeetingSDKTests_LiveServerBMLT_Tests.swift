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
// MARK: - More Involved "Live Server" BMLT Tests -
/* ###################################################################################################################################### */
/**
 This tests the BMLT SDK, but using a connection to the "live" TOMATO server.
 */
final class LGV_MeetingSDKTests_LiveServerBMLT_Tests: XCTestCase {
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
        guard let rootServerURL = organizationTransportServerURL
        else {
            XCTFail("This should not happen.")
            return
        }
        testSDK = LGV_MeetingSDK_BMLT(rootServerURL: rootServerURL)
    }

    /* ################################################################## */
    /**
     This tests the weekday refinement filter.
     */
    func testFixedRadiusSearchOnCertainDays() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        setup()
        
        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.sunday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(1, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.monday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(2, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.tuesday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(3, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.wednesday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(4, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.thursday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(5, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.friday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(6, $0.weekdayIndex)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.saturday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData

            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)

        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertEqual(7, $0.weekdayIndex)
        }
        
        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.saturday, .sunday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertTrue($0.weekdayIndex == 1 || $0.weekdayIndex == 7)
        }
        
        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.weekdays([.monday, .thursday, .tuesday, .friday, .wednesday])], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertFalse(searchResults?.meetings.isEmpty ?? true)
        searchResults?.meetings.forEach {
            XCTAssertTrue((2...6).contains($0.weekdayIndex))
        }
    }
    
    /* ################################################################## */
    /**
     This tests for the venue type refinement filter.
     */
    func testAutoRadiusSearchVenueType() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        setup()
        
        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [.venueTypes([.inPersonOnly])], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        searchResults?.meetings.forEach {
            XCTAssertEqual($0.meetingType, .inPersonOnly)
        }
        
        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [.venueTypes([.virtualOnly])], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        searchResults?.meetings.forEach {
            XCTAssertEqual($0.meetingType, .virtualOnly)
        }
        
        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [.venueTypes([.hybrid])], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        searchResults?.meetings.forEach {
            XCTAssertEqual($0.meetingType, .hybrid)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .autoRadius(centerLongLat: testLocationCenter, minimumNumberOfResults: 20, maxRadiusInMeters: Double.greatestFiniteMagnitude), refinements: [.venueTypes([.virtualOnly, .inPersonOnly])], completion: { inData, inError in
            guard nil == inError else {
                print("Auto Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 10)
        
        searchResults?.meetings.forEach {
            XCTAssertNotEqual($0.meetingType, .hybrid)
        }
    }
    
    /* ################################################################## */
    /**
     This tests the weekday refinement filter.
     */
    func testFixedRadiusSearchStartTimeRange() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        setup()
        
        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 10000), refinements: [.startTimeRange((0...1159))], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)
        
        searchResults?.meetings.forEach {
            XCTAssertLessThanOrEqual(1159, $0.meetingStartTime)
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 10000), refinements: [.startTimeRange((1200...1800))], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)
        
        searchResults?.meetings.forEach {
            XCTAssertTrue((1200...1800).contains($0.meetingStartTime))
        }

        searchResults = nil

        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 10000), refinements: [.startTimeRange((1801...2400))], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)
        
        searchResults?.meetings.forEach {
            XCTAssertTrue((1801...2400).contains($0.meetingStartTime))
        }
    }
    
    /* ################################################################## */
    /**
     This tests the weekday refinement filter.
     */
    func testFixedRadiusSearchDistanceFrom() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")
        
        setup()
        
        var searchResults: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
        
        let montaukLighthouse = CLLocationCoordinate2D(latitude: 41.0709, longitude: -71.8572)
        
        let centerDistance = CLLocation(latitude: testLocationCenter.latitude, longitude: testLocationCenter.longitude).distance(from: CLLocation(latitude: montaukLighthouse.latitude, longitude: montaukLighthouse.longitude))
        
        testSDK?.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [.distanceFrom(thisLocation: montaukLighthouse)], completion: { inData, inError in
            guard nil == inError else {
                print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                return
            }
            
            searchResults = inData
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 20)
        
        searchResults?.meetings.forEach {
            XCTAssertGreaterThanOrEqual(centerDistance + 1000, $0.distanceInMeters)
            XCTAssertLessThanOrEqual(centerDistance - 1000, $0.distanceInMeters)
        }
    }
}
