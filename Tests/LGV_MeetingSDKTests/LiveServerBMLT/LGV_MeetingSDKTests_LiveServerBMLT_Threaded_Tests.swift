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

/* ###################################################################################################################################### */
// MARK: - Simultaneous Threaded Call BMLT Tests -
/* ###################################################################################################################################### */
/**
 This tests the BMLT SDK, using a "live" connection, and multiple simultaneous calls.
 */
class LGV_MeetingSDKTests_LiveServerBMLT_Threaded_Tests: LGV_MeetingSDKTests_BMLT_Base {
    /* ################################################################## */
    /**
     This describes one Root Server entity.
     */
    typealias RootServerEntity = (name: String, rootURL: String)

    /* ################################################################## */
    /**
     Returns a list of all the root servers.
     */
    class var rootServerList: [RootServerEntity] {
        var ret = [RootServerEntity]()
        if let filepath = Bundle(for: LGV_MeetingSDKTests_LiveServerBMLT_Threaded_Tests.self).path(forResource: "rootServerList", ofType: "json") {
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

        return ret
    }
    
    /* ################################################################## */
    /**
     */
    func testAllRootServersSimultaneously() {
        var expectation: XCTestExpectation
        
        expectation = XCTestExpectation(description: "Callback never occurred.")

        var sdkInstances = [LGV_MeetingSDK_BMLT]()
        for server in Self.rootServerList {
            let serverName = server.name
            if let serverURL = URL(string: server.rootURL) {
                let sdkInstance = LGV_MeetingSDK_BMLT(rootServerURL: serverURL)
                sdkInstance.organization?.organizationName = serverName
                sdkInstance.organization?.organizationURL = serverURL
                sdkInstances.append(sdkInstance)
            }
        }
        
        XCTAssertFalse(sdkInstances.isEmpty)
        expectation.expectedFulfillmentCount = sdkInstances.count
        
        sdkInstances.forEach {
            $0.meetingSearch(type: .fixedRadius(centerLongLat: testLocationCenter, radiusInMeters: 1000), refinements: [], completion: { inData, inError in
                guard nil == inError else {
                    print("Fixed Radius Meeting Search Error: \(inError?.localizedDescription ?? "ERROR")")
                    return
                }

                expectation.fulfill()
            })
        }
        
        wait(for: [expectation], timeout: 30)
        print("Done!")
    }
}