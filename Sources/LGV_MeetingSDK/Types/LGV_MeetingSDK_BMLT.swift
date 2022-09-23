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

import Foundation

/* ###################################################################################################################################### */
// MARK: - BMLT-Specialized SDK struct -
/* ###################################################################################################################################### */
/**
 This is a subclass of the main SDK class, that is "tuned" for [the BMLT](https://bmlt.app)
 */
open class LGV_MeetingSDK_BMLT: LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: - BMLT-Specific Transport Struct -
    /* ################################################################################################################################## */
    /**
     This transport is dedicated to the BMLT.
     We make this a class, so we can be weakly referenced.
     */
    public class Transport: LGV_MeetingSDK_Transport_Protocol {
        /* ########################################################## */
        /**
         This is a special dummy URL that we use to allow mocking.
         */
        public static let testingRootServerURL = URL(string: "https://example.com")
        
        /* ############################################################################################################################## */
        // MARK: - Parser -
        /* ############################################################################################################################## */
        /**
         */
        public struct Parser: LGV_MeetingSDK_Parser_Protocol {
            /* ################################################################## */
            /**
             REQUIRED - This parses data, and returns meetings.
             
             - parameter searchType: OPTIONAL This is the search specification main search type. Default is .none.
             - parameter searchModifiers: OPTIONAL This is the search specification additional filters. Default is .none.
             - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
             
             - returns: An empty parse set
             */
            public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType = .none,
                                  searchModifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers> = [],
                                  data inData: Data) -> LGV_MeetingSDK_Meeting_Data_Set_Protocol {
                LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchModifiers: inSearchModifiers, meetings: [])
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: - Initiator -
        /* ############################################################################################################################## */
        /**
         This is an initiator. It forms queries to the BMLT Root Server.
         */
        public struct Initiator: LGV_MeetingSDK_SearchInitiator_Protocol {
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _transport: Transport?
            
            /* ########################################################## */
            /**
             The parser goes here.
             */
            public var parser: LGV_MeetingSDK_Parser_Protocol = Parser()
            
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             */
            public var transport: LGV_MeetingSDK_Transport_Protocol? {
                get { _transport }
                set { _transport = newValue as? Transport }
            }

            /* ########################################################## */
            /**
             This executes a meeting search.
             
             - Parameters:
             - type: Any search type that was specified.
             - modifiers: Any search modifiers.
             - completion: A completion function.
             */
            public func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType,
                                      modifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>,
                                      completion inCompletion: MeetingSearchCallbackClosure) {
                inCompletion(parser.parseThis(searchType: inSearchType, searchModifiers: inSearchModifiers, data: Data()), nil)
            }
        }
        
        /* ########################################################## */
        /**
         The initiator goes here.
         */
        public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol = Initiator()
        
        /* ################################################################## */
        /**
         The transport organization to which this instance is assigned.
         */
        public weak var organization: LGV_MeetingSDK_Organization_Transport_Protocol?
        
        /* ########################################################## */
        /**
         This contains the last search result set.
         */
        public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
        
        /* ########################################################## */
        /**
         This will contain the URL to the Root Server that is being accessed by this transport instance.
         */
        public var rootServerURL: URL
        
        /* ########################################################## */
        /**
         Default initializer.
         
         - parameter rootServerURL: The URL to the BMLT Root Server that will be accessed by this instance.
         */
        public init(rootServerURL inRootServerURL: URL) {
            rootServerURL = inRootServerURL
            initiator.transport = self
        }
    }
}
