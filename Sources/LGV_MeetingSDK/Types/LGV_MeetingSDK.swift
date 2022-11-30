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
// MARK: - CLLocationCoordinate2D Extension -
/* ###################################################################################################################################### */
internal extension CLLocationCoordinate2D {
    /* ################################################################## */
    /**
     - returns: True, if the location is valid. This allows some "slop" around the Prime Meridian/Equator point.
     */
    var isValid: Bool { !isEqualTo(CLLocationCoordinate2D(latitude: 0, longitude: 0), precisionInMeters: 500000) && CLLocationCoordinate2DIsValid(self) }

    /* ################################################################## */
    /**
     Compares two locations for "equality."
     
     - Parameters:
        - inComp: A location (long and lat), to which we are comparing ourselves.
        - precisionInMeters: This is an optional precision (slop area), in meters. If left out, then the match must be exact.
     
     - returns: True, if the locations are equal, according to the given precision.
     */
    func isEqualTo(_ inComp: CLLocationCoordinate2D, precisionInMeters inPrecisionInMeters: CLLocationDistance = 0.0) -> Bool {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: inComp.latitude, longitude: inComp.longitude)) <= inPrecisionInMeters
    }
}

/* ###################################################################################################################################### */
// MARK: - Hashable Conformance for CLLocationCoordinate2D -
/* ###################################################################################################################################### */
extension CLLocationCoordinate2D: Hashable {
    /* ############################################################## */
    /**
     This hashes the two double values.
     
     - parameter into: The mutable property that receives the hash.
     */
    public func hash(into inHasher: inout Hasher) {
        inHasher.combine(latitude)
        inHasher.combine(longitude)
    }
}

/* ###################################################################################################################################### */
// MARK: - Equatable Conformance for CLLocationCoordinate2D -
/* ###################################################################################################################################### */
extension CLLocationCoordinate2D: Equatable {
    /* ############################################################## */
    /**
     They need to both be equal.
     
     - parameter lhs: The left-hand side of the comparison.
     - parameter rhs: The right-hand side of the comparison.
     
     - returns: True, if they are equal.
     */
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool { lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude }
}

/* ###################################################################################################################################### */
// MARK: - The Parsed Meeting Search Information Class -
/* ###################################################################################################################################### */
/**
 This defines a class, containing a "found set" of meeting data.
 It is defined as a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
 */
open class LGV_MeetingSDK_Meeting_Data_Set: LGV_MeetingSDK_Meeting_Data_Set_Protocol {
    /* ################################################################################################################################## */
    // MARK: Top Level Error Enum
    /* ################################################################################################################################## */
    /**
     This enum is based on the Swift [`Error`](https://developer.apple.com/documentation/swift/error) protocol, and "wraps" more specific errors. It provides the general error categories.
     */
    public enum Error: Swift.Error, CaseIterable, CustomDebugStringConvertible {
        /* ############################################################################################################################## */
        // MARK: Communications Error Enum
        /* ############################################################################################################################## */
        /**
         This enum is based on the Swift [`Error`](https://developer.apple.com/documentation/swift/error) protocol. It provides errors specific to communication with the source server.
         */
        public enum CommunicationError: Swift.Error, CaseIterable, CustomDebugStringConvertible {
            /* ########################################################## */
            /**
             The server successfully completed, but there was a redirection (which we consider a failure).
             - parameter error: The Swift error, sent back (if any).
             */
            case redirectionError(error: Swift.Error?)
            
            /* ########################################################## */
            /**
             There was a problem with what we sent to the server.
             - parameter error: The Swift error, sent back (if any).
            */
            case clientError(error: Swift.Error?)
            
            /* ########################################################## */
            /**
             The server had a cow.
             - parameter error: The Swift error, sent back (if any).
             */
            case serverError(error: Swift.Error?)
            
            /* ########################################################## */
            /**
             Thisis called in case no HTTP response came in. It will likely never happen.
             
             - parameter error: The Swift error, sent back (if any).
             */
            case missingResponseError(error: Swift.Error?)

            /* ########################################################## */
            /**
             None of the above.
             - parameter error: The Swift error, sent back (if any).
             */
            case generalError(error: Swift.Error?)

            /* ########################################################## */
            /**
             CaseIterable Conformance
             Returns empty variants of each case.
             */
            public static var allCases: [CommunicationError] { [serverError(error: nil),
                                                                redirectionError(error: nil),
                                                                clientError(error: nil),
                                                                missingResponseError(error: nil),
                                                                generalError(error: nil)
            ] }
            
            /* ########################################################## */
            /**
             CustomDebugStringConvertible Conformance
             Returns a detailed, hierarchical debug description string.
             */
            public var debugDescription: String {
                switch self {
                case let .serverError(error):
                    return "serverError\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"
                    
                case let .redirectionError(error):
                    return "parameterError\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"

                case let .clientError(error):
                    return "clientError\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"

                case let .missingResponseError(error):
                    return "missingResponseError\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"

                case let .generalError(error):
                    return "generalError\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"
                }
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: Parser Error Enum
        /* ############################################################################################################################## */
        /**
         This enum is based on the Swift [`Error`](https://developer.apple.com/documentation/swift/error) protocol. It provides errors specific to parsing the returned data.
         */
        public enum ParserError: Swift.Error, CaseIterable, CustomDebugStringConvertible {
            /* ########################################################## */
            /**
             The JSON parser threw an error.
             - parameter error: The error that the parser threw.
             */
            case jsonParseFailure(error: Swift.Error?)
            
            /* ########################################################## */
            /**
             CaseIterable Conformance
             Returns empty variants of each case.
             */
            public static var allCases: [ParserError] { [jsonParseFailure(error: nil)
            ] }
            
            /* ########################################################## */
            /**
             CustomDebugStringConvertible Conformance
             Returns a detailed, hierarchical debug description string.
             */
            public var debugDescription: String {
                switch self {
                case let .jsonParseFailure(error):
                    return "jsonParseFailure\(nil != error ? "(" + (error?.localizedDescription ?? "") + ")" : "")"
                }
            }
        }
        
        /* ############################################################## */
        /**
         Error in communicating with the source server.
         */
        case communicationError(error: CommunicationError?)
        
        /* ############################################################## */
        /**
         Error parsing the returned meeting data.
         */
        case parsingError(error: ParserError?)
        
        /* ############################################################## */
        /**
         All other errors.
         */
        case generalError(error: Swift.Error?)
        
        /* ############################################################## */
        /**
         CaseIterable Conformance
         Returns empty variants of each case.
         */
        public static var allCases: [Error] {
            [communicationError(error: nil),
             parsingError(error: nil),
             generalError(error: nil)
            ]
        }
        
        /* ############################################################## */
        /**
         CustomDebugStringConvertible Conformance
         Returns a detailed, hierarchical debug description string.
         */
        public var debugDescription: String {
            switch self {
            case let .communicationError(error):
                return "communicationError\(nil != error ? "(" + (error?.debugDescription ?? "") + ")" : "")"
                
            case let .parsingError(error):
                return "parsingError\(nil != error ? "(" + (error?.debugDescription ?? "") + ")" : "")"

            case let .generalError(error):
                return "generalError(\(String(describing: error))"
            }
        }
    }
    
    /* ################################################################################################################################## */
    // MARK: Search Initiator Additional Refinements Weekdays Enum
    /* ################################################################################################################################## */
    /**
     This integer-based enum is a 1-based weekday specifier for the `LGV_MeetingSDK_SearchInitiator_Search_Refinements.weekdays` specialization.
     */
    public enum Weekdays: Int, CaseIterable, CustomDebugStringConvertible {
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
        
        /* ############################################################## */
        /**
         CustomDebugStringConvertible Conformance
         */
        public var debugDescription: String {
            switch self {
            case .sunday:
                return "Sunday"
                
            case .monday:
                return "Monday"
                
            case .tuesday:
                return "Tuesday"
                
            case .wednesday:
                return "Wednesday"
                
            case .thursday:
                return "Thursday"
                
            case .friday:
                return "Friday"
                
            case .saturday:
                return "Saturday"
            }
        }
    }

    /* ################################################################################################################################## */
    // MARK: Search Initiator Search Types Enum
    /* ################################################################################################################################## */
    /**
     These are enums that describe the "main" search parameters.
     */
    public enum SearchConstraints: CustomDebugStringConvertible, Codable {
        /* ############################################################## */
        /**
         No search constraints.
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
         This is very similar to the autoRadius search (in fact, it is used, internally), but it looks for meetings happening soon after the current time.
         */
        case nextMeetings(centerLongLat: CLLocationCoordinate2D, minimumNumberOfResults: UInt, maxRadiusInMeters: CLLocationDistance)

        /* ############################################################## */
        /**
         CustomDebugStringConvertible Conformance
         */
        public var debugDescription: String {
            switch self {
            case .none:
                return "none"
                
            case let .fixedRadius(centerLongLat, radiusInMeters):
                return ".fixedRadius(centerLongLat: (latitude: \(centerLongLat.latitude), longitude: \(centerLongLat.longitude)), radiusInMeters: \(radiusInMeters))"
                
            case let .autoRadius(centerLongLat, minimumNumberOfResults, maxRadiusInMeters):
                return ".autoRadius(centerLongLat: (latitude: \(centerLongLat.latitude), longitude: \(centerLongLat.longitude)), minimumNumberOfResults: \(minimumNumberOfResults), maxRadiusInMeters: \(maxRadiusInMeters))"

            case let .meetingID(ids):
                return ".meetingID(ids: \(ids.debugDescription))"
                
            case let .nextMeetings(centerLongLat, minimumNumberOfResults, maxRadiusInMeters):
                return ".nextMeetings(centerLongLat: (latitude: \(centerLongLat.latitude), longitude: \(centerLongLat.longitude)), minimumNumberOfResults: \(minimumNumberOfResults), maxRadiusInMeters: \(maxRadiusInMeters))"
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: Codable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Returns the parameter storage index for the type.
         
         - parameter for: The case we are checking.
         */
        private static func _typeIndex(for inCase: Self) -> Int {
            switch inCase {
            case .none:
                return 0
                
            case .fixedRadius:
                return 1
                
            case .autoRadius:
                return 2

            case .meetingID:
                return 3
                
            case .nextMeetings:
                return 4
            }
        }

        /* ############################################################################################################################## */
        // MARK: Coding Keys Enum
        /* ############################################################################################################################## */
        /**
         This enum defines the keys for the Codable protocol
         */
        enum CodingKeys: String, CodingKey {
            /* ############################################################## */
            /**
             The type of search
             */
            case type

            /* ############################################################## */
            /**
             The latitude of the center of a radius search.
             */
            case centerLongLat_Lat

            /* ############################################################## */
            /**
             The longitude of the center of a radius search.
             */
            case centerLongLat_Lng

            /* ############################################################## */
            /**
             The radius, in meters, of a constrained radius search.
             */
            case radiusInMeters

            /* ############################################################## */
            /**
             The minimum number of results, for an auto-radius search.
             */
            case minimumNumberOfResults

            /* ############################################################## */
            /**
             The ids, for an ID search.
             */
            case ids
        }

        /* ############################################################################################################################## */
        // MARK: Encodable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Stores the state into an Encoder.
         
         - parameter to: The Encoder instance that will hold the data.
         */
        public func encode(to inEncoder: Encoder) throws {
            var container = inEncoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .none:
                try container.encode(Self._typeIndex(for: self), forKey: .type)

            case let .fixedRadius(centerLongLat, radiusInMeters):
                try container.encode(Self._typeIndex(for: self), forKey: .type)
                try container.encode(centerLongLat.latitude, forKey: .centerLongLat_Lat)
                try container.encode(centerLongLat.longitude, forKey: .centerLongLat_Lng)
                try container.encode(radiusInMeters, forKey: .radiusInMeters)

            case let .autoRadius(centerLongLat, minimumNumberOfResults, maxRadiusInMeters):
                try container.encode(Self._typeIndex(for: self), forKey: .type)
                try container.encode(centerLongLat.latitude, forKey: .centerLongLat_Lat)
                try container.encode(centerLongLat.longitude, forKey: .centerLongLat_Lng)
                try container.encode(minimumNumberOfResults, forKey: .minimumNumberOfResults)
                try container.encode(maxRadiusInMeters, forKey: .radiusInMeters)

            case let .meetingID(ids):
                try container.encode(Self._typeIndex(for: self), forKey: .type)
                try container.encode(ids, forKey: .ids)

            case let .nextMeetings(centerLongLat, minimumNumberOfResults, maxRadiusInMeters):
                try container.encode(Self._typeIndex(for: self), forKey: .type)
                try container.encode(centerLongLat.latitude, forKey: .centerLongLat_Lat)
                try container.encode(centerLongLat.longitude, forKey: .centerLongLat_Lng)
                try container.encode(minimumNumberOfResults, forKey: .minimumNumberOfResults)
                try container.encode(maxRadiusInMeters, forKey: .radiusInMeters)
            }
        }

        /* ############################################################################################################################## */
        // MARK: Decodable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Initializes from a decoder.
         
         - parameter from: The Decoder instance that has our state.
         */
        public init(from inDecoder: Decoder) throws {
            let values = try inDecoder.container(keyedBy: CodingKeys.self)
            let type = try values.decode(Int.self, forKey: .type)
            switch type {
            case Self._typeIndex(for: .fixedRadius(centerLongLat: CLLocationCoordinate2D(), radiusInMeters: 0)):
                let latitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lat)
                let longitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lng)
                let radius = try values.decode(Double.self, forKey: .radiusInMeters)
                self = .fixedRadius(centerLongLat: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radiusInMeters: radius)

            case Self._typeIndex(for: .autoRadius(centerLongLat: CLLocationCoordinate2D(), minimumNumberOfResults: 0, maxRadiusInMeters: 0)):
                let latitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lat)
                let longitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lng)
                let minCount = try values.decode(UInt.self, forKey: .minimumNumberOfResults)
                let radius = try values.decode(Double.self, forKey: .radiusInMeters)
                self = .autoRadius(centerLongLat: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), minimumNumberOfResults: minCount, maxRadiusInMeters: radius)
                
            case Self._typeIndex(for: .meetingID(ids: [])):
                let ids = try values.decode([UInt64].self, forKey: .ids)
                self = .meetingID(ids: ids)

            case Self._typeIndex(for: .nextMeetings(centerLongLat: CLLocationCoordinate2D(), minimumNumberOfResults: 0, maxRadiusInMeters: 0)):
                let latitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lat)
                let longitude = try values.decode(CLLocationDegrees.self, forKey: .centerLongLat_Lng)
                let minCount = try values.decode(UInt.self, forKey: .minimumNumberOfResults)
                let radius = try values.decode(Double.self, forKey: .radiusInMeters)
                self = .nextMeetings(centerLongLat: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), minimumNumberOfResults: minCount, maxRadiusInMeters: radius)

            default:
                self = .none
            }
        }
    }

    /* ################################################################################################################################## */
    // MARK: Search Initiator Additional Refinements Enum
    /* ################################################################################################################################## */
    /**
     The main search can have "refinements" applied, that filter the response further.
     */
    public enum Search_Refinements: CustomDebugStringConvertible, Hashable, Codable {
        /* ############################################################## */
        /**
         This means don't apply any refinements to the main search.
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
        
        /* ############################################################## */
        /**
         This allows a string to be submitted for a search.
         */
        case string(searchString: String)
        
        /* ############################################################## */
        /**
         We can specify a location that can be used as a "fulcrum," from which to measure distance to the results.
         
         > Note: The parameter cannot be (0, 0), as that is considered an "invalid" location.
         */
        case distanceFrom(thisLocation: CLLocationCoordinate2D)
        
        /* ############################################################## */
        /**
         CustomDebugStringConvertible Conformance
         */
        public var debugDescription: String {
            switch self {
            case .none:
                return "none"
                
            case let .venueTypes(venueTypes):
                return ".venueTypes(\(venueTypes.debugDescription))"

            case let .weekdays(weekdays):
                return ".weekdays(\(weekdays.debugDescription))"

            case let .startTimeRange(startTimeRange):
                return ".startTimeRange(\(startTimeRange.debugDescription))"

            case let .string(string):
                return ".string(\(string))"

            case let .distanceFrom(thisLocation):
                return ".distanceFrom(latitude: \(thisLocation.latitude), longitude: \(thisLocation.longitude))"
            }
        }

        /* ############################################################## */
        /**
         Used to make sure that we can only have one of each, regardless of associated values.
         */
        public var hashKey: String {
            switch self {
            case .none:
                return "none"
                
            case .venueTypes:
                return "venueTypes"

            case .weekdays:
                return "weekdays"

            case .startTimeRange:
                return "startTimeRange"

            case .string:
                return "string"

            case .distanceFrom:
                return "distanceFrom"
            }
        }
    
        /* ############################################################## */
        /**
         Equatable Conformance
         */
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.hashKey == rhs.hashKey
        }

        /* ############################################################## */
        /**
         Hashable Conformance
         */
        public func hash(into hasher: inout Hasher) {
            hasher.combine(hashKey)
        }
        
        /* ############################################################################################################################## */
        // MARK: Codable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Returns the parameter storage index for the type.
         
         - parameter for: The case we are checking.
         */
        private static func _typeIndex(for inCase: Self) -> Int {
            switch inCase {
            case .none:
                return 0
                
            case .venueTypes:
                return 1
                
            case .weekdays:
                return 2
            
            case .startTimeRange:
                return 3
            
            case .string:
                return 4

            case .distanceFrom:
                return 5
            }
        }

        /* ############################################################################################################################## */
        // MARK: Coding Keys Enum
        /* ############################################################################################################################## */
        /**
         This enum defines the keys for the Codable protocol
         */
        enum CodingKeys: String, CodingKey {
            /* ############################################################## */
            /**
             The type of enum
             */
            case type

            /* ############################################################## */
            /**
             A list of venue types.
             */
            case venueTypes

            /* ############################################################## */
            /**
             A list of weekdays
             */
            case weekdays

            /* ############################################################## */
            /**
             The lower bound of the start time range.
             */
            case startTimeRange_LowerBound

            /* ############################################################## */
            /**
             The upper bound of the start time range.
             */
            case startTimeRange_UpperBound

            /* ############################################################## */
            /**
             The search string.
             */
            case string

            /* ############################################################## */
            /**
             The latitude of the coordinate we want to find the distance from
             */
            case distanceFrom_Lat

            /* ############################################################## */
            /**
             The longitude of the coordinate we want to find the distance from
             */
            case distanceFrom_Lng
        }
        
        /* ############################################################################################################################## */
        // MARK: Encodable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Stores the state into an Encoder.
         
         - parameter to: The Encoder instance that will hold the data.
         */
        public func encode(to inEncoder: Encoder) throws {
            var container = inEncoder.container(keyedBy: CodingKeys.self)
            try container.encode(Self._typeIndex(for: self), forKey: .type)
            switch self {
            case .none:
                break

            case let .venueTypes(venueTypes):
                try container.encode(venueTypes.compactMap { $0.rawValue }, forKey: .venueTypes)

            case let .weekdays(weekdays):
                try container.encode(weekdays.compactMap { $0.rawValue }, forKey: .weekdays)

            case let .startTimeRange(startTimeRange):
                try container.encode(startTimeRange.lowerBound, forKey: .startTimeRange_LowerBound)
                try container.encode(startTimeRange.upperBound, forKey: .startTimeRange_UpperBound)

            case let .string(searchString):
                try container.encode(searchString, forKey: .string)

            case let .distanceFrom(thisLocation):
                try container.encode(thisLocation.latitude, forKey: .distanceFrom_Lat)
                try container.encode(thisLocation.longitude, forKey: .distanceFrom_Lng)
            }
        }

        /* ############################################################################################################################## */
        // MARK: Decodable Conformance
        /* ############################################################################################################################## */
        /* ############################################################## */
        /**
         Initializes from a decoder.
         
         - parameter from: The Decoder instance that has our state.
         */
        public init(from inDecoder: Decoder) throws {
            let values = try inDecoder.container(keyedBy: CodingKeys.self)
            let type = try values.decode(Int.self, forKey: .type)
            switch type {
            case Self._typeIndex(for: .venueTypes([])):
                let venues = try values.decode([String].self, forKey: .venueTypes)
                self = .venueTypes(Set<LGV_MeetingSDK_VenueType_Enum>(venues.compactMap { LGV_MeetingSDK_VenueType_Enum(rawValue: $0) }))

            case Self._typeIndex(for: .weekdays([])):
                let weekdays = try values.decode([Int].self, forKey: .weekdays)
                self = .weekdays(Set<Weekdays>(weekdays.compactMap { Weekdays(rawValue: $0) }))
                
            case Self._typeIndex(for: .startTimeRange((0...0))):
                let rangeLower = try values.decode(TimeInterval.self, forKey: .startTimeRange_LowerBound)
                let rangeUpper = try values.decode(TimeInterval.self, forKey: .startTimeRange_UpperBound)
                self = .startTimeRange(rangeLower...rangeUpper)

            case Self._typeIndex(for: .string(searchString: "")):
                let searchString = try values.decode(String.self, forKey: .string)
                self = .string(searchString: searchString)

            case Self._typeIndex(for: .distanceFrom(thisLocation: CLLocationCoordinate2D())):
                let latitude = try values.decode(CLLocationDegrees.self, forKey: .distanceFrom_Lat)
                let longitude = try values.decode(CLLocationDegrees.self, forKey: .distanceFrom_Lng)
                self = .distanceFrom(thisLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                
            default:
                self = .none
            }
        }
    }
    
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
    public var meetings: [LGV_MeetingSDK.Meeting]
    
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
                meetings inMeetings: [LGV_MeetingSDK.Meeting] = [],
                extraInfo inExtraInfo: String = "",
                refCon inRefCon: Any? = nil) {
        searchType = inSearchType
        searchRefinements = inSearchRefinements
        meetings = inMeetings
        extraInfo = inExtraInfo
        refCon = inRefCon
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
    // MARK: - Meeting Struct -
    /* ################################################################################################################################## */
    /**
     This describes one meeting.
     */
    public struct Meeting: LGV_MeetingSDK_Meeting_Protocol {
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
            public var postalAddress: CNPostalAddress?
            
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
    private var _lastSearch: LGV_MeetingSDK_Meeting_Data_Set_Protocol?
    
    /* ################################################################################################################################## */
    // MARK: Main Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the default initializer for the search SDK.
     
     - parameter organization: The organization (containing the transport) to be applied.
     */
    public init(organization inOrganization: LGV_MeetingSDK_Organization_Transport_Protocol) {
        _organization = inOrganization
        _organization?.sdkInstance = self
    }
}

/* ###################################################################################################################################### */
// MARK: Static Utility Functions
/* ###################################################################################################################################### */
extension LGV_MeetingSDK {
    /* ################################################################## */
    /**
     "Cleans" a URI.
     
     - parameter urlString: The URL, as a String. It can be optional.
     
     - returns: an optional String. This is the given URI, "cleaned up" ("https://" or "tel:" may be prefixed)
     */
    static func cleanURI(urlString inURLString: String?) -> String? {
        /* ################################################################## */
        /**
         This tests a string to see if a given substring is present at the start.
         
         - Parameters:
         - inString: The string to test.
         - inSubstring: The substring to test for.
         
         - returns: true, if the string begins with the given substring.
         */
        func string (_ inString: String, beginsWith inSubstring: String) -> Bool {
            var ret: Bool = false
            if let range = inString.range(of: inSubstring) {
                ret = (range.lowerBound == inString.startIndex)
            }
            return ret
        }
        
        guard var ret: String = inURLString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
              let regex = try? NSRegularExpression(pattern: "^(http://|https://|tel://|tel:)", options: .caseInsensitive)
        else { return nil }
        
        // We specifically look for tel URIs.
        let wasTel = string(ret.lowercased(), beginsWith: "tel:")
        
        // Yeah, this is pathetic, but it's quick, simple, and works a charm.
        ret = regex.stringByReplacingMatches(in: ret, options: [], range: NSRange(location: 0, length: ret.count), withTemplate: "")
        
        if ret.isEmpty {
            return nil
        }
        
        if wasTel {
            ret = "tel:" + ret
        } else {
            ret = "https://" + ret
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This simply strips out all non-decimal characters in the string, leaving only valid decimal digits.
     
     - parameter inString: The string to be "decimated."
     
     - returns: A String, with all the non-decimal characters stripped.
     */
    static func decimalOnly(_ inString: String) -> String {
        let decimalDigits = CharacterSet(charactersIn: "0123456789")
        return inString.filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return decimalDigits.contains(cha)
        }
    }
    
    /* ################################################################## */
    /**
     This allows us to find if a string contains another string.
     
     - Parameters:
         - inString: The string we're looking for.
         - withinThisString: The string we're looking through.
         - options (OPTIONAL): The String options for the search. Default is case insensitive, and diacritical insensitive.
     
     - returns: True, if the string contains the other String.
     */
    private static func _isThisString(_ inString: String, withinThisString inMainString: String, options inOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]) -> Bool { nil != inMainString.range(of: inString, options: inOptions)?.lowerBound }

    /* ########################################################## */
    /**
     Checks a meeting, to see if a given string is present.
     
     - parameter meeting: The meeing instance to check (haystack).
     - parameter string: The string we're looking for (needle).
     
     - returns: True, if the meeting contains the string we're looking for.
     */
    private static func _isStringInHere(meeting inMeeting: LGV_MeetingSDK.Meeting, string inString: String) -> Bool {
        var ret = false
        
        if LGV_MeetingSDK._isThisString(inString, withinThisString: inMeeting.name)
            || LGV_MeetingSDK._isThisString(inString, withinThisString: inMeeting.extraInfo) {
            ret = true
        } else if let physicalLocationName = inMeeting.physicalLocation?.name,
                  LGV_MeetingSDK._isThisString(inString, withinThisString: physicalLocationName) {
            ret = true
        } else if let virtualInfo = inMeeting.virtualMeetingInfo?.videoMeeting?.extraInfo,
                  LGV_MeetingSDK._isThisString(inString, withinThisString: virtualInfo) {
            ret = true
        } else if let virtualInfo = inMeeting.virtualMeetingInfo?.videoMeeting?.description,
                  LGV_MeetingSDK._isThisString(inString, withinThisString: virtualInfo) {
            ret = true
        } else if let virtualInfo = inMeeting.virtualMeetingInfo?.phoneMeeting?.extraInfo,
                  LGV_MeetingSDK._isThisString(inString, withinThisString: virtualInfo) {
            ret = true
        } else if let virtualInfo = inMeeting.virtualMeetingInfo?.phoneMeeting?.description,
                  LGV_MeetingSDK._isThisString(inString, withinThisString: virtualInfo) {
            ret = true
        } else if !inMeeting.formats.isEmpty {
            for meetingFormat in inMeeting.formats where LGV_MeetingSDK._isThisString(inString, withinThisString: meetingFormat.name) || LGV_MeetingSDK._isThisString(inString, withinThisString: meetingFormat.description) {
                ret = true
                break
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - Parameters:
         - inMeetings: The meeting array to be filtered.
         - searchType: This is the search specification main search type.
         - searchRefinements: This is the search specification additional filters.
     
     - returns: The refined meeting array.
     */
    static func refineMeetings(_ inMeetings: [LGV_MeetingSDK.Meeting],
                               searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                               searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>) -> [LGV_MeetingSDK.Meeting] {
        var maximumDistanceInMeters: CLLocationDistance = -1
        
        // See if we have a distance-constrained search.
        switch inSearchType {
        case let .fixedRadius(centerLongLat: _, radiusInMeters: max):
            maximumDistanceInMeters = max
            
        case let .autoRadius(centerLongLat: _, minimumNumberOfResults: _, maxRadiusInMeters: max):
            maximumDistanceInMeters = max
            
        default:
            break
        }
        
        // We go through each meeting in the results.
        return inMeetings.compactMap { meeting in
            // First filter is for distance.
            if 0 >= maximumDistanceInMeters || meeting.distanceInMeters <= maximumDistanceInMeters {
                // We then see if we specified any refinements. If so, we need to meet them.
                if !inSearchRefinements.isEmpty {
                    var returned: LGV_MeetingSDK.Meeting?
                    for refinement in inSearchRefinements.enumerated() {
                        switch refinement.element {
                        // String searches look at a number of fields in each meeting.
                        case let .string(searchForThisString):
                            guard Self._isStringInHere(meeting: meeting, string: searchForThisString) else { return nil }
                          
                            returned = meeting
                            
                        // If we specified weekdays, then we need to meet on one of the provided days.
                        case let .weekdays(weekdays):
                            guard weekdays.map({ $0.rawValue }).contains(meeting.weekdayIndex) else { return nil }
                           
                            returned = meeting
                            
                        // If we specified a start time range, then we need to start within that range.
                        case let .startTimeRange(startTimeRange):
                            guard let startTimeInSeconds = meeting.startTimeInSeconds,
                                  startTimeRange.contains(startTimeInSeconds)
                            else { return nil }
                            
                            returned = meeting
                            
                        // Are we looking for only virtual, in-person, or hybrid (or combinations, thereof)?
                        case let .venueTypes(venues):
                            guard venues.contains(meeting.meetingType) else { return nil }
                     
                            returned = meeting
                            
                        default:
                            returned = meeting
                        }
                        
                        return returned
                    }
                    // If the meeting did not meet any of the refinements, then we don't include it.
                    return nil
                } else {    // If we are not refining, then we just include the meeting.
                    return meeting
                }
            } else {    // If we were looking at restricting the distance, then this means the meeting exceeds our maximum distance.
                return nil
            }
        }
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
    public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set_Protocol? {
        get { _lastSearch }
        set { _lastSearch = newValue }
    }
    
    /* ################################################################## */
    /**
     Default runs, using the built-in organization->transport->initiator method.
     */
    public func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                              refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                              refCon inRefCon: Any? = nil,
                              completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        organization?.transport?.sdkInstance?.lastSearch = nil
        guard let urlRequest = organization?.transport?.ceateURLRequest(type: inSearchType, refinements: inSearchRefinements) else { return }
        #if DEBUG
            print("URL Request: \(urlRequest.debugDescription)")
        #endif
        // See if we have mock data.
        if let dataToParse = (organization?.transport as? LGV_MeetingSDK_LGV_MeetingServer.Transport)?.debugMockDataResponse {
            organization?.transport?.debugMockDataResponse = nil
            organization?.transport?.parser?.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: dataToParse, refCon: inRefCon) { inParsedMeetings, inError in
                if var parsedData = inParsedMeetings {
                    parsedData.extraInfo = urlRequest.url?.absoluteString ?? ""
                    inCompletion(parsedData, inError)
                } else {
                    inCompletion(nil, nil)
                }
            }
        } else {    // Otherwise, we need to execute an NSURLSession data task.
            organization?.transport?.initiator?.meetingSearch(type: inSearchType, refinements: inSearchRefinements, refCon: inRefCon, completion: inCompletion)
        }
    }

    /* ################################################################## */
    /**
     WHAT'S ALL THIS, THEN?
     
     This method will be a bit complex, because, what we are doing, is successive auto radius calls, until a minimum number of aggregated results are found.
     
     Sounds like a standard auto radius call, eh? But there's a difference. This is a "Next Available Meetings" call. The result will be a series of meetings, sorted by weekday and time, then by distance, after now.
     
     The caller can specify refinements, like "Only look at meetings on weekdays, between 6PM and 9PM."
     
     The search will continue until the minimum number of search results has been found, or until all seven days have been exhausted. The caller can also specify a maximum radius.

     - default minimumNumberOfResults is 10
     - default maxRadiusInMeters is 10,000 Km
     - default refinements is nil
     - default refCon is nil
     */
    public func findNextMeetingsSearch(centerLongLat inCenterLongLat: CLLocationCoordinate2D,
                                       minimumNumberOfResults inMinimumNumberOfResults: UInt = 10,
                                       maxRadiusInMeters inMaxRadiusInMeters: CLLocationDistance = 10000000,
                                       refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>? = nil,
                                       refCon inRefCon: Any? = nil,
                                       completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        let maxRadius = (0.0..<40075000.0).contains(inMaxRadiusInMeters) ? inMaxRadiusInMeters : 0
        
        let lockTite = DispatchQueue(label: "threadlock", qos: .background) // We use this to make sure we don't get thread collisions.
        var currentWeekdayIndex = 0
        var aggregatedMeetings: [Meeting] = []
        var searchUnderWay = false

        /* ############################################################## */
        /**
         This is our own internal completion callback. We use this to aggregate the search results.
         
         > NOTE: I don't want to recurse, because I don't want long stack chains. We're calling a remote service, and it could be dicey. Instead, I will use a rather primitive loop.
         
         - parameter inData: The data returned from the search.
         - parameter inError: Any errors encountered (may be nil).
         */
        func searchCallback(_ inData: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _ inError: Error?) {
            #if DEBUG
                print("SDK Internal Callback, with data: \(String(describing: inData)), error: \(String(describing: inError))")
            #endif
            defer { lockTite.sync { searchUnderWay = false } }
            lockTite.sync {
                lastSearch = nil
                currentWeekdayIndex += 1
            }
            
            guard let meetings = inData?.meetings,
                  !meetings.isEmpty
            else {
                return
            }

            // This helps to prevent occasional thread collision crashes.
            lockTite.sync {
                #if DEBUG
                    print("SDK Internal Callback, found meetings: \(meetings.debugDescription)")
                #endif

                meetings.forEach { meeting in
                    if !aggregatedMeetings.contains(where: { $0.id == meeting.id }) {
                        aggregatedMeetings.append(meeting)
                    }
                }

                #if DEBUG
                    print("SDK Internal Callback, final aggregate meetings: \(aggregatedMeetings.debugDescription)")
                #endif
            }
        }
        
        // This sets us up for the current time and weekday.
        let todayWeekday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let secondsSinceMidnightThisMorning = TimeInterval(Int(Date().timeIntervalSince(Calendar.current.startOfDay(for: Date()))))
        
        let searchRefinements = inSearchRefinements ?? []
        
        // Save the requested refinements for weekday and start time range. These can be empty arrays
        let weekdayRefinement = Array(searchRefinements.filter { $0.hashKey == "weekdays" })
        let startTimeRangeRefinement = Array(searchRefinements.filter { $0.hashKey == "startTimeRange" })
        // Now, remove them from our basic refinements.
        let baselineRefinements = searchRefinements.filter { $0.hashKey != "weekdays" && $0.hashKey != "startTimeRange" }
        
        // We build a "pool" of weekdays to search, starting from today's weekday, and extending for a week.
        // We will be searching only these weekdays. We won't worry about when the week starts in the calendar, but we will be going from today, on. It's an array, because order is important.
        var weekdayPool = [LGV_MeetingSDK_Meeting_Data_Set.Weekdays]()
        
        for index in todayWeekday...(todayWeekday + 6) {
            // If we have a weekday refinement, we only add weekdays that are in it.
            if let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: 0 < index ? (8 > index ? index : index - 7) : index + 7) {
                if !weekdayRefinement.isEmpty {
                    if case let .weekdays(weekdayArray) = weekdayRefinement[0],
                       weekdayArray.contains(weekday) {
                        weekdayPool.append(weekday)
                    }
                } else {    // Otherwise, we add all seven weekdays.
                    weekdayPool.append(weekday)
                }
            }
        }
        
        var eachDayTimeRange = TimeInterval(0)...TimeInterval(86399)
        var firstDayTimeRange = eachDayTimeRange
        
        if let startTimeRange = startTimeRangeRefinement.first {
            if case let .startTimeRange(startTimeRangeVal) = startTimeRange {
                eachDayTimeRange = startTimeRangeVal
            }
        }

        if !weekdayPool.isEmpty {
            if todayWeekday == weekdayPool[0].rawValue {    // If we are starting today, we may need to clamp the range.
                firstDayTimeRange = (max(eachDayTimeRange.lowerBound, secondsSinceMidnightThisMorning)...eachDayTimeRange.upperBound)
            } else {
                firstDayTimeRange = eachDayTimeRange
            }
            
            var currentTimeRange = firstDayTimeRange
            
            var breakMe = false // We use a semaphore, to avoid thread collisions.
            
            while !breakMe {
                var dontDoASearch = true
                lockTite.sync {
                    breakMe = aggregatedMeetings.count >= inMinimumNumberOfResults || currentWeekdayIndex >= weekdayPool.count
                    dontDoASearch = searchUnderWay || breakMe
                }
                if !dontDoASearch {
                    lockTite.sync { searchUnderWay = true }
                    let searchType = LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints.autoRadius(centerLongLat: inCenterLongLat, minimumNumberOfResults: inMinimumNumberOfResults, maxRadiusInMeters: maxRadius)
                    // Each sweep adds the next weekday in our list.
                    var refinements = baselineRefinements
                    let weekdays = weekdayPool[currentWeekdayIndex]
                    refinements.insert(LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements.weekdays([weekdays]))
                    if 0 < currentTimeRange.lowerBound || 86399 > currentTimeRange.upperBound {    // We don't specify a time range, at all, if we never specified a constrained one.
                        refinements.insert(LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements.startTimeRange(currentTimeRange))
                    }
                    
                    currentTimeRange = eachDayTimeRange
                    
                    lastSearch = nil
                    meetingSearch(type: searchType, refinements: refinements, refCon: inRefCon, completion: searchCallback)
                }
            }
            
            aggregatedMeetings = aggregatedMeetings.sorted { a, b in
                guard a.weekdayIndex == b.weekdayIndex, // If the weekdays aren't the same, then no further sorting.
                      let aStartTime = a.startTimeInSeconds,
                      let bStartTime = b.startTimeInSeconds
                else { return false }

                guard aStartTime == bStartTime else { return aStartTime < bStartTime }
                
                return a.distanceInMeters < b.distanceInMeters
            }
            
            // We make sure to trim to the requested amount, or less.
            aggregatedMeetings = [Meeting](aggregatedMeetings[0..<min(aggregatedMeetings.count, Int(inMinimumNumberOfResults))])
        }
        
        let resultantDataSet = LGV_MeetingSDK_Meeting_Data_Set(searchType: .nextMeetings(centerLongLat: inCenterLongLat, minimumNumberOfResults: inMinimumNumberOfResults, maxRadiusInMeters: maxRadius), searchRefinements: inSearchRefinements ?? [], meetings: aggregatedMeetings)
        
        lastSearch = resultantDataSet
        
        inCompletion(resultantDataSet, nil)
    }
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
    public var organizationDescription: String? {
        get { _organizationDescription }
        set { _organizationDescription = newValue }
    }

    /* ################################################################## */
    /**
     This is the accessor for the URL private property.
     */
    public var organizationURL: URL? {
        get { _organizationURL }
        set { _organizationURL = newValue }
    }
    
    /* ################################################################## */
    /**
     The default initializer.
     
     - Parameters:
        - transport (REQUIRED): This is a required argument. It will be the transport instance to be used with this organization.
        - organizationKey (REQUIRED): This is a required argument. The organization key.
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
