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
     - parameter inComp: A location (long and lat), to which we are comparing ourselves.
     - parameter precisionInMeters: This is an optional precision (slop area), in meters. If left out, then the match must be exact.
     
     - returns: True, if the locations are equal, according to the given precision.
     */
    func isEqualTo(_ inComp: CLLocationCoordinate2D, precisionInMeters inPrecisionInMeters: CLLocationDistance = 0.0) -> Bool {
        CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: inComp.latitude, longitude: inComp.longitude)) <= inPrecisionInMeters
    }
}

/* ###################################################################################################################################### */
// MARK: - BMLT Parser Extension -
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_BMLT.Transport.Parser: LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     This allows us to find if a string contains another string.
     
     - parameter inString: The string we're looking for.
     - parameter withinThisString: The string we're looking through.
     - parameter options (OPTIONAL): The String options for the search. Default is case insensitive, and diacritical insensitive.
     
     - returns: True, if the string contains the other String.
     */
    static func isThisString(_ inString: String, withinThisString inMainString: String, options inOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]) -> Bool { nil != inMainString.range(of: inString, options: inOptions)?.lowerBound }

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
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     - parameter theseFormats: The Dictionary of String Dictionaries that represent the parsed JSON object for the formats.
     - returns: An Array of parsed and initialized format instances.
     */
    private func _convert(theseFormats inJSONParsedFormats: [[String: String]]) -> [UInt64: LGV_MeetingSDK_Format_Protocol] {
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
            let meetingStartTime = (Int(Self.decimalOnly(meetingDictionary["start_time"] ?? "00:00:00")) ?? 0) / 100
            let meetingDuration = TimeInterval((meetingDurationComponents[0] * (60 * 60)) + (meetingDurationComponents[1] * 60))
            let formats = sharedFormatIDs.split(separator: ",").compactMap { UInt64($0) }.compactMap { inFormats[$0] }
            let physicalLocation = _convert(thisDataToAPhysicalLocation: meetingDictionary)
            let virtualInformation = _convert(thisDataToAVirtualLocation: meetingDictionary)
            let comments = meetingDictionary["comments"] ?? ""
            var distance = Double.greatestFiniteMagnitude
            if let coords = physicalLocation?.coords,
               coords.isValid,
               inSearchCenter.coordinate.isValid {
                let meetingLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
                distance = abs(meetingLocation.distance(from: inSearchCenter))
            }

            let meeting = LGV_MeetingSDK_BMLT.Meeting(organization: organization,
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
            ret.append(meeting)
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
    
    /* ################################################################## */
    /**
     - parameter theseMeetings: The Dictionary that represents this meeting.
     - returns: A new virtual location instance.
     */
    private func _convert(thisDataToAVirtualLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_BMLT.Meeting.VirtualLocation? {
        let meetingURL = URL(string: Self.cleanURI(urlString: inMeetingData["virtual_meeting_link"] ?? inMeetingData["virtual_meeting_additional_info"] ?? "") ?? "")
                        ?? URL(string: Self.cleanURI(urlString: inMeetingData["comments"] ?? "") ?? "")
        let phoneNumber = Self.decimalOnly(inMeetingData["phone_meeting_number"] ?? "")
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
    private func _convert(thisDataToAPhysicalLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_BMLT.Meeting.PhysicalLocation? {
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
     REQUIRED - This parses data, and returns meetings.
     
     - parameter searchType (OPTIONAL): This is the search specification main search type. Default is .none.
     - parameter searchRefinements (OPTIONAL): This is the search specification additional filters. Default is .none.
     - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
     - parameter completion: A callback, for when the parse is complete.
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                          searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                          data inData: Data,
                          completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        /* ############################################################## */
        /**
         - parameter inMeetings: The meeting array to be filtered.
         - parameter searchRefinements: This is the search specification additional filters.
         
         - returns: The refined meeting array.
         */
        func refineMeetings(_ inMeetings: [LGV_MeetingSDK_Meeting_Protocol],
                            searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>) -> [LGV_MeetingSDK_Meeting_Protocol] {
            return inMeetings.compactMap { meeting in
                if !inSearchRefinements.isEmpty {
                    var returned: LGV_MeetingSDK_Meeting_Protocol?
                    for refinement in inSearchRefinements.enumerated() {
                        switch refinement.element {
                        case let .string(searchForThisString):
                            if Self.isThisString(searchForThisString, withinThisString: meeting.name) {
                                returned = meeting
                            } else if Self.isThisString(searchForThisString, withinThisString: meeting.extraInfo) {
                                returned = meeting
                            } else {
                                return nil
                            }
                            
                        case let .weekdays(weekdays):
                            if weekdays.map({ $0.rawValue }).contains(meeting.weekdayIndex) {
                                returned = meeting
                            } else {
                                return nil
                            }
                            
                        default:
                            break
                        }
                        
                        return returned
                    }
                    
                    return nil
                } else {
                    return meeting
                }
            }
        }
        
        if let main_object = try? JSONSerialization.jsonObject(with: inData, options: []) as? [String: [[String: String]]],
           let meetingsObject = main_object["meetings"],
           let formatsObject = main_object["formats"] {
            var searchCenter: CLLocation = CLLocation(latitude: 0, longitude: 0)
            if case let .fixedRadius(centerLongLat, _) = inSearchType {
                searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
            } else if case let .autoRadius(centerLongLat, _, _) = inSearchType {
                searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
            }
            
            // We can specify a "distance from here" in refinements, and that trumps a search center, for distances. It can also add distances to otherwise unmeasured meetings.
            for refinement in inSearchRefinements.enumerated() {
                if case let .distanceFrom(thisLocation) = refinement.element {
                    searchCenter = CLLocation(latitude: thisLocation.latitude, longitude: thisLocation.longitude)
                    break
                }
            }
            
            let formats = _convert(theseFormats: formatsObject)
            let meetings = refineMeetings(_convert(theseMeetings: meetingsObject, andTheseFormats: formats, searchCenter: searchCenter), searchRefinements: inSearchRefinements)
            let meetingData = LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: meetings)

            inCompletion(meetingData, nil)
        }
    }
}
