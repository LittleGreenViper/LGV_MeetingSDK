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
        class Empty_Parser: LGV_MeetingSDK_Parser_Protocol {
            /* ################################################################## */
            /**
             REQUIRED - This parses data, and returns meetings.
             
             - parameter searchType (OPTIONAL): This is the search specification main search type. Default is .none.
             - parameter searchRefinements (OPTIONAL): This is the search specification additional filters. Default is .none.
             - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
             */
            func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                           searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                           data inData: Data,
                           completion inCompletion: LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
                inCompletion(LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: []), nil)
            }
        }

        /* ############################################################################################################################## */
        // MARK: - Initiator Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty placeholder initiator. It does nothing.
         */
        class Empty_Initiator: LGV_MeetingSDK_SearchInitiator_Protocol {
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
                - refinements: Any search refinements.
                - completion: A completion function.
             */
            func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                               refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                               completion inCompletion: @escaping MeetingSearchCallbackClosure) {
                parser.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: Data(), completion: inCompletion)
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: - Transport Mock -
        /* ############################################################################################################################## */
        /**
         This is an empty "placeholder" transport.
         */
        class Dummy_Transport: LGV_MeetingSDK_Transport_Protocol {
            /* ########################################################## */
            /**
             The dummy initiator goes here.
             */
            var initiator: LGV_MeetingSDK_SearchInitiator_Protocol?
            
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
            init() {
                initiator = Empty_Initiator()
                initiator?.transport = self
            }
        }
        
        let expectation = XCTestExpectation(description: "Data Was Not Properly Set")

        // This just fulfills the expectation, so we know the callback was made.
        func dummyCompletion(_ inDataSet: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _: Error?) {
            guard case .none? = inDataSet?.searchType,
                  [] == inDataSet?.searchRefinements
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
        XCTAssert(testSDK.organization?.transport?.initiator?.parser is Empty_Parser)
        XCTAssert(testSDK.organization?.transport?.organization === organization)
        XCTAssert(testSDK.organization?.transport?.sdkInstance === testSDK)
        XCTAssertEqual(testSDK.organization?.organizationKey, organizationKey)
        XCTAssertEqual(testSDK.organization?.organizationName, organizationName)
        XCTAssertEqual(testSDK.organization?.organizationDescription, organizationDescription)
        XCTAssertEqual(testSDK.organization?.organizationURL, organizationURL)
        
        // Make sure that our callback is made.
        testSDK.meetingSearch(type: .none, refinements: [], completion: dummyCompletion)
        wait(for: [expectation], timeout: 0.25)
    }
}
