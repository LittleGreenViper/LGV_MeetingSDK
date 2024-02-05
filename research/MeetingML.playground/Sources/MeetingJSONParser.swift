import CoreLocation // For physical venues.
import Contacts     // For the postal address
import CreateML     // For taggedData

/* ###################################################################################################################################### */
// MARK: - Special Array Extension for Creating Tagged Data -
/* ###################################################################################################################################### */
public extension Array where Element == MeetingJSONParser.Meeting {
    /* ################################################# */
    /**
     This reduces the entire array into a tagged value array.
     */
    var taggedData: [String: any MLDataValueConvertible] {
        reduce([:]) { current, next in
            var interimData = current
            
            next.taggedData.forEach { key, value in
                interimData[key] = (interimData[key] ?? []) + [value]
            }
            return interimData
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting JSON Page Parser -
/* ###################################################################################################################################### */
/**
 This struct will accept raw JSON data from one page of results from the `LGV_MeetingServer`, and parse it into struct data.
 */
public struct MeetingJSONParser: Codable {
    /* ################################################################################################################################## */
    // MARK: Page Metadata Container
    /* ################################################################################################################################## */
    /**
     This struct holds metada about the page of meeting results.
     */
    public struct PageMeta: Codable {
        /* ############################################# */
        /**
         This is the actual size of this single page of results, in results (not bytes).
         */
        public let actualSize: Int

        /* ############################################# */
        /**
         This is the number of results allowed as a maximum, per page, in results.
         */
        public let pageSize: Int

        /* ############################################# */
        /**
         This is the 0-based starting index, of the total found set (in results), for this page.
         */
        public let startingIndex: Int

        /* ############################################# */
        /**
         This is the total size of all results in the found set.
         */
        public let total: Int

        /* ############################################# */
        /**
         This is the total number of pages that contain the found set.
         */
        public let totalPages: Int

        /* ############################################# */
        /**
         This is the 0-based index of this page of results.
         */
        public let page: Int

        /* ############################################# */
        /**
         This is the number of seconds, reported by the server, to generate this page of results.
         */
        public let searchTime: TimeInterval
    }

    /* ################################################################################################################################## */
    // MARK: Meeting Data Container
    /* ################################################################################################################################## */
    /**
     This struct holds a parsed meeting instance.
     */
    public struct Meeting: Codable {
        /* ############################################################################################################################## */
        // MARK: Format Information Container
        /* ############################################################################################################################## */
        /**
         This struct holds a parsed format information instance.
         */
        public struct Format: Codable, MLDataValueConvertible {
            public init?(from inDataValue: MLDataValue) { nil }
            
            public init() {
                key = ""
                name = ""
                description = ""
                language = ""
            }
            
            public static var dataValueType: MLDataValue.ValueType { MLDataValue.ValueType.dictionary }
            
            public var dataValue: MLDataValue {
                MLDataValue.DictionaryType([
                    MLDataValue.string("key"): MLDataValue.string(key),
                    MLDataValue.string("name"): MLDataValue.string(name),
                    MLDataValue.string("description"): MLDataValue.string(description),
                    MLDataValue.string("language"): MLDataValue.string(language)
                ]).dataValue
            }
            
            /* ########################################################################################################################## */
            // MARK: Codable Coding Keys
            /* ########################################################################################################################## */
            /**
             This defines the keys that we use for encoding and decoding.
             */
            private enum _CodingKeys: String, CodingKey {
                /* ######################################### */
                /**
                 This is the short format "key" string.
                 */
                case key
                
                /* ######################################### */
                /**
                 This is the short name for the format.
                 */
                case name

                /* ######################################### */
                /**
                 This is the longer description of the format.
                 */
                case description

                /* ######################################### */
                /**
                 This is the [ISO 639-2](https://www.loc.gov/standards/iso639-2/php/code_list.php) code for the language used for the name and description.
                 */
                case language
            }

            /* ############################################# */
            /**
             This is the short format "key" string.
             */
            public let key: String

            /* ############################################# */
            /**
             This is the short name for the format.
             */
            public let name: String

            /* ############################################# */
            /**
             This is the longer description of the format.
             */
            public let description: String
            
            /* ############################################# */
            /**
             This is the [ISO 639-2](https://www.loc.gov/standards/iso639-2/php/code_list.php) code for the language used for the name and description.
             */
            public let language: String

            /* ############################################# */
            /**
             A failable initializer. This initializer parses "raw" format data, and populates the instance properties.
             
             - parameter inDictionary: A simple String-keyed dictionary of partly-parsed values.
             */
            public init?(_ inDictionary: [String: Any]) {
                self.key = MeetingJSONParser._decodeUnicode(inDictionary["key"] as? String)
                self.name = MeetingJSONParser._decodeUnicode(inDictionary["name"] as? String)
                self.description = MeetingJSONParser._decodeUnicode(inDictionary["description"] as? String)
                self.language = MeetingJSONParser._decodeUnicode(inDictionary["language"] as? String)
            }
            
            // MARK: Codable Conformance
            
            /* ############################################# */
            /**
             Decodable initializer
             
             - parameter from: The decoder to use as a source of values.
             */
            public init(from inDecoder: Decoder) throws {
                let container: KeyedDecodingContainer<_CodingKeys> = try inDecoder.container(keyedBy: _CodingKeys.self)
                self.key = try container.decode(String.self, forKey: .key)
                self.name = try container.decode(String.self, forKey: .name)
                self.description = try container.decode(String.self, forKey: .description)
                self.language = try container.decode(String.self, forKey: .language)
            }
            
            /* ############################################# */
            /**
             Encoder
             
             - parameter to: The encoder to load with our values.
             */
            public func encode(to inEncoder: Encoder) throws {
                var container = inEncoder.container(keyedBy: _CodingKeys.self)
                try container.encode(key, forKey: .key)
                try container.encode(name, forKey: .name)
                try container.encode(description, forKey: .description)
                try container.encode(language, forKey: .language)
            }
        }

        /* ############################################################################################################################## */
        // MARK: Codable Coding Keys
        /* ############################################################################################################################## */
        /**
         This defines the keys that we use for encoding and decoding.
         */
        private enum _CodingKeys: String, CodingKey {
            /* ############################################# */
            /**
             This is a unique ID (within the found set) for this meeting.
             */
            case id
            
            /* ############################################# */
            /**
             This is the unique ID (within the found set) for the data source server.
             */
            case serverID
            
            /* ############################################# */
            /**
             This is a unique ID (within the data source server) for this meeting.
             */
            case localMeetingID
            
            /* ############################################# */
            /**
             This is a 1-based weekday index.
             */
            case weekday
            
            /* ############################################# */
            /**
             This is the time of day that the meeting starts.
             */
            case startTime
            
            /* ############################################# */
            /**
             This is the duration, in seconds, of the meeting.
             */
            case duration
            
            /* ############################################# */
            /**
             This is the local timezone of this meeting.
             */
            case timezone
            
            /* ############################################# */
            /**
             This is the organization to which this meeting belongs.
             */
            case organization
            
            /* ############################################# */
            /**
             The latitude of the meeting.
             */
            case coords_lat
            
            /* ############################################# */
            /**
             The longitude of the meeting.
             */
            case coords_lng

            /* ############################################# */
            /**
             This is the name of the meeting.
             */
            case name
            
            /* ############################################# */
            /**
             This is any additional comments for the meeting.
             */
            case comments
            
            /* ############################################# */
            /**
             This the street address for the in-person meeting.
             */
            case inPersonAddress_street
            
            /* ############################################# */
            /**
             This the neighborhood for the in-person meeting.
             */
            case inPersonAddress_subLocality
            
            /* ############################################# */
            /**
             This the municipality for the in-person meeting.
             */
            case inPersonAddress_city
            
            /* ############################################# */
            /**
             This the province/state for the in-person meeting.
             */
            case inPersonAddress_state
            
            /* ############################################# */
            /**
             This the county for the in-person meeting.
             */
            case inPersonAddress_subAdministrativeArea
            
            /* ############################################# */
            /**
             This the postal code for the in-person meeting.
             */
            case inPersonAddress_postalCode
            
            /* ############################################# */
            /**
             This the nation for the in-person meeting.
             */
            case inPersonAddress_country
            
            /* ############################################# */
            /**
             This is any additional text, describing the location.
             */
            case locationInfo
            
            /* ############################################# */
            /**
             This is a URL for a virtual meeting.
             */
            case virtualURL
            
            /* ############################################# */
            /**
             This is a phonr number for a virtual meeting.
             */
            case virtualPhoneNumber
            
            /* ############################################# */
            /**
             This is any additional text, describing the virtual meeting.
             */
            case virtualInfo
            
            /* ############################################# */
            /**
             This contains an array of formats that apply to the meeting.
             */
            case formats
        }

        /* ############################################################################################################################## */
        // MARK: Organization Type Enum
        /* ############################################################################################################################## */
        /**
         This specifies the organization for the meeting.
         */
        public enum Organization: String, Codable {
            /* ############################################# */
            /**
             No organization specified
             */
            case none

            /* ############################################# */
            /**
             Narcotics Anonymous
             */
            case na
        }
        
        // MARK: Required Instance Properties
        
        /* ################################################# */
        /**
         This is a unique ID (within the found set) for this meeting, based on the two local IDs.
         */
        public let id: UInt64
        
        /* ################################################# */
        /**
         This is the unique ID (within the found set) for the data source server.
         */
        public let serverID: Int
        
        /* ################################################# */
        /**
         This is a unique ID (within the data source server) for this meeting.
         */
        public let localMeetingID: Int
        
        /* ################################################# */
        /**
         This is a 1-based weekday index, with 1 being Sunday, and 7 being Saturday.
         */
        public let weekday: Int
        
        /* ################################################# */
        /**
         This is the time of day that the meeting starts (date-independent).
         */
        public let startTime: Date
        
        /* ################################################# */
        /**
         This is the duration, in seconds, of the meeting.
         */
        public let duration: TimeInterval
        
        /* ################################################# */
        /**
         This is the local timezone of this meeting.
         */
        public let timezone: TimeZone
        
        /* ################################################# */
        /**
         This is the name of the meeting.
         */
        public let name: String

        /* ################################################# */
        /**
         This is the organization to which this meeting belongs.
         */
        public let organization: Organization
        
        /* ################################################# */
        /**
         This contains an array of formats that apply to the meeting.
         */
        public let formats: [Format]

        // MARK: Optional Instance Properties
        
        /* ################################################# */
        /**
         This is the physical location of this meeting, or a location used to determine local timezone. It is optional.
         */
        public let coords: CLLocationCoordinate2D?
        
        /* ################################################# */
        /**
         This is any additional comments for the meeting. It is optional.
         */
        public let comments: String?
        
        /* ################################################# */
        /**
         This is a physical address of an in-person meeting. It is optional.
         */
        public let inPersonAddress: CNPostalAddress?
        
        /* ################################################# */
        /**
         This is any additional text, describing the location. It is optional.
         */
        public let locationInfo: String?
        
        /* ################################################# */
        /**
         This is a URL for a virtual meeting. It is optional.
         */
        public let virtualURL: URL?
        
        /* ################################################# */
        /**
         This is a phonr number for a virtual meeting. It is optional.
         */
        public let virtualPhoneNumber: String?
        
        /* ################################################# */
        /**
         This is any additional text, describing the virtual meeting. It is optional.
         */
        public let virtualInfo: String?
        
        // MARK: Public Computed Properties
                
        /* ################################################# */
        /**
         This provides the object as "tagged" data, for things like ML processing.
         */
        public var taggedData: [String: MLDataValue] {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let startTime = formatter.string(from: self.startTime)
            let coords = nil != coords ? "\(coords!.latitude),\(coords!.longitude)" : ""
            return [
                "serverID": MLDataValue.int(serverID),
                "localMeetingID": MLDataValue.int(localMeetingID),
                "weekday": MLDataValue.int(weekday),
                "startTime": MLDataValue.string(startTime),
                "duration": MLDataValue.double(duration),
                "timezone": MLDataValue.string(timezone.identifier),
                "organization": MLDataValue.string(organization.rawValue),
                "name": MLDataValue.string(name),
                "comments": MLDataValue.string(comments ?? ""),
                "locationInfo": MLDataValue.string(locationInfo ?? ""),
                "virtualURL": MLDataValue.string(virtualURL?.absoluteString ?? ""),
                "virtualPhoneNumber": MLDataValue.string(virtualPhoneNumber ?? ""),
                "virtualInfo": MLDataValue.string(virtualInfo ?? ""),
                "coords": MLDataValue.string(coords),
                "inPersonAddress": MLDataValue.string(inPersonAddress?.description ?? ""),
                "formats": MLDataValue.sequence(formats)
            ]
        }
        
        // MARK: Initializer
                
        /* ################################################# */
        /**
         This is a failable initializer, it parses an input dictionary.
         
         - parameter inDictionary: The semi-parsed JSON record for the meeting.
         */
        public init?(_ inDictionary: [String: Any]) {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "HH:mm:ss"

            guard let serverID = inDictionary["server_id"] as? Int,
                  let startTimeStr = inDictionary["start_time"] as? String,
                  let startTime = dateFormatter.date(from: startTimeStr),
                  let localMeetingID = inDictionary["meeting_id"] as? Int,
                  let weekday = inDictionary["weekday"] as? Int,
                  (1..<8).contains(weekday),
                  let organizationStr = inDictionary["organization_key"] as? String
            else { return nil }

            self.weekday = weekday
            self.startTime = startTime
            self.serverID = serverID
            self.localMeetingID = localMeetingID
            self.organization = Organization(rawValue: organizationStr) ?? .none

            if let timezoneStr = inDictionary["time_zone"] as? String ?? TimeZone.current.localizedName(for: .standard, locale: .current) {
                self.timezone = TimeZone(identifier: timezoneStr) ?? .current
            } else {
                self.timezone = .current
            }

            if let duration = inDictionary["duration"] as? Int,
               (0..<86400).contains(duration) {
                self.duration = TimeInterval(duration)
            } else {
                self.duration = TimeInterval(3600)
            }

            self.formats = (inDictionary["formats"] as? [[String: Any]] ?? []).compactMap { Format($0) }

            self.id = (UInt64(serverID) << 44) + UInt64(localMeetingID)

            self.name = MeetingJSONParser._decodeUnicode(inDictionary["name"] as? String)

            if let long = inDictionary["longitude"] as? Double,
               let lat = inDictionary["latitude"] as? Double,
               CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: long)) {
                self.coords = CLLocationCoordinate2D(latitude: lat, longitude: long)
            } else {
                self.coords = nil
            }

            if let comments = inDictionary["comments"] as? String,
               !comments.isEmpty {
                self.comments = MeetingJSONParser._decodeUnicode(comments)
            } else {
                self.comments = nil
            }

            if let physicalAddress = inDictionary["physical_address"] as? [String: String] {
                let mutableGoPostal = CNMutablePostalAddress()
                mutableGoPostal.street = MeetingJSONParser._decodeUnicode(physicalAddress["street"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.subLocality = MeetingJSONParser._decodeUnicode(physicalAddress["neighborhood"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.city = MeetingJSONParser._decodeUnicode(physicalAddress["city"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.state = MeetingJSONParser._decodeUnicode(physicalAddress["province"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.subAdministrativeArea = MeetingJSONParser._decodeUnicode(physicalAddress["county"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.postalCode = MeetingJSONParser._decodeUnicode(physicalAddress["postal_code"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableGoPostal.country = MeetingJSONParser._decodeUnicode(physicalAddress["nation"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                self.inPersonAddress = mutableGoPostal
                let locationInfo = MeetingJSONParser._decodeUnicode(physicalAddress["info"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                self.locationInfo = locationInfo.isEmpty ? nil : locationInfo
            } else {
                self.inPersonAddress = nil
                self.locationInfo = nil
            }

            if let virtualMeetingInfo = inDictionary["virtual_information"] as? [String: String] {
                let urlStr = MeetingJSONParser._decodeUnicode(virtualMeetingInfo["url"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                if !urlStr.isEmpty,
                   let virtualURL = URL(string: urlStr) {
                    self.virtualURL = virtualURL
                } else {
                    self.virtualURL = nil
                }
                
                let virtualPhoneNumber = MeetingJSONParser._decodeUnicode(virtualMeetingInfo["phone_number"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                if !virtualPhoneNumber.isEmpty {
                    self.virtualPhoneNumber = virtualPhoneNumber
                } else {
                    self.virtualPhoneNumber = nil
                }
                
                let virtualInfo = MeetingJSONParser._decodeUnicode(virtualMeetingInfo["info"]?.trimmingCharacters(in: .whitespacesAndNewlines))
                self.virtualInfo = virtualInfo.isEmpty ? nil : virtualInfo
            } else {
                self.virtualURL = nil
                self.virtualPhoneNumber = nil
                self.virtualInfo = nil
            }
        }
        
        // MARK: Codable Conformance
        
        /* ############################################# */
        /**
         Decodable initializer
         
         - parameter from: The decoder to use as a source of values.
         */
        public init(from inDecoder: Decoder) throws {
            let container: KeyedDecodingContainer<_CodingKeys> = try inDecoder.container(keyedBy: _CodingKeys.self)
            id = try container.decode(UInt64.self, forKey: .id)
            serverID = try container.decode(Int.self, forKey: .serverID)
            localMeetingID = try container.decode(Int.self, forKey: .localMeetingID)
            weekday = try container.decode(Int.self, forKey: .weekday)
            startTime = try container.decode(Date.self, forKey: .startTime)
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            timezone = try container.decode(TimeZone.self, forKey: .timezone)
            organization = try container.decode(Organization.self, forKey: .organization)
            name = try container.decode(String.self, forKey: .name)
            formats = try container.decode([Format].self, forKey: .formats)
            
            comments = try? container.decode(String.self, forKey: .comments)
            locationInfo = try? container.decode(String.self, forKey: .locationInfo)
            virtualURL = try? container.decode(URL.self, forKey: .virtualURL)
            virtualPhoneNumber = try? container.decode(String.self, forKey: .virtualPhoneNumber)
            virtualInfo = try? container.decode(String.self, forKey: .virtualInfo)
            
            if let latitude = try? container.decode(CLLocationDegrees.self, forKey: .coords_lat),
               let longitude = try? container.decode(CLLocationDegrees.self, forKey: .coords_lng) {
                let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if CLLocationCoordinate2DIsValid(coords) {
                    self.coords = coords
                } else {
                    self.coords = nil
                }
            } else {
                coords = nil
            }
            
            if let street = try? container.decode(String.self, forKey: .inPersonAddress_street),
               let subLocality = try? container.decode(String.self, forKey: .inPersonAddress_subLocality),
               let city = try? container.decode(String.self, forKey: .inPersonAddress_city),
               let state = try? container.decode(String.self, forKey: .inPersonAddress_state),
               let subAdministrativeArea = try? container.decode(String.self, forKey: .inPersonAddress_subAdministrativeArea),
               let postalCode = try? container.decode(String.self, forKey: .inPersonAddress_postalCode),
               let country = try? container.decode(String.self, forKey: .inPersonAddress_country) {
                let mutableGoPostal = CNMutablePostalAddress()
                mutableGoPostal.street = street
                mutableGoPostal.subLocality = subLocality
                mutableGoPostal.city = city
                mutableGoPostal.state = state
                mutableGoPostal.subAdministrativeArea = subAdministrativeArea
                mutableGoPostal.postalCode = postalCode
                mutableGoPostal.country = country
                inPersonAddress = mutableGoPostal
            } else {
                inPersonAddress = nil
            }
        }
        
        /* ############################################# */
        /**
         Encoder
         
         - parameter to: The encoder to load with our values.
         */
        public func encode(to inEncoder: Encoder) throws {
            var container = inEncoder.container(keyedBy: _CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(serverID, forKey: .serverID)
            try container.encode(localMeetingID, forKey: .localMeetingID)
            try container.encode(weekday, forKey: .weekday)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(duration, forKey: .duration)
            try container.encode(timezone, forKey: .timezone)
            try container.encode(organization, forKey: .organization)
            try container.encode(name, forKey: .name)
            try container.encode(formats, forKey: .formats)

            try? container.encode(comments, forKey: .comments)
            try? container.encode(locationInfo, forKey: .locationInfo)
            try? container.encode(virtualURL, forKey: .virtualURL)
            try? container.encode(virtualPhoneNumber, forKey: .virtualPhoneNumber)
            try? container.encode(virtualInfo, forKey: .virtualInfo)

            try? container.encode(coords?.latitude, forKey: .coords_lat)
            try? container.encode(coords?.longitude, forKey: .coords_lng)
            
            try? container.encode(inPersonAddress?.street, forKey: .inPersonAddress_street)
            try? container.encode(inPersonAddress?.subLocality, forKey: .inPersonAddress_subLocality)
            try? container.encode(inPersonAddress?.city, forKey: .inPersonAddress_city)
            try? container.encode(inPersonAddress?.state, forKey: .inPersonAddress_state)
            try? container.encode(inPersonAddress?.subAdministrativeArea, forKey: .inPersonAddress_subAdministrativeArea)
            try? container.encode(inPersonAddress?.postalCode, forKey: .inPersonAddress_postalCode)
            try? container.encode(inPersonAddress?.country, forKey: .inPersonAddress_country)
        }
    }

    // META: Private Static Functions
    
    /* ################################################# */
    /**
     This decodes Unicode characters in the string.
     */
    private static func _decodeUnicode(_ inString: String?) -> String { inString?.applyingTransform(StringTransform("Hex-Any"), reverse: false) ?? "" }
    
    /* ################################################# */
    /**
     This parses the page metadata from the raw dictionary.
     
     - parameter inDictionary: The partly-parsed raw JSON
     */
    private static func _parseMeta(_ inDictionary: [String: Any]) -> PageMeta? {
        guard let actualSize = inDictionary["actual_size"] as? Int,
              let pageSize = inDictionary["page_size"] as? Int,
              let startingIndex = inDictionary["starting_index"] as? Int,
              let total = inDictionary["total"] as? Int,
              let totalPages = inDictionary["total_pages"] as? Int,
              let page = inDictionary["page"] as? Int,
              let searchTime = inDictionary["search_time"] as? TimeInterval
        else { return nil }
        
        return PageMeta(actualSize: actualSize,
                        pageSize: pageSize,
                        startingIndex: startingIndex,
                        total: total,
                        totalPages: totalPages,
                        page: page,
                        searchTime: searchTime
        )
    }

    /* ################################################# */
    /**
     This parses the meetings from the raw dictionary.
     
     - parameter inDictionary: The partly-parsed raw JSON
     */
    private static func _parseMeeting(_ inDictionary: [String: Any]) -> Meeting? { Meeting(inDictionary) }
    
    /* ################################################# */
    /**
     The page metadata for this page of meetings.
     */
    public let meta: PageMeta
    
    /* ################################################# */
    /**
     The meeting data for this page of meetings.
     */
    public let meetings: [Meeting]
    
    // MARK: Public Initializer
    
    /* ################################################# */
    /**
     This is a failable initializer. It parses the JSON data.
     
     - parameter jsonData: A Data instance, with the raw JSON dump.
     */
    public init?(jsonData inJSONData: Data) {
        guard let simpleJSON = try? JSONSerialization.jsonObject(with: inJSONData, options: [.allowFragments]) as? NSDictionary,
              let metaJSON = simpleJSON["meta"] as? [String: Any],
              let meta = Self._parseMeta(metaJSON),
              let meetingsJSON = simpleJSON["meetings"] as? [[String: Any]]
        else { return nil }
        self.meta = meta
        self.meetings = meetingsJSON.compactMap { Self._parseMeeting($0) }
    }
}

