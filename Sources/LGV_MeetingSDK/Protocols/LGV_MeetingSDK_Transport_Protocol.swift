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

import CoreLocation

/* ###################################################################################################################################### */
// MARK: - The Parser Protocol -
/* ###################################################################################################################################### */
/**
 This defines the requirements for an instance of a data parser for the transport.
 */
public protocol LGV_MeetingSDK_Parser_Protocol: AnyObject {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - Parameters:
        - searchType (OPTIONAL): This is the search specification main search type.
        - searchRefinements (OPTIONAL): This is the search specification additional filters.
        - data: The unparsed data, from the transport. It should consist of a meeting data set.
        - refCon: An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion: A callback, for when the parse is complete. This is escaping, and may not be called in the main thread.
     */
    func parseThis(searchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                   searchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                   data: Data,
                   refCon: Any?,
                   completion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: - Search Initiator Protocol -
/* ###################################################################################################################################### */
/**
 This is supplied to a transport instance, and is used to form the searh "stimulus" commands, to be sent to the server.
 */
public protocol LGV_MeetingSDK_SearchInitiator_Protocol: AnyObject {
    /* ################################################################## */
    /**
     This is the callback made, when the search is complete.
     
     > Warning: This may not be called in the main thread.
     
     - parameter: Meeting Data, this is an optional (may be nil) of any returned (parsed) data. It will contain the original search specification parameters.
     - parameter: Error This is optional and will usually be nil. If an error was encountered during the search, it is returned here.
     */
    typealias MeetingSearchCallbackClosure = (_: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _: Error?) -> Void
    
    /* ################################################################## */
    /**
     REQUIRED - The parser for meeting data.
     */
    var parser: LGV_MeetingSDK_Parser_Protocol { get }
    
    /* ################################################################## */
    /**
     OPTIONAL (BUT ACTUALLY REQUIRED) - The transport to be used for this initiator.
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? { get set }

    /* ################################################################## */
    /**
     REQUIRED - This executes a meeting search.
     - Parameters:
        - type: The main search type.
        - refinements: a set of search filter refinements.
        - refCon: An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion: The completion closure.
     */
    func meetingSearch(type: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                       refinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                       refCon: Any?,
                       completion: @escaping MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults.
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_SearchInitiator_Protocol {
    /* ################################################################## */
    /**
     The default is nils, all the way down.
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? {
        get { nil }
        set { _ = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Transport Layer Protocol -
/* ###################################################################################################################################### */
/**
 This defines requirements for a loosely-coupled transport layer.
 */
public protocol LGV_MeetingSDK_Transport_Protocol: AnyObject {
    /* ################################################################## */
    /**
     REQUIRED - The initiator, for creating search commands.
     */
    var initiator: LGV_MeetingSDK_SearchInitiator_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The parser, for parsing search commands.
     */
    var parser: LGV_MeetingSDK_Parser_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The transport organization to which this instance is assigned. It should generally be declared weak.
     */
    var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { get set }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The SDK instance to which this transport's organization is assigned.
     */
    var sdkInstance: LGV_MeetingSDK? { get }

    /* ################################################################## */
    /**
     OPTIONAL - The "base" URL for the transport target.
     */
    var baseURL: URL? { get set }
    
    /* ########################################################## */
    /**
     OPTIONAL - This is used to "short-circuit" the actual network call.
     
     If this is non-nil, then the Data instance is sent to the callback closure as a "one-shot" call. The property is immediately cleared, after being read.
     The URL is ignored.
     */
    var debugMockDataResponse: Data? { get set }
    
    /* ################################################################## */
    /**
     REQUIRED - Creates a URL Request, for the given search parameters.
     - Parameters:
        - type: Any search type that was specified.
        - refinements: Any search refinements.
     
     - returns: A new URL Request object, ready for a task.
     */
    func ceateURLRequest(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                         refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>
    ) -> URLRequest?
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Transport_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var baseURL: URL? {
        get { nil }
        set { _ = newValue }
    }
    
    /* ################################################################## */
    /**
     The default simply returns the organization's SDK instance.
     */
    var sdkInstance: LGV_MeetingSDK? { organization?.sdkInstance }
}
