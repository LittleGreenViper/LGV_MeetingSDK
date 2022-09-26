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
    private func _convert(theseMeetings inJSONParsedMeetings: [[String: String]], andTheseFormats inFormats: [UInt64: LGV_MeetingSDK_Format_Protocol]) -> [LGV_MeetingSDK_Meeting_Protocol] {
        /* ################################################################## */
        /**
         This simply strips out all non-decimal characters in the string, leaving only valid decimal digits.
         
         - parameter inString: The string to be "decimated."
         
         - returns: A String, with all the non-decimal characters stripped.
         */
        func decimalOnly(_ inString: String) -> String {
            let decimalDigits = CharacterSet(charactersIn: "0123456789")
            return inString.filter {
                // The higher-order function stuff will convert each character into an aggregate integer, which then becomes a Unicode scalar. Very primitive, but shouldn't be a problem for us, as we only need a very limited ASCII set.
                guard let cha = UnicodeScalar($0.unicodeScalars.map { $0.value }.reduce(0, +)) else { return false }
                
                return decimalDigits.contains(cha)
            }
        }
        var ret = [LGV_MeetingSDK_Meeting_Protocol]()
        
        guard let organization = initiator?.transport?.organization else { return [] }
        
        inJSONParsedMeetings.forEach { meetingDictionary in
            guard let str = meetingDictionary["id_bigint"],
                  let sharedFormatIDs = meetingDictionary["format_shared_id_list"],
                  let id = UInt64(str)
            else { return }
            let meetingName = meetingDictionary["meeting_name"] ?? "NA Meeting"
            let weekdayIndex = Int(meetingDictionary["weekday_tinyint"] ?? "0") ?? 0
            let meetingStartTime = (Int(decimalOnly(meetingDictionary["start_time"] ?? "00:00:00")) ?? 0) / 100
            let formats = sharedFormatIDs.split(separator: ",").compactMap { UInt64($0) }.compactMap { inFormats[$0] }
            let physicalLocation = _convert(thisDataToAPhysicalLocation: meetingDictionary)
            let meeting = LGV_MeetingSDK_BMLT.Meeting(organization: organization, id: id, name: meetingName, weekdayIndex: weekdayIndex, meetingStartTime: meetingStartTime, formats: formats, physicalLocation: physicalLocation)
            ret.append(meeting)
        }
        
        return ret
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
        if let main_object = try? JSONSerialization.jsonObject(with: inData, options: []) as? [String: [[String: String]]],
           let meetingsObject = main_object["meetings"],
           let formatsObject = main_object["formats"] {
            let formats = _convert(theseFormats: formatsObject)
            let meetingData = LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: _convert(theseMeetings: meetingsObject, andTheseFormats: formats))
            
            if false { // !meetingData.meetings.isEmpty {
//                let geocoder = CLGeocoder()
//                var currentMeetingIndex: Int = 0
//                meetingData.meetings.forEach { _ in
//                    let meeting = meetingData.meetings[currentMeetingIndex]
//                    if let coords = meeting.physicalLocation?.coords {
//                        geocoder.reverseGeocodeLocation(CLLocation(latitude: coords.latitude, longitude: coords.longitude)) {(_ inPlaceMarks: [CLPlacemark]?, _ inError: Error?) in
//                            if currentMeetingIndex >= meetingData.meetings.count {
//                                inCompletion(meetingData, nil)
//                            } else if let timeZone = inPlaceMarks?[0].timeZone,
//                                      var postalAddress = meeting.physicalLocation?.postalAddress,
//                                      let name = meeting.physicalLocation?.name,
//                                      let extraInfo = meeting.physicalLocation?.extraInfo {
//                                if let isoCountryCode = inPlaceMarks?[0].isoCountryCode {
//                                    let newPostalAddress = CNMutablePostalAddress()
//
//                                    newPostalAddress.street = postalAddress.street
//                                    newPostalAddress.subLocality = postalAddress.subLocality
//                                    newPostalAddress.city = postalAddress.city
//                                    newPostalAddress.subAdministrativeArea = postalAddress.subAdministrativeArea
//                                    newPostalAddress.state = postalAddress.state
//                                    newPostalAddress.postalCode = postalAddress.postalCode
//                                    newPostalAddress.country = postalAddress.country
//                                    newPostalAddress.isoCountryCode = isoCountryCode
//                                    meetingData.meetings[currentMeetingIndex].physicalLocation = LGV_MeetingSDK_BMLT.Meeting.PhysicalLocation(coords: coords, name: name, postalAddress: newPostalAddress, timeZone: timeZone, extraInfo: extraInfo)
//                                } else {
//                                    meetingData.meetings[currentMeetingIndex].physicalLocation = LGV_MeetingSDK_BMLT.Meeting.PhysicalLocation(coords: coords, name: name, postalAddress: postalAddress, timeZone: timeZone, extraInfo: extraInfo)
//                                }
//                            }
//                        }
//                    }
//                    currentMeetingIndex += 1
//                }
            } else {
                inCompletion(meetingData, nil)
            }
        }
    }
}
