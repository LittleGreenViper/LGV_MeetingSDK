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
// MARK: - BMLT Parser Extension (Static Utility Methods) -
/* ###################################################################################################################################### */
internal extension LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser {
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
    private static func _convert(thisDataToAVirtualLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation? {
        let meetingURL = URL(string: _cleanURI(urlString: inMeetingData["url"] ?? inMeetingData["info"] ?? "") ?? "")
        let phoneNumber = _decimalOnly(inMeetingData["phone_number"] ?? "")
        let phoneURL = phoneNumber.isEmpty ? nil : URL(string: "tel:\(phoneNumber)")
        let extraInfo = inMeetingData["info"] ?? ""
        var timeZone: TimeZone
        if let timeZoneIdentifier = inMeetingData["time_zone"],
           let timeZoneTemp = TimeZone(identifier: timeZoneIdentifier) {
            timeZone = timeZoneTemp
        } else {
            timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        }

        var videoVenue: LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation.VirtualVenue?
        var phoneVenue: LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation.VirtualVenue?

        if let meetingURL = meetingURL {
            videoVenue = LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation.VirtualVenue(description: "",
                                                                                  timeZone: timeZone,
                                                                                  url: meetingURL,
                                                                                  extraInfo: extraInfo)
        }

        if let phoneURL = phoneURL {
            phoneVenue = LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation.VirtualVenue(description: "",
                                                                                  timeZone: timeZone,
                                                                                  url: phoneURL,
                                                                                  extraInfo: extraInfo)
        }

        guard nil != videoVenue || nil != phoneVenue else { return nil }
        
        return LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation(videoMeeting: videoVenue, phoneMeeting: phoneVenue, extraInfo: "")
    }
    
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter thisDataToAPhysicalLocation: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     - parameter coords: The meeting coordinates.
     
     - returns: A new physical location instance.
     */
    private static func _convert(thisDataToAPhysicalLocation inMeetingData: [String: String], coords inCoords: CLLocationCoordinate2D) -> LGV_MeetingSDK_LGV_MeetingServer.Meeting.PhysicalLocation? {
        let name = inMeetingData["name"] ?? ""
        let extraInfo = inMeetingData["info"] ?? ""
        let timeZone = TimeZone.autoupdatingCurrent

        let postalAddress = CNMutablePostalAddress()

        if let value = inMeetingData["street"] {
            postalAddress.street = value
        }
        
        // No street, no physical location.
        guard !postalAddress.street.isEmpty else { return nil }
        
        if let value = inMeetingData["city_subsection"] {
            postalAddress.subLocality = value
        }
        
        if let value = inMeetingData["municipality"] {
            postalAddress.city = value
        }
        
        if let value = inMeetingData["sub_province"] {
            postalAddress.subAdministrativeArea = value
        }
        
        if let value = inMeetingData["province"] {
            postalAddress.state = value
        }
        
        if let value = inMeetingData["postal_code"] {
            postalAddress.postalCode = value
        }
        
        if let value = inMeetingData["nation"] {
            postalAddress.country = value
        }

        return LGV_MeetingSDK_LGV_MeetingServer.Meeting.PhysicalLocation(coords: inCoords, name: name, postalAddress: postalAddress, timeZone: timeZone, extraInfo: extraInfo)
    }

    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter theseFormats: The Dictionary of String Dictionaries that represent the parsed JSON object for the formats.
     
     - returns: An Array of parsed and initialized format instances.
     */
    private static func _convert(theseFormats inJSONParsedFormats: [[String: Any]]) -> [LGV_MeetingSDK_Format_Protocol] {
        var ret = [LGV_MeetingSDK_Format_Protocol]()
        
        inJSONParsedFormats.forEach {
            guard let idInt = $0["id"] as? Int,
                  let key = $0["key"] as? String,
                  let name = $0["name"] as? String,
                  let description = $0["description"] as? String
            else { return }
            let id = UInt64(idInt)
            let format = LGV_MeetingSDK_LGV_MeetingServer.Format(id: id, key: key, name: name, description: description)
            ret.append(format)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     Yeah, this is a big, ugly function, with lots of cyclomatic complexity.
     
     Deal with it. It works great.
     
     - Parameters:
         - inMeetings: The meeting array to be filtered.
         - searchType: This is the search specification main search type.
         - searchRefinements: This is the search specification additional filters.
     
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
internal extension LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser {
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - Parameters:
         - theseMeetings: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     
     - returns: An Array of parsed and initialized meeting instances.
     */
    private func _convert(theseMeetings inJSONParsedMeetings: [[String: Any]], searchCenter inSearchCenter: CLLocation) -> [LGV_MeetingSDK_Meeting_Protocol] {
        guard let organization = initiator?.transport?.organization else { return [] }

        var ret = [LGV_MeetingSDK_Meeting_Protocol]()
        
        inJSONParsedMeetings.forEach { rawMeetingObject in
            let serverID = UInt64(rawMeetingObject["server_id"] as? Int ?? 0)
            let meetingID = UInt64(rawMeetingObject["meeting_id"] as? Int ?? 0)
            let organizationKey: String = rawMeetingObject["organization_key"] as? String ?? ""
            let coords = CLLocationCoordinate2D(latitude: Double(rawMeetingObject["latitude"] as? Double ?? 0), longitude: Double(rawMeetingObject["longitude"] as? Double ?? 0))
            let name = rawMeetingObject["name"] as? String ?? ""
            let comments = rawMeetingObject["comments"] as? String ?? ""
            let duration = TimeInterval(rawMeetingObject["duration"] as? Int ?? 0)
            let weekday = rawMeetingObject["weekday"] as? Int ?? 0
            let meetingStartTime = (Int(Self._decimalOnly(rawMeetingObject["start_time"] as? String ?? "00:00:00")) ?? 0) / 100
            let distance: CLLocationDistance = CLLocationDistance(rawMeetingObject["distance"] as? Double ?? Double.greatestFiniteMagnitude)
            let formats: [LGV_MeetingSDK_Format_Protocol] = Self._convert(theseFormats: rawMeetingObject["formats"] as? [[String: Any]] ?? [])

            var physicalLocation: LGV_MeetingSDK_LGV_MeetingServer.Meeting.PhysicalLocation?

            if let physicalAddress = rawMeetingObject["physical_address"] as? [String: String] {
                physicalLocation = Self._convert(thisDataToAPhysicalLocation: physicalAddress, coords: coords)
            }
            
            var virtualInformation: LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation?

            if let virtualStuff = rawMeetingObject["virtual_information"] as? [String: String] {
                virtualInformation = Self._convert(thisDataToAVirtualLocation: virtualStuff)
            }

            print("Meeting:\n\tcoords: \(coords)\n\tname: \(name)\n\tserver_id: \(serverID)\n\tmeeting_id: \(meetingID)\n\torganizationKey: \(organizationKey)\n\tduration: \(duration)\n\tdistance: \(String(describing: distance))")
            print("\tformats: \(formats.debugDescription)")
            print("\tphysicalLocation: \(physicalLocation.debugDescription)")
            print("\tvirtualInformation: \(virtualInformation.debugDescription)")
            
            let id = (serverID << 44) + meetingID
            
            ret.append(LGV_MeetingSDK_LGV_MeetingServer.Meeting(organization: organization,
                                                                id: id,
                                                                weekdayIndex: weekday,
                                                                meetingStartTime: meetingStartTime,
                                                                name: name,
                                                                extraInfo: comments,
                                                                meetingDuration: duration,
                                                                distanceInMeters: distance,
                                                                formats: formats,
                                                                physicalLocation: physicalLocation,
                                                                virtualMeetingInfo: virtualInformation
                                                               )
                       )
        }
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: LGV_MeetingSDK_Parser_Protocol Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser: LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - Parameters:
        - searchType (OPTIONAL): This is the search specification main search type. Default is .none.
        - searchRefinements (OPTIONAL): This is the search specification additional filters. Default is .none.
        - data: The unparsed data, from the transport. It should consist of a meeting data set.
        - refCon: An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion: A callback, for when the parse is complete. This is escaping, and may not be called in the main thread.
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                          searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                          data inData: Data,
                          refCon inRefCon: Any?,
                          completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        let emptyResponse = LGV_MeetingSDK_LGV_MeetingServer.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, refCon: inRefCon)
        do {
            if let meetingsObject = (try JSONSerialization.jsonObject(with: inData, options: []) as? [String: Any])?["meetings"] as? [[String: Any]] {
                var searchCenter: CLLocation = CLLocation(latitude: 0, longitude: 0)
                if case let .fixedRadius(centerLongLat, _) = inSearchType {
                    searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
                } else if case let .autoRadius(centerLongLat, _, _) = inSearchType {
                    searchCenter = CLLocation(latitude: centerLongLat.latitude, longitude: centerLongLat.longitude)
                }
                
                var distanceFrom: CLLocation?
                
                // We can specify a "distance from here" in refinements, and that trumps a search center, for distances. It can also add distances to otherwise unmeasured meetings.
                for refinement in inSearchRefinements.enumerated() {
                    if case let .distanceFrom(thisLocation) = refinement.element {
                        distanceFrom = CLLocation(latitude: thisLocation.latitude, longitude: thisLocation.longitude)
                        break
                    }
                }
                
                let meetings = Self._refineMeetings(_convert(theseMeetings: meetingsObject, searchCenter: searchCenter), searchType: inSearchType, searchRefinements: inSearchRefinements).map {
                    var meeting = $0
                    
                    if let distanceFrom = distanceFrom,
                       let meetingCoords = meeting.locationCoords {
                        let meetingLocation = CLLocation(latitude: meetingCoords.latitude, longitude: meetingCoords.longitude)
                        meeting.distanceInMeters = distanceFrom.distance(from: meetingLocation)
                    }
                    
                    return meeting
                }
                
                let meetingData = LGV_MeetingSDK_LGV_MeetingServer.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: meetings, refCon: inRefCon)
                
                inCompletion(meetingData, nil)
            } else {
                inCompletion(LGV_MeetingSDK_LGV_MeetingServer.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: [], refCon: inRefCon), nil)
            }
        } catch {
            inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.parsingError(error: .jsonParseFailure(error: error)))
        }
    }
}
