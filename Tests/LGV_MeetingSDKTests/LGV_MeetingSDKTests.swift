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
 This just sets up the default SDK, with a dummy initiator.
 */
final class LGV_MeetingSDKTests_Setup: XCTestCase {
    /* ################################################################## */
    /**
     We set the system up with dummy structs and classes, and make sure that they are stored properly.
     This also tests the basic setup of the generic organization.
     */
    func testInstantiation() throws {
        /* ############################################################################################################################## */
        // MARK: - Parser Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty placeholder parser. It does nothing.
         */
        struct Empty_Parser: LGV_MeetingSDK_Parser_Protocol {
            /* ################################################################## */
            /**
             REQUIRED - This parses data, and returns meetings.
             
             - parameter searchType: OPTIONAL This is the search specification main search type. Default is .none.
             - parameter searchModifiers: OPTIONAL This is the search specification additional filters. Default is .none.
             - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.

             - returns: An empty parse set
             */
            func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType,
                           searchModifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>,
                           data inData: Data) -> LGV_MeetingSDK_Meeting_Data_Set_Protocol {
                LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchModifiers: inSearchModifiers, meetings: [])
            }
        }

        /* ############################################################################################################################## */
        // MARK: - Initiator Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty placeholder initiator. It does nothing.
         */
        struct Empty_Initiator: LGV_MeetingSDK_SearchInitiator_Protocol {
            /* ########################################################## */
            /**
             The dummy parser goes here.
             */
            var parser: LGV_MeetingSDK_Parser_Protocol = Empty_Parser()

            /* ################################################################## */
            /**
             The transport to be used for this initiator.
             */
            var transport: LGV_MeetingSDK_Transport_Protocol?

            /* ################################################################## */
            /**
             This pretends to execute a meeting search.
             
             - Parameters:
                - type: Any search type that was specified.
                - modifiers: Any search modifiers.
                - completion: A completion function.
             */
            func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType,
                               modifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>,
                               completion inCompletion: MeetingSearchCallbackClosure) {
                inCompletion(parser.parseThis(searchType: inSearchType, searchModifiers: inSearchModifiers, data: Data()), nil)
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
             The dummy initiator goes here.
             */
            var initiator: LGV_MeetingSDK_SearchInitiator_Protocol = Empty_Initiator()
            
            /* ################################################################## */
            /**
             The transport organization to which this instance is assigned.
             */
            weak var organization: LGV_MeetingSDK_Organization_Transport_Protocol?
            
            /* ########################################################## */
            /**
             This will remain nil.
             */
            var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
            
            /* ########################################################## */
            /**
             The initiator uses us.
             */
            init() { initiator.transport = self }
        }
        
        let expectation = XCTestExpectation(description: "Data Was Not Properly Set")

        // This just fulfills the expectation, so we know the callback was made.
        func dummyCompletion(_ inDataSet: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _: Error?) {
            guard case .none? = inDataSet?.searchType,
                  [] == inDataSet?.searchModifiers
            else { return }
            expectation.fulfill()
        }

        let organizationKey: String = "MockNA"
        let organizationName: String = "Mocked NA"
        let organizationDescription = "Not Real NA"
        let organizationURL = URL(string: "http://example.com")
        let organization = LGV_MeetingSDK_Generic_Organization(transport: Dummy_Transport(),
                                                               organizationKey: organizationKey,
                                                               organizationName: organizationName,
                                                               organizationDescription: organizationDescription,
                                                               organizationURL: organizationURL
                                                              )
        // We simply test that the organization and parser are assigned to the correct place, upon instantiation of the main struct.
        let testSDK = LGV_MeetingSDK(organization: organization)

        // We make sure that everything is where it's supposed to be.
        XCTAssert(testSDK.organization === organization)
        XCTAssert(testSDK.organization?.sdkInstance === testSDK)
        XCTAssert(testSDK.organization?.transport is Dummy_Transport)
        XCTAssert(testSDK.organization?.transport?.initiator is Empty_Initiator)
        XCTAssert(testSDK.organization?.transport?.initiator.parser is Empty_Parser)
        XCTAssert(testSDK.organization?.transport?.organization === organization)
        XCTAssert(testSDK.organization?.transport?.sdkInstance === testSDK)
        XCTAssertEqual(testSDK.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK.organization?.organizationURL, organizationURL)
        
        // Make sure that our callback is made.
        testSDK.meetingSearch(type: .none, modifiers: [], completion: dummyCompletion)
        wait(for: [expectation], timeout: 0.25)
    }
}

/* ###################################################################################################################################### */
// MARK: - BMLT Tests -
/* ###################################################################################################################################### */
/**
 This tests the BMLT SDK.
 */
final class LGV_MeetingSDKTests_BMLT_Tester: XCTestCase {
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
        guard let rootServerURL = LGV_MeetingSDK_BMLT.Transport.testingRootServerURL
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
        XCTAssert(testSDK?.organization?.sdkInstance === testSDK)
        XCTAssert(testSDK?.organization?.transport?.organization === testingOrganization)
    }

    /* ################################################################## */
    /**
     This tests the basic setup of the BMLT SDK class.
     */
    func testSetup() {
        setup()
        XCTAssert(testSDK?.organization?.transport is LGV_MeetingSDK_BMLT.Transport)
        XCTAssert(testSDK?.organization?.transport?.initiator is LGV_MeetingSDK_BMLT.Transport.Initiator)
        XCTAssert(testSDK?.organization?.transport?.initiator.parser is LGV_MeetingSDK_BMLT.Transport.Parser)
        XCTAssert(testSDK?.organization?.transport?.sdkInstance === testSDK)
        XCTAssertEqual(testSDK?.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK?.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK?.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK?.organization?.organizationURL, organizationURL)
    }
}
