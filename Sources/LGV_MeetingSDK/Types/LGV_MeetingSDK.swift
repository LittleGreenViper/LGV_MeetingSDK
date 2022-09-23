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
// MARK: - The Parsed Meeting Search Information Class -
/* ###################################################################################################################################### */
/**
 This defines a class, containing a "found set" of meeting data.
 It is defined as a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
 */
open class LGV_MeetingSDK_Meeting_Data_Set: LGV_MeetingSDK_Meeting_Data_Set_Protocol {
    /* ################################################################################################################################## */
    // MARK: - Search Initiator Additional Modifiers Weekdays Enum -
    /* ################################################################################################################################## */
    /**
     This integer-based enum is a 1-based weekday specifier for the `LGV_MeetingSDK_SearchInitiator_Search_Modifiers.weekdays` specialization.
     */
    public enum Weekdays: Int, CaseIterable {
        /* ############################################################## */
        /**
         Sunday is always 1. The start of week is not taken into account, and should be handled at a level above this connector.
         */
        case sunday = 1
        
        /* ############################################################## */
        /**
         Monday
         */
        case monday
        
        /* ############################################################## */
        /**
         Tuesday
         */
        case tuesday
        
        /* ############################################################## */
        /**
         Wednesday
         */
        case wednesday
        
        /* ############################################################## */
        /**
         Thursday
         */
        case thursday
        
        /* ############################################################## */
        /**
         Friday
         */
        case friday
        
        /* ############################################################## */
        /**
         Saturday (Maximum value of 7).
         */
        case saturday
    }

    /* ################################################################################################################################## */
    // MARK: - Search Initiator Search Types Enum -
    /* ################################################################################################################################## */
    /**
     These are enums that describe the "main" search parameters.
     */
    public enum SearchType {
        /* ############################################################## */
        /**
         No search made.
         */
        case none
        
        /* ############################################################## */
        /**
         This means that the search will sweep up every meeting within `radiusInMeters` meters of `centerLongLat`.
         */
        case fixedRadius(centerLongLat: CLLocationCoordinate2D, radiusInMeters: CLLocationDistance)
        
        /* ############################################################## */
        /**
         This means that the search will start at `centerLongLat`, and move outward, in "rings," until it gets at least the `minimumNumberOfResults` number of meetings, and will stop there.
         We deliberately do not specify the "width" of these "rings," because the server may have its own ideas. A conformant implementation of the initiator could be used to allow the width to be specified.
         */
        case autoRadius(centerLongLat: CLLocationCoordinate2D, minimumNumberOfResults: UInt, maxRadiusInMeters: CLLocationDistance)
        
        /* ############################################################## */
        /**
         This is a very basic Array of individual meeting IDs.
         */
        case meetingID(ids: [UInt64])
        
        /* ############################################################## */
        /**
         This allows a string to be submitted for a search.
         */
        case string(searchString: String)
    }

    /* ################################################################################################################################## */
    // MARK: - Search Initiator Additional Modifiers Enum -
    /* ################################################################################################################################## */
    /**
     The main search can have "modifiers" applied, that filter the response further.
     */
    public enum Search_Modifiers: Hashable {
        /* ############################################################## */
        /**
         This means don't apply any modifiers to the main search.
         */
        case none
        
        /* ############################################################## */
        /**
         This allows us to provide a filter for the venue type, in our search.
         */
        case venueTypes(Set<LGV_MeetingSDK_VenueType_Enum>)
        
        /* ############################################################## */
        /**
         This allows us to specify certain weekdays to be returned.
         */
        case weekdays(Set<Weekdays>)
        
        /* ############################################################## */
        /**
         This allows us to specify a range of times, from 0000 (midnight this morning), to 2400 (midnight tonight), inclusive.
         The times are specified in seconds (0...86400).
         Meetings that start within this range will be returned.
         */
        case startTimeRange(ClosedRange<TimeInterval>)
    }

    /* ############################################################## */
    /**
     This is the search specification main search type.
     */
    public let searchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType
    
    /* ############################################################## */
    /**
     This is the search specification additional filters.
     */
    public let searchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>
    
    /* ############################################################## */
    /**
     This contains any found meetings. It may be empty (no meetings found).
     */
    public let meetings: [LGV_MeetingSDK_Meeting_Protocol]

    /* ############################################################## */
    /**
     Default initializer.
     
     - parameter searchType: OPTIONAL This is the search specification main search type. Default is .none.
     - parameter searchModifiers: OPTIONAL This is the search specification additional filters. Default is an empty set.
     - parameter meetings: OPTIONAL This contains any found meetings. It may be empty or omitted (no meetings found).
     */
    public init(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType = .none,
                searchModifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers> = [],
                meetings inMeetings: [LGV_MeetingSDK_Meeting_Protocol] = []) {
        searchType = inSearchType
        searchModifiers = inSearchModifiers
        meetings = inMeetings
    }
}

/* ###################################################################################################################################### */
// MARK: - Main SDK struct -
/* ###################################################################################################################################### */
/**
 This is instantiated, in order to provide meeting search capabilities for one organization.
 This is a class, so it can be specialized, and referenced.
 */
open class LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the organization that applies to this search instance. This is a strong reference.
     */
    private var _organization: LGV_MeetingSDK_Organization_Transport_Protocol?

    /* ################################################################## */
    /**
     The "cached" last search. It may be nil (no last search cached).
     */
    private var _lastSearch: LGV_MeetingSDK_Meeting_Data_Set?

    /* ################################################################################################################################## */
    // MARK: Main Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the default initializer for the search SDK.
     */
    public init(organization inOrganization: LGV_MeetingSDK_Organization_Transport_Protocol) {
        _organization = inOrganization
        _organization?.sdkInstance = self
    }
}

/* ###################################################################################################################################### */
// MARK: LGV_MeetingSDK_Protocol Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK: LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     This is the organization that applies to this search instance.
     */
    public var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { _organization }
    
    /* ################################################################## */
    /**
     The "cached" last search. It may be nil (no last search cached).
     */
    public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set? { _lastSearch }
}

/* ###################################################################################################################################### */
// MARK: - Generic Organization struct -
/* ###################################################################################################################################### */
/**
 This is a "general-purpose" organization class that should work for most requirements.
 */
public class LGV_MeetingSDK_Generic_Organization: LGV_MeetingSDK_Organization_Transport_Protocol {
    /* ########################################################## */
    /**
     We store the transport in a private property, and access it, via a computed one. This is a strong reference.
     */
    private var _transport: LGV_MeetingSDK_Transport_Protocol?
    
    /* ################################################################## */
    /**
     We store the description in a private property, and access it, via a computed one.
     */
    private var _organizationDescription: String?

    /* ################################################################## */
    /**
     We store the URL in a private property, and access it, via a computed one.
     */
    private var _organizationURL: URL?

    /* ################################################################## */
    /**
     The SDK instance to which this organization is assigned. This is a weak reference.
     */
    public weak var sdkInstance: LGV_MeetingSDK?
    
    /* ################################################################## */
    /**
     This is the unique key for the organization. This should be unique in the SDK execution environment.
     */
    public var organizationKey: String
    
    /* ################################################################## */
    /**
     This is a short name for the organization.
     */
    public var organizationName: String

    /* ########################################################## */
    /**
     This is the accessor for the transport private property.
     */
    public var transport: LGV_MeetingSDK_Transport_Protocol? { _transport }
    
    /* ################################################################## */
    /**
     This is the accessor for the description private property.
     */
    public var organizationDescription: String? { _organizationDescription }

    /* ################################################################## */
    /**
     This is the accessor for the URL private property.
     */
    public var organizationURL: URL? { _organizationURL }
    
    /* ################################################################## */
    /**
     The default initializer.
     
     - Parameters:
        - transport (REQUIRED): This is a required argument. It will be the transport instance to be used with this organization.
        - organizationKey (REQUIRED): This is a required argument. The organization key. This should be unique, in the SDK execution context.
        - organizationName (OPTIONAL): The name of the organization. Default is an empty String.
        - organizationName (OPTIONAL): A longer description for the organization. Default is nil.
        - organizationURL (OPTIONAL): A URL for the organization. Default is nil.
     */
    public init(transport inTransport: LGV_MeetingSDK_Transport_Protocol,
                organizationKey inOrganizationKey: String,
                organizationName inOrganizationName: String = "",
                organizationDescription inOrganizationDescription: String? = nil,
                organizationURL inOrganizationURL: URL? = nil
        ) {
        organizationKey = inOrganizationKey
        organizationName = inOrganizationName
        _organizationDescription = inOrganizationDescription
        _organizationURL = inOrganizationURL
        _transport = inTransport
        _transport?.organization = self
    }
}
