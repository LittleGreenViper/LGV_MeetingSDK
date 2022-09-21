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
// MARK: - Transport Mock -
/* ###################################################################################################################################### */
/**
 */
struct LGV_MeetingSDKTests_Transport: LGV_MeetingSDK_Transport_Protocol {
    
}

/* ###################################################################################################################################### */
// MARK: - Organization Mock -
/* ###################################################################################################################################### */
/**
 */
class LGV_MeetingSDKTests_Organization: LGV_MeetingSDK_Organization_Transport_Protocol {
    /* ################################################################## */
    /**
     */
    var transport: LGV_MeetingSDK_Transport_Protocol?
    
    /* ################################################################## */
    /**
     */
    var organizationKey: String
    
    /* ################################################################## */
    /**
     */
    var organizationName: String
    
    /* ################################################################## */
    /**
     */
    var organizationDescription: String

    /* ################################################################## */
    /**
     */
    init() {
        transport = LGV_MeetingSDKTests_Transport()
        organizationKey = "MockNA"
        organizationName = "Mocked NA"
        organizationDescription = "Not Real NA"
    }
}

/* ###################################################################################################################################### */
// MARK: - Basic Setup Tests -
/* ###################################################################################################################################### */
/**
 */
final class LGV_MeetingSDKTests_Setup: XCTestCase {
    /* ################################################################## */
    /**
     */
    func testInstantiation() throws {
        let testSDK = LGV_MeetingSDK(organization: LGV_MeetingSDKTests_Organization())
        XCTAssert(testSDK.transport is LGV_MeetingSDKTests_Transport)
    }
}
