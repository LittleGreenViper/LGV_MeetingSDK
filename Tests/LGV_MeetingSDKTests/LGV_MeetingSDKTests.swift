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
// MARK: - Basic Setup Tests -
/* ###################################################################################################################################### */
/**
 */
final class LGV_MeetingSDKTests_Setup: XCTestCase {
    /* ################################################################## */
    /**
     We set the system up with dummy structs and classes, and make sure that they are stored properly.
     */
    func testInstantiation() throws {
        /* ############################################################################################################################## */
        // MARK: - Parser Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty placeholder parser. It does nothing.
         */
        struct Empty_Parser: LGV_MeetingSDK_Parser_Protocol {
            /* ########################################################## */
            /**
             This is a "dummy parser" for testing instantiation.
             
             - parameter data: Ignored.
             
             - returns: An empty parse set.
             */
            func parseThis(data: Data) -> LGV_MeetingSDK_Meeting_Data_Set {
                LGV_MeetingSDK_Meeting_Data_Set()
            }
        }

        /* ############################################################################################################################## */
        // MARK: - Transport Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty "placeholder" transport.
         */
        struct Dummy_Transport: LGV_MeetingSDK_Transport_Protocol {
            /* ########################################################## */
            /**
             The dummy parser goes here.
             */
            var parser: LGV_MeetingSDK_Parser_Protocol
            
            /* ########################################################## */
            /**
             This will remain nil.
             */
            var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
        }

        let organizationKey: String = "MockNA"
        let organizationName: String = "Mocked NA"
        let organizationDescription = "Not Real NA"
        let organizationURL = URL(string: "http://example.com")
        
        // We simply test that the organization and parser are assigned to the correct place, upon instantiation of the main struct.
        let testSDK = LGV_MeetingSDK(organization: LGV_MeetingSDK_Generic_Organization(transport: Dummy_Transport(parser: Empty_Parser()),
                                                                                       organizationKey: organizationKey,
                                                                                       organizationName: organizationName,
                                                                                       organizationDescription: organizationDescription,
                                                                                       organizationURL: organizationURL
                                                                                      )
        )

        XCTAssert(testSDK.organization is LGV_MeetingSDK_Generic_Organization)
        XCTAssert(testSDK.transport is Dummy_Transport)
        XCTAssert(testSDK.transport?.parser is Empty_Parser)

        XCTAssert(testSDK.organization?.transport is Dummy_Transport)
        XCTAssert(testSDK.organization?.transport?.parser is Empty_Parser)
        
        XCTAssertEqual(testSDK.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK.organization?.organizationURL, organizationURL)
    }
}
