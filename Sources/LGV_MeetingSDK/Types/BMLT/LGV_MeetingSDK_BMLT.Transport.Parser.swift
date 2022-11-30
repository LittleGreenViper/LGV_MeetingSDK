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
internal extension LGV_MeetingSDK_BMLT.Transport.Parser {
    /* ################################################################## */
    /**
     Creates (or not) a virtual location, based on the provided meeting details.
     
     - parameter theseMeetings: The Dictionary that represents this meeting.
     
     - returns: A new virtual location instance.
     */
    private static func _convert(thisDataToAVirtualLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_BMLT.Meeting.VirtualLocation? {
        let meetingURL = URL(string: LGV_MeetingSDK.cleanURI(urlString: inMeetingData["virtual_meeting_link"] ?? inMeetingData["virtual_meeting_additional_info"] ?? "") ?? "")
        let phoneNumber = LGV_MeetingSDK.decimalOnly(inMeetingData["phone_meeting_number"] ?? "")
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
        
        return LGV_MeetingSDK.Meeting.VirtualLocation(videoMeeting: videoVenue, phoneMeeting: phoneVenue, extraInfo: "")
    }
    
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter thisDataToAPhysicalLocation: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     
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

        var postalAddress: CNMutablePostalAddress?

        if let value = inMeetingData["location_street"],
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            postalAddress = CNMutablePostalAddress()
            postalAddress?.street = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // No street, no address.
        if nil != postalAddress {
            if let value = inMeetingData["location_city_subsection"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.subLocality = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["location_municipality"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.city = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["location_sub_province"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.subAdministrativeArea = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["location_province"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.state = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["location_postal_code_1"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.postalCode = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["location_nation"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.country = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return LGV_MeetingSDK.Meeting.PhysicalLocation(coords: coords, name: name, postalAddress: postalAddress, timeZone: timeZone, extraInfo: extraInfo)
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
            let format = LGV_MeetingSDK.Meeting.Format(id: id, key: key, name: name, description: description)
            ret[id] = format
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Utility Methods
/* ###################################################################################################################################### */
internal extension LGV_MeetingSDK_BMLT.Transport.Parser {
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - Parameters:
         - theseMeetings: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
         - andTheseFormats: The Dictionary of parsed formats.
     
     - returns: An Array of parsed and initialized meeting instances.
     */
    private func _convert(theseMeetings inJSONParsedMeetings: [[String: String]], andTheseFormats inFormats: [UInt64: LGV_MeetingSDK_Format_Protocol], searchCenter inSearchCenter: CLLocation) -> [LGV_MeetingSDK.Meeting] {
        guard let organization = initiator?.transport?.organization else { return [] }
        
        var ret = [LGV_MeetingSDK.Meeting]()
        
        inJSONParsedMeetings.forEach { meetingDictionary in
            let meetingDurationComponents = meetingDictionary["duration_time"]?.split(separator: ":").map { Int($0) ?? 0 } ?? [0, 0]
            guard 1 < meetingDurationComponents.count,
                  let str = meetingDictionary["id_bigint"],
                  let sharedFormatIDs = meetingDictionary["format_shared_id_list"],
                  let id = UInt64(str)
            else { return }
            let meetingName = meetingDictionary["meeting_name"] ?? "NA Meeting"
            let weekdayIndex = Int(meetingDictionary["weekday_tinyint"] ?? "0") ?? 0
            let meetingStartTime = (Int(LGV_MeetingSDK.decimalOnly(meetingDictionary["start_time"] ?? "00:00:00")) ?? 0) / 100
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

            ret.append(LGV_MeetingSDK.Meeting(organization: organization,
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
        - refCon: An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion: A callback, for when the parse is complete. This is escaping, and may not be called in the main thread.
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                          searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                          data inData: Data,
                          refCon inRefCon: Any?,
                          completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        let emptyResponse = LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, refCon: inRefCon)
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
                
                let meetings = LGV_MeetingSDK.refineMeetings(_convert(theseMeetings: meetingsObject, andTheseFormats: formats, searchCenter: searchCenter), searchType: inSearchType, searchRefinements: inSearchRefinements).map {
                    var meeting = $0
                    
                    if let distanceFrom = distanceFrom,
                       let meetingCoords = meeting.locationCoords {
                        let meetingLocation = CLLocation(latitude: meetingCoords.latitude, longitude: meetingCoords.longitude)
                        meeting.distanceInMeters = distanceFrom.distance(from: meetingLocation)
                    }
                    
                    return meeting
                }
                
                let meetingData = LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: meetings, refCon: inRefCon)
                
                inCompletion(meetingData, nil)
            } else {
                inCompletion(LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: [], refCon: inRefCon), nil)
            }
        } catch {
            inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.parsingError(error: .jsonParseFailure(error: error)))
        }
    }
}
