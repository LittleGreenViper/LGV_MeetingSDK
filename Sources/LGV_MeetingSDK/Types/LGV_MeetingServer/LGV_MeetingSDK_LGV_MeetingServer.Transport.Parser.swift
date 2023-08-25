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
// MARK: - LGV_MeetingServer Parser Extension (Static Utility Methods) -
/* ###################################################################################################################################### */
internal extension LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser {
    /* ################################################################## */
    /**
     Creates (or not) a virtual location, based on the provided meeting details.
     
     - parameter theseMeetings: The Dictionary that represents this meeting.
     
     - returns: A new virtual location instance.
     */
    private static func _convert(thisDataToAVirtualLocation inMeetingData: [String: String]) -> LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation? {
        let meetingURL = URL(string: LGV_MeetingSDK.cleanURI(urlString: inMeetingData["url"] ?? inMeetingData["info"] ?? "") ?? "")
        let phoneNumber = LGV_MeetingSDK.decimalOnly(inMeetingData["phone_number"] ?? "")
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
        
        return LGV_MeetingSDK.Meeting.VirtualLocation(videoMeeting: videoVenue, phoneMeeting: phoneVenue, extraInfo: "")
    }
    
    /* ################################################################## */
    /**
     This converts "raw" (String Dictionary) meeting objects, into actual Swift structs.
     
     - parameter thisDataToAPhysicalLocation: The Dictionary of String Dictionaries that represent the parsed JSON object for the meetings.
     - parameter coords: The meeting coordinates.
     
     - returns: A new physical location instance.
     */
    private static func _convert(thisDataToAPhysicalLocation inMeetingData: [String: String], timeZoneID inTimeZoneID: String?, coords inCoords: CLLocationCoordinate2D) -> LGV_MeetingSDK_LGV_MeetingServer.Meeting.PhysicalLocation? {
        let name = inMeetingData["name"] ?? ""
        let extraInfo = inMeetingData["info"] ?? ""
        var meetingLocalTimezone: TimeZone
        
        if let timeZoneIdentifier = !(inTimeZoneID ?? "").isEmpty ? inTimeZoneID ?? "" : inMeetingData["time_zone"],
           let timeZoneTemp = TimeZone(identifier: timeZoneIdentifier) {
            meetingLocalTimezone = timeZoneTemp
        } else {
            meetingLocalTimezone = .current
        }

        var postalAddress: CNMutablePostalAddress?

        if let value = inMeetingData["street"],
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            postalAddress = CNMutablePostalAddress()
            postalAddress?.street = value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // No street, no address.
        if nil != postalAddress {
            if let value = inMeetingData["city_subsection"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.subLocality = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["city"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.city = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["sub_province"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.subAdministrativeArea = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["province"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.state = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["postal_code"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.postalCode = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            if let value = inMeetingData["nation"],
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                postalAddress?.country = value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return LGV_MeetingSDK.Meeting.PhysicalLocation(coords: inCoords, name: name, postalAddress: postalAddress, timeZone: meetingLocalTimezone, extraInfo: extraInfo)
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
            let format = LGV_MeetingSDK.Meeting.Format(id: id, key: key, name: name, description: description)
            ret.append(format)
        }
        
        return ret
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
    private func _convert(theseMeetings inJSONParsedMeetings: [[String: Any]], searchCenter inSearchCenter: CLLocation) -> [LGV_MeetingSDK.Meeting] {
        guard let organization = initiator?.transport?.organization else { return [] }

        var ret = [LGV_MeetingSDK.Meeting]()
        
        inJSONParsedMeetings.forEach { rawMeetingObject in
            let serverID = UInt64(rawMeetingObject["server_id"] as? Int ?? 0)
            let meetingID = UInt64(rawMeetingObject["meeting_id"] as? Int ?? 0)
            let organizationKey: String = rawMeetingObject["organization_key"] as? String ?? ""
            let coords = CLLocationCoordinate2D(latitude: Double(rawMeetingObject["latitude"] as? Double ?? 0), longitude: Double(rawMeetingObject["longitude"] as? Double ?? 0))
            let name = rawMeetingObject["name"] as? String ?? ""
            let comments = rawMeetingObject["comments"] as? String ?? ""
            let duration = TimeInterval(rawMeetingObject["duration"] as? Int ?? 0)
            let weekday = rawMeetingObject["weekday"] as? Int ?? 0
            let timeZoneID = rawMeetingObject["time_zone"] as? String
            let meetingStartTime = (Int(LGV_MeetingSDK.decimalOnly(rawMeetingObject["start_time"] as? String ?? "00:00:00")) ?? 0) / 100
            let distance: CLLocationDistance = CLLocationDistance(rawMeetingObject["distance"] as? Double ?? Double.greatestFiniteMagnitude)
            let formats: [LGV_MeetingSDK_Format_Protocol] = Self._convert(theseFormats: rawMeetingObject["formats"] as? [[String: Any]] ?? [])

            var physicalLocation: LGV_MeetingSDK_LGV_MeetingServer.Meeting.PhysicalLocation?

            if let physicalAddress = rawMeetingObject["physical_address"] as? [String: String] {
                physicalLocation = Self._convert(thisDataToAPhysicalLocation: physicalAddress, timeZoneID: timeZoneID, coords: coords)
            }
            
            var virtualInformation: LGV_MeetingSDK_LGV_MeetingServer.Meeting.VirtualLocation?

            if let virtualStuff = rawMeetingObject["virtual_information"] as? [String: String] {
                virtualInformation = Self._convert(thisDataToAVirtualLocation: virtualStuff)
            }
            
            var localTimeZone = physicalLocation?.timeZone
            
            if nil == localTimeZone {
                if let timeZoneIdentifier = timeZoneID,
                   let timeZoneTemp = TimeZone(identifier: timeZoneIdentifier) {
                    localTimeZone = timeZoneTemp
                } else {
                    localTimeZone = .current
                }
            }

            #if DEBUG
                print("Meeting:\n\tweekday: \(weekday)\n\tstart_time: \(meetingStartTime)\n\tcoords: \(coords)\n\tname: \(name)\n\tserver_id: \(serverID)\n\tmeeting_id: \(meetingID)\n\torganizationKey: \(organizationKey)\n\tduration: \(duration)\n\tdistance: \(String(describing: distance))")
                print("\ttime zone: \(localTimeZone.debugDescription)")
                print("\tformats: \(formats.debugDescription)")
                print("\tphysicalLocation: \(physicalLocation.debugDescription)")
                print("\tvirtualInformation: \(virtualInformation.debugDescription)")
            #endif
            
            let id = (serverID << 44) + meetingID
            guard let localTimeZone = localTimeZone else { return }
            
            ret.append(LGV_MeetingSDK.Meeting(organization: organization,
                                              id: id,
                                              weekdayIndex: weekday,
                                              meetingStartTime: meetingStartTime,
                                              name: name,
                                              extraInfo: comments,
                                              meetingDuration: duration,
                                              distanceInMeters: distance,
                                              formats: formats,
                                              meetingLocalTimezone: localTimeZone,
                                              physicalLocation: physicalLocation,
                                              virtualMeetingInfo: virtualInformation
                                             )
                       )
        }
        
        #if DEBUG
            print("Meeting List: \(ret.debugDescription)")
        #endif
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
        let emptyResponse = LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, refCon: inRefCon)
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
                
                let meetings = LGV_MeetingSDK.refineMeetings(_convert(theseMeetings: meetingsObject, searchCenter: searchCenter), searchType: inSearchType, searchRefinements: inSearchRefinements).map {
                    let meeting = $0
                    
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
