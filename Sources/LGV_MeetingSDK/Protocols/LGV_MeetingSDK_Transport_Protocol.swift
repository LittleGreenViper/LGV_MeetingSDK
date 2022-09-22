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
// MARK: - Search Initiator Additional Modifiers Weekdays Enum -
/* ###################################################################################################################################### */
/**
 This integer-based enum is a 1-based weekday specifier for the `LGV_MeetingSDK_SearchInitiator_Search_Modifiers.weekdays` specialization.
 */
public enum LGV_MeetingSDK_SearchInitiator_Search_Modifiers_Weekdays: Int, CaseIterable {
    /* ################################################################## */
    /**
     Sunday is always 1. The start of week is not taken into account, and should be handled at a level above this connector.
     */
    case sunday = 1
    
    /* ################################################################## */
    /**
     Monday
     */
    case monday
    
    /* ################################################################## */
    /**
     Tuesday
     */
    case tuesday
    
    /* ################################################################## */
    /**
     Wednesday
     */
    case wednesday
    
    /* ################################################################## */
    /**
     Thursday
     */
    case thursday
    
    /* ################################################################## */
    /**
     Friday
     */
    case friday
    
    /* ################################################################## */
    /**
     Saturday (Maximum value of 7).
     */
    case saturday
}

/* ###################################################################################################################################### */
// MARK: - Search Initiator Search Types Enum -
/* ###################################################################################################################################### */
/**
 These are enums that describe the "main" search parameters.
 */
public enum LGV_MeetingSDK_SearchInitiator_SearchType {
    /* ################################################################## */
    /**
     No search made.
     */
    case none
    
    /* ################################################################## */
    /**
     This means that the search will sweep up every meeting within `radiusInMeters` meters of `centerLongLat`.
     */
    case fixedRadius(centerLongLat: CLLocationCoordinate2D, radiusInMeters: CLLocationDistance)
    
    /* ################################################################## */
    /**
     This means that the search will start at `centerLongLat`, and move outward, in "rings," until it gets at least the `minimumNumberOfResults` number of meetings, and will stop there.
     We deliberately do not specify the "width" of these "rings," because the server may have its own ideas. A conformant implementation of the initiator could be used to allow the width to be specified.
     */
    case autoRadius(centerLongLat: CLLocationCoordinate2D, minimumNumberOfResults: UInt, maxRadiusInMeters: CLLocationDistance)
    
    /* ################################################################## */
    /**
     This is a very basic Array of individual meeting IDs.
     */
    case meetingID(ids: [UInt64])
    
    /* ################################################################## */
    /**
     This allows a string to be submitted for a search.
     */
    case string(searchString: String)
}

/* ###################################################################################################################################### */
// MARK: - Search Initiator Additional Modifiers Enum -
/* ###################################################################################################################################### */
/**
 The main search can have "modifiers" applied, that filter the response further.
 */
public enum LGV_MeetingSDK_SearchInitiator_Search_Modifiers: Hashable {
    /* ################################################################## */
    /**
     This means don't apply any modifiers to the main search.
     */
    case none
    
    /* ################################################################## */
    /**
     This allows us to provide a filter for the venue type, in our search.
     */
    case venueTypes(Set<LGV_MeetingSDK_VenueType_Enum>)
    
    /* ################################################################## */
    /**
     This allows us to specify certain weekdays to be returned.
     */
    case weekdays(Set<LGV_MeetingSDK_SearchInitiator_Search_Modifiers_Weekdays>)
    
    /* ################################################################## */
    /**
     This allows us to specify a range of times, from 0000 (midnight this morning), to 2400 (midnight tonight), inclusive.
     The times are specified in seconds (0...86400).
     Meetings that start within this range will be returned.
     */
    case startTimeRange(ClosedRange<TimeInterval>)
}

/* ###################################################################################################################################### */
// MARK: - The Parser Protocol -
/* ###################################################################################################################################### */
/**
 This defines the requirements for an instance of a data parser for the transport.
 */
public protocol LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - parameter searchType: OPTIONAL This is the search specification main search type.
     - parameter searchModifiers: OPTIONAL This is the search specification additional filters.
     - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.

     - returns: The parsed meeting information
     */
    func parseThis(searchType inSearchType: LGV_MeetingSDK_SearchInitiator_SearchType,
                   searchModifiers inSearchModifiers: Set<LGV_MeetingSDK_SearchInitiator_Search_Modifiers>,
                   data: Data) -> LGV_MeetingSDK_Meeting_Data_Set
}

/* ###################################################################################################################################### */
// MARK: - Search Initiator Protocol -
/* ###################################################################################################################################### */
/**
 This is supplied to a transport instance, and is used to form the searh "stimulus" commands, to be sent to the server.
 */
public protocol LGV_MeetingSDK_SearchInitiator_Protocol {
    /* ################################################################## */
    /**
     This is the callback made, when the search is complete.
     **NOTE:** This may not be called in the main thread.
     - parameter: Meeting Data, this is an optional (may be nil) of any returned (parsed) data. It will contain the original search specification parameters.
     - parameter: Error This is optional and will usually be nil. If an error was encountered during the search, it is returned here.
     */
    typealias MeetingSearchCallbackClosure = (_: LGV_MeetingSDK_Meeting_Data_Set?, _: Error?) -> Void
    
    /* ################################################################## */
    /**
     REQUIRED - The parser for meeting data.
     */
    var parser: LGV_MeetingSDK_Parser_Protocol { get }
    
    /* ################################################################## */
    /**
     REQUIRED - This executes a meeting search.
     - Parameters:
        - type: The main search type.
        - modifiers: a set of search filter modifiers.
        - completion: The completion closure.
     */
    func meetingSearch(type: LGV_MeetingSDK_SearchInitiator_SearchType,
                       modifiers: Set<LGV_MeetingSDK_SearchInitiator_Search_Modifiers>,
                       completion: MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: - The Transport Layer Protocol -
/* ###################################################################################################################################### */
/**
 This defines requirements for a loosely-coupled transport layer.
 */
public protocol LGV_MeetingSDK_Transport_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The initiator, for creating search commands.
     */
    var initiator: LGV_MeetingSDK_SearchInitiator_Protocol { get }
    
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
    var baseURL: URL? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Transport_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var baseURL: URL? { nil }
    
    /* ################################################################## */
    /**
     The default simply returns the organization's SDK instance.
     */
    var sdkInstance: LGV_MeetingSDK? { organization?.sdkInstance }
}
