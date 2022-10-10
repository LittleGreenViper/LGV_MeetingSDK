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
     
     - parameter inComp: A location (long and lat), to which we are comparing ourselves.
     - parameter precisionInMeters: This is an optional precision (slop area), in meters. If left out, then the match must be exact.
     
     - returns: True, if the locations are equal, according to the given precision.
     */
    func isEqualTo(_ inComp: CLLocationCoordinate2D, precisionInMeters inPrecisionInMeters: CLLocationDistance = 0.0) -> Bool {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: inComp.latitude, longitude: inComp.longitude)) <= inPrecisionInMeters
    }
}

/* ###################################################################################################################################### */
// MARK: - BMLT Parser Extension (Static Utility Methods) -
/* ###################################################################################################################################### */
internal extension LGV_MeetingSDK_BMLT.Transport.Parser {
    /* ################################################################## */
    /**
     This allows us to find if a string contains another string.
     
     - parameter inString: The string we're looking for.
     - parameter withinThisString: The string we're looking through.
     - parameter options (OPTIONAL): The String options for the search. Default is case insensitive, and diacritical insensitive.
     
     - returns: True, if the string contains the other String.
     */
    private static func _isThisString(_ inString: String, withinThisString inMainString: String, options inOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]) -> Bool { nil != inMainString.range(of: inString, options: inOptions)?.lowerBound }

    /* ################################################################## */
    /**
     "Cleans" a URI.
     
     - parameter urlString: The URL, as a String. It can be optional.
     
     - returns: an optional String. This is the given URI, "cleaned up" ("https://" or "tel:" may be prefixed)
     */
    private static func _cleanURI(urlString inURLString: String?) -> String? {
        /* ################################################################## */
        /**
         This tests a string to see if a given substring is present at the start.
         
         - parameter inString: The string to test.
         - parameter inSubstring: The substring to test for.

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
    private static func _decimalOnly(_ inString: String) -> String {
        let decimalDigits = CharacterSet(charactersIn: "0123456789")
        return inString.filter {
            // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
            guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
            
            return decimalDigits.contains(cha)
        }
    }
    
    /* ################################################################## */
    /**
     Creates (or not) a virtual location, based on the provided meeting details.
     
     - parameter theseMeetings: The Dictionary that represents this meeting.
     - returns: A new virtual location instance.
     */
    private static func _convert(thisDataToAVirtualLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_BMLT.Meeting.VirtualLocation? {
        let meetingURL = URL(string: _cleanURI(urlString: inMeetingData["virtual_meeting_link"] ?? inMeetingData["virtual_meeting_additional_info"] ?? "") ?? "")
                        ?? URL(string: _cleanURI(urlString: inMeetingData["comments"] ?? "") ?? "")
        let phoneNumber = _decimalOnly(inMeetingData["phone_meeting_number"] ?? "")
        let phoneURL = phoneNumber.isEmpty ? nil : URL(string: "tel:\(phoneNumber)")
        let extraInfo = inMeetingData["virtual_meeting_additional_info"] ?? ""
        var timeZone: TimeZone
        if let timeZoneIdentifier = inMeetingData["time_zone"],
           let timeZoneTemp = TimeZone(identifier: timeZoneIdentifier) {
            timeZone = timeZoneTemp
        } else {
            timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        }

        var videoVenue: LGV_MeetingSDK_BMLT.Meeting.VirtualLocation.VirtualVenue?
        var phoneVenue: LGV_MeetingSDK_BMLT.Meeting.VirtualLocation.VirtualVenue?

        if let meetingURL = meetingURL {
            videoVenue = LGV_MeetingSDK_BMLT.Meeting.VirtualLocation.VirtualVenue(description: "",
                                                                                  timeZone: timeZone,
                                                                                  url: meetingURL,
                                                                                  extraInfo: extraInfo)
        }

        if let phoneURL = phoneURL {
            phoneVenue = LGV_MeetingSDK_BMLT.Meeting.VirtualLocation.VirtualVenue(description: "",
                                                                                  timeZone: timeZone,
                                                                                  url: phoneURL,
                                                                                  extraInfo: extraInfo)
        }

        guard nil != videoVenue || nil != phoneVenue else { return nil }
        
        return LGV_MeetingSDK_BMLT.Meeting.VirtualLocation(videoMeeting: videoVenue, phoneMeeting: phoneVenue, extraInfo: "")
    }
    
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter theseMeetings: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     - returns: A new physical location instance.
     */
    private static func _convert(thisDataToAPhysicalLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_BMLT.Meeting.PhysicalLocation? {
        let coords = CLLocationCoordinate2D(latitude: Double(inMeetingData["latitude"] ?? "0") ?? 0, longitude: Double(inMeetingData["longitude"] ?? "0") ?? 0)
        let name = inMeetingData["location_text"] ?? ""
        let extraInfo = inMeetingData["location_info"] ?? ""
        var timeZone = TimeZone.autoupdatingCurrent
        if let timeZoneIdentifier = inMeetingData["time_zone"],
           let timeZoneTemp = TimeZone(identifier: timeZoneIdentifier) {
            timeZone = timeZoneTemp
        }

        let postalAddress = CNMutablePostalAddress()

        if let value = inMeetingData["location_street"] {
            postalAddress.street = value
        }
        
        if let value = inMeetingData["location_city_subsection"] {
            postalAddress.subLocality = value
        }
        
        if let value = inMeetingData["location_municipality"] {
            postalAddress.city = value
        }
        
        if let value = inMeetingData["location_sub_province"] {
            postalAddress.subAdministrativeArea = value
        }
        
        if let value = inMeetingData["location_province"] {
            postalAddress.state = value
        }
        
        if let value = inMeetingData["location_postal_code_1"] {
            postalAddress.postalCode = value
        }
        
        if let value = inMeetingData["location_nation"] {
            postalAddress.country = value
        }

        return LGV_MeetingSDK_BMLT.Meeting.PhysicalLocation(coords: coords, name: name, postalAddress: postalAddress, timeZone: timeZone, extraInfo: extraInfo)
    }

    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter theseFormats: The Dictionary of String Dictionaries that represent the parsed JSON object for the formats.
     - returns: An Array of parsed and initialized format instances.
     */
    private static func _convert(theseFormats inJSONParsedFormats: [[String: String]]) -> [UInt64: LGV_MeetingSDK_Format_Protocol] {
        var ret = [UInt64: LGV_MeetingSDK_Format_Protocol]()
        
        inJSONParsedFormats.forEach { formatDictionary in
            guard let str = formatDictionary["id"],
                  let id = UInt64(str),
                  let key = formatDictionary["key_string"],
                  let name = formatDictionary["name_string"],
                  let description = formatDictionary["description_string"]
            else { return }
            let format = LGV_MeetingSDK_BMLT.Format(id: id, key: key, name: name, description: description)
            ret[id] = format
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     Yeah, this is a big, ugly function, with lots of cyclomatic complexity.
     
     Deal with it. It works great.
     
     - parameter inMeetings: The meeting array to be filtered.
     - parameter searchType: This is the search specification main search type.
     - parameter searchRefinements: This is the search specification additional filters.
     
     - returns: The refined meeting array.
     */
    private static func _refineMeetings(_ inMeetings: [LGV_MeetingSDK_Meeting_Protocol],
                                        searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                                        searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>) -> [LGV_MeetingSDK_Meeting_Protocol] {
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
            /* ########################################################## */
            /**
             Checks a meeting, to see if a given string is present.
             
             - parameter meeting: The meeing instance to check (haystack).
             - parameter string: The string we're looking for (needle).
             
             - returns: True, if the meeting contains the string we're looking for.
             */
            func _isStringInHere(meeting inMeeting: LGV_MeetingSDK_Meeting_Protocol, string inString: String) -> Bool {
                var ret = false
                
                if _isThisString(inString, withinThisString: inMeeting.name)
                    || _isThisString(inString, withinThisString: inMeeting.extraInfo) {
                    ret = true
                } else if let physicalLocationName = inMeeting.physicalLocation?.name,
                          _isThisString(inString, withinThisString: physicalLocationName) {
                    ret = true
                } else if let virtualInfo = inMeeting.virtualMeetingInfo?.videoMeeting?.extraInfo,
                          _isThisString(inString, withinThisString: virtualInfo) {
                    ret = true
                } else if let virtualInfo = inMeeting.virtualMeetingInfo?.videoMeeting?.description,
                          _isThisString(inString, withinThisString: virtualInfo) {
                    ret = true
                } else if let virtualInfo = inMeeting.virtualMeetingInfo?.phoneMeeting?.extraInfo,
                          _isThisString(inString, withinThisString: virtualInfo) {
                    ret = true
                } else if let virtualInfo = inMeeting.virtualMeetingInfo?.phoneMeeting?.description,
                          _isThisString(inString, withinThisString: virtualInfo) {
                    ret = true
                } else if !meeting.formats.isEmpty {
                    for meetingFormat in inMeeting.formats where _isThisString(inString, withinThisString: meetingFormat.name) || _isThisString(inString, withinThisString: meetingFormat.description) {
                        ret = true
                        break
                    }
                }
                
                return ret
            }
            
            // First filter is for distance.
            if 0 > maximumDistanceInMeters || meeting.distanceInMeters <= maximumDistanceInMeters {
                // We then see if we specified any refinements. If so, we need to meet them.
                if !inSearchRefinements.isEmpty {
                    var returned: LGV_MeetingSDK_Meeting_Protocol?
                    for refinement in inSearchRefinements.enumerated() {
                        switch refinement.element {
                        // String searches look at a number of fields in each meeting.
                        case let .string(searchForThisString):
                            guard _isStringInHere(meeting: meeting, string: searchForThisString) else { return nil }
                          
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
// MARK: Instance Utility Methods
/* ###################################################################################################################################### */
internal extension LGV_MeetingSDK_BMLT.Transport.Parser {
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     - parameter theseMeetings: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     - parameter andTheseFormats: The Dictionary of parsed formats.
     - returns: An Array of parsed and initialized meeting instances.
     */
    private func _convert(theseMeetings inJSONParsedMeetings: [[String: String]], andTheseFormats inFormats: [UInt64: LGV_MeetingSDK_Format_Protocol], searchCenter inSearchCenter: CLLocation) -> [LGV_MeetingSDK_Meeting_Protocol] {
        var ret = [LGV_MeetingSDK_Meeting_Protocol]()
        
        guard let organization = initiator?.transport?.organization else { return [] }
        
        inJSONParsedMeetings.forEach { meetingDictionary in
            let meetingDurationComponents = meetingDictionary["duration_time"]?.split(separator: ":").map { Int($0) ?? 0 } ?? [0, 0]
            guard 1 < meetingDurationComponents.count,
                  let str = meetingDictionary["id_bigint"],
                  let sharedFormatIDs = meetingDictionary["format_shared_id_list"],
                  let id = UInt64(str)
            else { return }
            let meetingName = meetingDictionary["meeting_name"] ?? "NA Meeting"
            let weekdayIndex = Int(meetingDictionary["weekday_tinyint"] ?? "0") ?? 0
            let meetingStartTime = (Int(Self._decimalOnly(meetingDictionary["start_time"] ?? "00:00:00")) ?? 0) / 100
            let meetingDuration = TimeInterval((meetingDurationComponents[0] * (60 * 60)) + (meetingDurationComponents[1] * 60))
            let formats = sharedFormatIDs.split(separator: ",").compactMap { UInt64($0) }.compactMap { inFormats[$0] }
            let physicalLocation = Self._convert(thisDataToAPhysicalLocation: meetingDictionary)
            let virtualInformation = Self._convert(thisDataToAVirtualLocation: meetingDictionary)
            let comments = meetingDictionary["comments"] ?? ""
            var distance = Double.greatestFiniteMagnitude
            if let coords = physicalLocation?.coords,
               coords.isValid,
               inSearchCenter.coordinate.isValid {
                let meetingLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
                distance = abs(meetingLocation.distance(from: inSearchCenter))
            }

            ret.append(LGV_MeetingSDK_BMLT.Meeting(organization: organization,
                                                   id: id,
                                                   weekdayIndex: weekdayIndex,
                                                   meetingStartTime: meetingStartTime,
                                                   name: meetingName,
                                                   extraInfo: comments,
                                                   meetingDuration: meetingDuration,
                                                   distanceInMeters: distance,
                                                   formats: formats,
                                                   physicalLocation: physicalLocation,
                                                   virtualMeetingInfo: virtualInformation
                                                  )
                       )
        }

        return ret.sorted { lhs, rhs in
            guard !inSearchCenter.coordinate.isValid || lhs.distanceInMeters == rhs.distanceInMeters else {
                return lhs.distanceInMeters < rhs.distanceInMeters
            }
            
            guard lhs.adjustedWeekdayIndex == rhs.adjustedWeekdayIndex else {
                return lhs.adjustedWeekdayIndex < rhs.adjustedWeekdayIndex
            }
            
            guard lhs.meetingStartTime == rhs.meetingStartTime else {
                return lhs.meetingStartTime < rhs.meetingStartTime
            }
            
            guard lhs.meetingType == rhs.meetingType else {
                switch lhs.meetingType {
                case .invalid, .virtualOnly:
                    return false
                    
                case .inPersonOnly:
                    return .hybrid == rhs.meetingType
                
                case .hybrid:
                    return true
                }
            }
            
            return false
        }
    }
}

/* ###################################################################################################################################### */
// MARK: LGV_MeetingSDK_Parser_Protocol Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_BMLT.Transport.Parser: LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - Parameters:
        - searchType (OPTIONAL): This is the search specification main search type. Default is .none.
        - searchRefinements (OPTIONAL): This is the search specification additional filters. Default is .none.
        - data: The unparsed data, from the transport. It should consist of a meeting data set.
        - completion: A callback, for when the parse is complete. This is escaping, and may not be called in the main thread.
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                          searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                          data inData: Data,
                          completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        let emptyResponse = LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements)
        do {
            if let main_object = try JSONSerialization.jsonObject(with: inData, options: []) as? [String: [[String: String]]],
               let meetingsObject = main_object["meetings"],
               let formatsObject = main_object["formats"] {
                var searchCenter: CLLocation = CLLocation(latitude: 0, longitude: 0)
                if case let .fixedRadius(centerLongLat, _) = inSearchType {
                    searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
                } else if case let .autoRadius(centerLongLat, _, _) = inSearchType {
                    searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
                }
                
                let formats = Self._convert(theseFormats: formatsObject)
                
                var distanceFrom: CLLocation?
                
                // We can specify a "distance from here" in refinements, and that trumps a search center, for distances. It can also add distances to otherwise unmeasured meetings.
                for refinement in inSearchRefinements.enumerated() {
                    if case let .distanceFrom(thisLocation) = refinement.element {
                        distanceFrom = CLLocation(latitude: thisLocation.latitude, longitude: thisLocation.longitude)
                        break
                    }
                }
                
                let meetings = Self._refineMeetings(_convert(theseMeetings: meetingsObject, andTheseFormats: formats, searchCenter: searchCenter), searchType: inSearchType, searchRefinements: inSearchRefinements).map {
                    var meeting = $0
                    
                    if let distanceFrom = distanceFrom,
                       let meetingCoords = meeting.locationCoords {
                        let meetingLocation = CLLocation(latitude: meetingCoords.latitude, longitude: meetingCoords.longitude)
                        meeting.distanceInMeters = distanceFrom.distance(from: meetingLocation)
                    }
                    
                    return meeting
                }
                
                let meetingData = LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: meetings)

                inCompletion(meetingData, nil)
            } else {
                inCompletion(LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: []), nil)
            }
        } catch {
            inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.parsingError(error: .jsonParseFailure(error: error)))
        }
    }
}
