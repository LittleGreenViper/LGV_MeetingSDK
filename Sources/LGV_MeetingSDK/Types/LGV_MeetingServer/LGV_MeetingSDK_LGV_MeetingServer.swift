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
import Contacts

/* ###################################################################################################################################### */
// MARK: - BMLT-Specialized SDK struct -
/* ###################################################################################################################################### */
/**
 This is a subclass of the main SDK class, that is "tuned" for [the BMLT](https://bmlt.app)
 */
open class LGV_MeetingSDK_LGV_MeetingServer: LGV_MeetingSDK {
    /* ###################################################################################################################################### */
    // MARK: - The Parsed Meeting Search Information Class -
    /* ###################################################################################################################################### */
    /**
     This defines a class, containing a "found set" of meeting data.
     It is defined as a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
     */
    public class Data_Set: LGV_MeetingSDK_Meeting_Data_Set_Protocol {
        /* ################################################################################################################################## */
        // MARK: LGV_MeetingSDK_Additional_Info_Protocol Conformance
        /* ################################################################################################################################## */
        /* ############################################################## */
        /**
         This allows us to have extra information attached to the found set.
         */
        public var extraInfo: String = ""

        /* ################################################################################################################################## */
        // MARK: LGV_MeetingSDK_RefCon_Protocol Conformance
        /* ################################################################################################################################## */
        /* ############################################################## */
        /**
         This allows us to have a reference context attached to the found set.
         */
        public var refCon: Any?

        /* ################################################################################################################################## */
        // MARK: Instance Properties
        /* ################################################################################################################################## */
        /* ############################################################## */
        /**
         This is the search specification main search type.
         */
        public let searchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints

        /* ############################################################## */
        /**
         This is the search specification additional filters.
         */
        public let searchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>
        
        /* ############################################################## */
        /**
         This contains any found meetings. It may be empty (no meetings found).
         */
        private var _meetings: [Meeting]
        
        /* ############################################################## */
        /**
         This contains any found meetings. It may be empty (no meetings found).
         */
        public var meetings: [LGV_MeetingSDK_Meeting_Protocol] {
            get { _meetings }
            set { _meetings = (newValue as? [Meeting]) ?? [] }
        }

        /* ############################################################## */
        /**
         Default initializer.
         
         - Parameters:
             - searchType (OPTIONAL): This is the search specification main search type. Default is .none.
             - searchRefinements (OPTIONAL): This is the search specification additional filters. Default is an empty set.
             - meetings (OPTIONAL): This contains any found meetings. It may be empty or omitted (no meetings found).
             - formats (OPTIONAL): This Dictionary contains any found formats.
             - extraInfo (OPTIONAL): This has any extra information that we wish to attach to the data set. Default is an empty String.
             - refCon (OPTIONAL): This has any reference context that we wish to attach to the data set. Default is nil.
         */
        public init(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                    searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                    meetings inMeetings: [LGV_MeetingSDK_Meeting_Protocol] = [],
                    extraInfo inExtraInfo: String = "",
                    refCon inRefCon: Any? = nil) {
            searchType = inSearchType
            searchRefinements = inSearchRefinements
            _meetings = (inMeetings as? [Meeting]) ?? []
            extraInfo = inExtraInfo
            refCon = inRefCon
        }
    }

    /* ################################################################################################################################## */
    // MARK: - Format Struct -
    /* ################################################################################################################################## */
    /**
     This describes one "meeting format," which is some extra information attached to a meeting, describing attributes.
     */
    public struct Format: LGV_MeetingSDK_Format_Protocol {
        /* ################################################################## */
        /**
         This is a a unique ID (in the organization/server), for the format.
         */
        public var id: UInt64
        
        /* ################################################################## */
        /**
         This is a simple text "key" for the format. It should be unique in the found set.
         */
        public var key: String
        
        /* ################################################################## */
        /**
         This is a short name for the format.
         */
        public var name: String
        
        /* ################################################################## */
        /**
         This is a longer description for the format.
         */
        public var description: String
    }

    /* ################################################################################################################################## */
    // MARK: - Meeting Struct -
    /* ################################################################################################################################## */
    /**
     This describes one BMLT meeting.
     */
    public struct Meeting: LGV_MeetingSDK_Meeting_Protocol {
        /* ############################################################################################################################## */
        // MARK: Physical Location Struct
        /* ############################################################################################################################## */
        /**
         This describes a physical location for the meeting.
         */
        public struct PhysicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol {
            /* ############################################################## */
            /**
             The coordinates of the meeting.
             */
            public var coords: CLLocationCoordinate2D
            
            /* ############################################################## */
            /**
             A name for the location.
             */
            public var name: String

            /* ############################################################## */
            /**
             The address of the meeting.
             */
            public var postalAddress: CNPostalAddress
            
            /* ############################################################## */
            /**
             The local time zone of the meeting.
             */
            public var timeZone: TimeZone
            
            /* ############################################################## */
            /**
             Any additional information.
             */
            public var extraInfo: String
        }
        
        /* ############################################################################################################################## */
        // MARK: Virtual Location Struct
        /* ############################################################################################################################## */
        /**
         This defines a set of virtual access points for the meeting (there may be multiple ones).
         */
        public struct VirtualLocation: LGV_MeetingSDK_Meeting_Virtual_Protocol {
            /* ############################################################################################################################## */
            // MARK: Virtual Venue Struct
            /* ############################################################################################################################## */
            /**
             This is a concrete implementation of the venue struct.
             */
            public struct VirtualVenue: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol {
                /* ################################################################## */
                /**
                 This describes the meeting venue (i.e. "Video," "Zoom," "Audio-Only," "Phone," etc.).
                 */
                public let description: String

                /* ################################################################## */
                /**
                 The local timezone for the meeting.
                 */
                public let timeZone: TimeZone?

                /* ################################################################## */
                /**
                 If the meeting has a URI, that is available here.
                 */
                public let url: URL?
                
                /* ################################################################## */
                /**
                 If the meeting has a separate meeting ID, that is available here, as a String.
                 */
                public let meetingID: String?
                
                /* ################################################################## */
                /**
                 If the meeting has a separate meeting password, that is available here, as a String.
                 */
                public let password: String?
                
                /* ############################################################## */
                /**
                 Any additional information.
                 */
                public let extraInfo: String
                
                /* ############################################################## */
                /**
                 Default initializer.
                 
                 - Parameters:
                     - description (OPTIONAL): This describes the meeting venue (i.e. "Video," "Zoom," "Audio-Only," "Phone," etc.).
                     - timeZone (OPTIONAL): The local timezone for the meeting.
                     - url (OPTIONAL): If the meeting has a URI, that is available here.
                     - meetingID (OPTIONAL): If the meeting has a separate meeting ID, that is available here, as a String.
                     - password (OPTIONAL): If the meeting has a separate meeting password, that is available here, as a String.
                     - extraInfo (OPTIONAL): Any additional information (as a String).
                 */
                init(description inDescription: String = "",
                     timeZone inTimeZone: TimeZone? = nil,
                     url inURL: URL? = nil,
                     meetingID inMeetingID: String? = nil,
                     password inPassword: String? = nil,
                     extraInfo inExtraInfo: String = "") {
                    description = inDescription
                    timeZone = inTimeZone
                    url = inURL
                    meetingID = inMeetingID
                    password = inPassword
                    extraInfo = inExtraInfo
                }
            }
            
            /* ################################################################## */
            /**
             Local storage for the video venue.
             */
            private let _videoMeeting: VirtualVenue?
            
            /* ################################################################## */
            /**
             Local storage for the phone venue.
             */
            private let _phoneMeeting: VirtualVenue?

            /* ############################################################## */
            /**
             Any additional information.
             */
            public let extraInfo: String
            
            /* ################################################################## */
            /**
             If there is a video meeting associated, it is defined here. May be nil. This also applies to audio-only (not phone) meetings.
             */
            public var videoMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { _videoMeeting }
            
            /* ################################################################## */
            /**
             If there is a phone meeting associated, it is defined here. May be nil.
             */
            public var phoneMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { _phoneMeeting }
            
            /* ############################################################## */
            /**
             Default initializer.
             
             - Parameters:
                 - videoMeeting (OPTIONAL): If specified, the video meeting venue.
                 - phoneMeeting (OPTIONAL): If specified, the phone meeting venue.
                 - extraInfo (OPTIONAL): Any additional information (as a String).
             */
            public init(videoMeeting inVideoMeeting: VirtualVenue? = nil, phoneMeeting inPhoneMeeting: VirtualVenue? = nil, extraInfo inExtraInfo: String = "") {
                _videoMeeting = inVideoMeeting
                _phoneMeeting = inPhoneMeeting
                extraInfo = inExtraInfo
            }
        }

        /* ################################################################## */
        /**
         The meeting's physical location (if any).
         */
        private var _physicalLocation: PhysicalLocation?

        /* ################################################################## */
        /**
         The meeting's virtual information (if any).
         */
        private var _virtualLocation: VirtualLocation?

        /* ################################################################## */
        /**
         The organization to which this meeting belongs.
         */
        public var organization: LGV_MeetingSDK_Organization_Protocol?
        
        /* ################################################################## */
        /**
         A unique ID for this meeting (within the organization).
         */
        public var id: UInt64
        
        /* ################################################################## */
        /**
         The name of the meeting.
         */
        public let name: String
        
        /* ################################################################## */
        /**
         Any comments and/or additional information.
         */
        public let extraInfo: String

        /* ################################################################## */
        /**
         The duration of the meeting, in seconds.
         */
        public let meetingDuration: TimeInterval
        
        /* ################################################################## */
        /**
         The distance of this meeting, from the search center, or a specified "distance from" refinement.
         */
        public var distanceInMeters: CLLocationDistance

        /* ################################################################## */
        /**
         The 1-based weekday instance.
         
         > Note: This is always 1 -> Sunday, 7 -> Saturday, regardless of when the week starts in the device locale.
         */
        public let weekdayIndex: Int
        
        /* ################################################################## */
        /**
         The start time of the meeting, in miltary time (HHMM).
         
         > Note: 0000 is midnight (this morning), and 2400 is midnight (tonight).
         */
        public let meetingStartTime: Int
        
        /* ################################################################## */
        /**
         Any formats that apply to this meeting.
         */
        public let formats: [LGV_MeetingSDK_Format_Protocol]
        
        /* ################################################################## */
        /**
         Accessor for the physical location.
         */
        public var physicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol? {
            get { _physicalLocation }
            set { _physicalLocation = newValue as? PhysicalLocation }
        }

        /* ################################################################## */
        /**
         Accessor for the virtual information.
         */
        public var virtualMeetingInfo: LGV_MeetingSDK_Meeting_Virtual_Protocol? {
            get { _virtualLocation }
            set { _virtualLocation = newValue as? VirtualLocation }
        }
        
        /* ################################################################## */
        /**
         Default initializer.
         
         - Parameters:
            - id: A unique ID for this meeting (within the organization).
            - weekdayIndex: The 1-based weekday instance (1 is always Sunday).
            - meetingStartTime: The start time of the meeting, in miltary time (HHMM).
            - name (OPTIONAL): The name of the meeting.
            - extraInfo (OPTIONAL): Any comments and/or additional information.
            - meetingDuration (OPTIONAL): The duration of the meeting, in seconds.
            - distanceInMeters (OPTIONAL): The distance of this meeting, from the search center, or a specified "distance from" refinement. This is in meters.
            - formats (OPTIONAL): Any formats that apply to this meeting.
            - physicalLocation (OPTIONAL): The meeting's physical location (if any).
            - virtualMeetingInfo (OPTIONAL): The meeting's virtual information (if any).
         */
        public init(organization inOrganization: LGV_MeetingSDK_Organization_Protocol? = nil,
                    id inID: UInt64,
                    weekdayIndex inWeekdayIndex: Int,
                    meetingStartTime inMeetingStartTime: Int,
                    name inName: String = "",
                    extraInfo inExtraInfo: String = "",
                    meetingDuration inMeetingDuration: TimeInterval = 0,
                    distanceInMeters inDistance: CLLocationDistance = 0,
                    formats inFormats: [LGV_MeetingSDK_Format_Protocol] = [],
                    physicalLocation inPhysicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol? = nil,
                    virtualMeetingInfo inVirtualMeetingInfo: LGV_MeetingSDK_Meeting_Virtual_Protocol? = nil) {
            organization = inOrganization
            id = inID
            name = inName
            weekdayIndex = inWeekdayIndex
            meetingStartTime = inMeetingStartTime
            extraInfo = inExtraInfo
            meetingDuration = inMeetingDuration
            distanceInMeters = inDistance
            formats = inFormats
            _physicalLocation = inPhysicalLocation as? PhysicalLocation
            virtualMeetingInfo = inVirtualMeetingInfo
        }
    }

    /* ################################################################################################################################## */
    // MARK: BMLT-Specific Transport Struct
    /* ################################################################################################################################## */
    /**
     This transport is dedicated to the BMLT.
     We make this a class, so we can be weakly referenced.
     */
    public class Transport: LGV_MeetingSDK_Transport_Protocol {
        /* ############################################################################################################################## */
        // MARK: Parser
        /* ############################################################################################################################## */
        /**
         This is the parser. Most functionality will be in the extension.
         */
        public class Parser {
            /* ################################################################## */
            /**
             The initiator, for creating search commands.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _initiator: Initiator?
            
            /* ################################################################## */
            /**
             The initiator, for creating search commands.
             */
            public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol? {
                get { _initiator }
                set { _initiator = newValue as? Initiator }
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: Initiator
        /* ############################################################################################################################## */
        /**
         This is an initiator. It forms queries to the BMLT Root Server. Most functionality will be in the extension.
         We make it a class, so it will be referencable.
         */
        public class Initiator {
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _transport: Transport?
            
            /* ########################################################## */
            /**
             */
            private var _parser: LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser?
            
            /* ########################################################## */
            /**
             The parser goes here.
             */
            public var parser: LGV_MeetingSDK_Parser_Protocol {
                get { _parser! } // I hate implicit optionals, but I want this to crash, if it is deallocated.
                set { _parser = newValue as? LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser }
            }
            
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
             Default init. we simply create a parser, and let it know about us.
             */
            public init() {
                parser = Parser()
                (parser as? Parser)?.initiator = self
            }
        }
        
        /* ################################################################################################################################## */
        // MARK: LGV_MeetingSDK_Transport_Protocol Conformance
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         This will contain the URL to the Root Server that is being accessed by this transport instance.
         */
        public var baseURL: URL?

        /* ################################################################################################################################## */
        // MARK: Instance Properties
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         The initiator goes here.
         */
        public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol?
        
        /* ################################################################## */
        /**
         The transport organization to which this instance is assigned.
         */
        public var organization: LGV_MeetingSDK_Organization_Transport_Protocol?
        
        /* ########################################################## */
        /**
         This contains the last search result set.
         */
        public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
        
        /* ################################################################################################################################## */
        // MARK: Mocking Properties
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         This is a special dummy URL that we use to allow mocking.
         */
        public static let testingRootServerURL = URL(string: "https://bmlt.app.example.com/littlegreenviper")
        
        /* ########################################################## */
        /**
         This is used to "short-circuit" the actual network call.
         
         If this is non-nil, then the Data instance is sent to the callback closure as a "one-shot" call. The property is immediately cleared, after being read.
         The URL is ignored.
         */
        public var debugMockDataResponse: Data?
        
        /* ################################################################################################################################## */
        // MARK: Initializer
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         Default initializer.
         
         - parameter rootServerURL: The URL to the BMLT Root Server that will be accessed by this instance.
         */
        public init(rootServerURL inRootServerURL: URL) {
            baseURL = inRootServerURL
            initiator = Initiator()
            initiator?.transport = self
        }
    }
    
    /* ###################################################################################################################################### */
    // MARK: Type Properties
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     The organization key to use for the test organization.
     */
    public static let organizationKey: String = "BMLT"
    
    /* ################################################################## */
    /**
     The name to use for the test organization.
     */
    public static let organizationName: String = "BMLT-Enabled"
    
    /* ################################################################## */
    /**
     The description to use for the test organization.
     */
    public static let organizationDescription = "BMLT-Enabled is an independent, non-profit management entity for the Basic Meeting List Toolbox Initiative."
    
    /* ################################################################## */
    /**
     The URL to use for the test organization.
     */
    public static let organizationURL = URL(string: "https://bmlt.app")
    
    /* ###################################################################################################################################### */
    // MARK: Instance Methods
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     Simple accessor to the Root Server URL String.
     */
    public var rootServerURLString: String {
        get { organization?.transport?.baseURL?.absoluteString ?? "" }
        set { organization?.transport?.baseURL = URL(string: newValue) }
    }
    
    /* ###################################################################################################################################### */
    // MARK: Initializer
    /* ###################################################################################################################################### */
    /* ############################################################## */
    /**
     Default initializer.
     
     - Parameters:
        - rootServerURL (REQUIRED): The URL to the BMLT Root Server that will be accessed by this instance.
        - organizationKey (OPTIONAL): The organization key. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationKey`
        - organizationName (OPTIONAL): The name of the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationName`.
        - organizationName (OPTIONAL): A longer description for the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationDescription`.
        - organizationURL (OPTIONAL): A URL for the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationURL`.
        - refCon (OPTIONAL): An optional (default is nil) reference context, to attach to the SDK instance.
     */
    public init(rootServerURL inRootServerURL: URL,
                organizationKey inOrganizationKey: String = LGV_MeetingSDK_LGV_MeetingServer.organizationKey,
                organizationName inOrganizationName: String = LGV_MeetingSDK_LGV_MeetingServer.organizationName,
                organizationDescription inOrganizationDescription: String = LGV_MeetingSDK_LGV_MeetingServer.organizationDescription,
                organizationURL inorganizationURL: URL? = LGV_MeetingSDK_LGV_MeetingServer.organizationURL,
                refCon: Any? = nil) {
        let organization = LGV_MeetingSDK_Generic_Organization(transport: LGV_MeetingSDK_LGV_MeetingServer.Transport(rootServerURL: inRootServerURL),
                                                               organizationKey: inOrganizationKey,
                                                               organizationName: inOrganizationName,
                                                               organizationDescription: inOrganizationDescription,
                                                               organizationURL: inorganizationURL
        )
        super.init(organization: organization)
    }
}
