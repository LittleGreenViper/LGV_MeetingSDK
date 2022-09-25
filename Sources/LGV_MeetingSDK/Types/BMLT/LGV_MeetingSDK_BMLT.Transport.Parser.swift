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

import Foundation

/* ###################################################################################################################################### */
// MARK: - Meeting Struct -
/* ###################################################################################################################################### */
/**
 */
public struct LGV_MeetingSDK_BMLT_Meeting: LGV_MeetingSDK_Meeting_Protocol {
    /* ################################################################## */
    /**
     */
    public weak var organization: LGV_MeetingSDK_Organization_Protocol?
    
    /* ################################################################## */
    /**
     */
    public let id: UInt64
    
    /* ################################################################## */
    /**
     */
    public let name: String
    
    /* ################################################################## */
    /**
     */
    public let formats: [LGV_MeetingSDK_Format_Protocol]
}

/* ###################################################################################################################################### */
// MARK: - Format Struct -
/* ###################################################################################################################################### */
/**
 */
public struct LGV_MeetingSDK_BMLT_Format: LGV_MeetingSDK_Format_Protocol {
    /* ################################################################## */
    /**
     */
    public var id: UInt64
    
    /* ################################################################## */
    /**
     */
    public var key: String
    
    /* ################################################################## */
    /**
     */
    public var name: String
    
    /* ################################################################## */
    /**
     */
    public var description: String
}

/* ###################################################################################################################################### */
// MARK: - BMLT Parser Extension -
/* ###################################################################################################################################### */
/**
 This adds methods to the parser struct.
 */
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
            let format = LGV_MeetingSDK_BMLT_Format(id: id, key: key, name: name, description: description)
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
        var ret = [LGV_MeetingSDK_Meeting_Protocol]()
        
        guard let organization = initiator?.transport?.organization else { return [] }
        
        inJSONParsedMeetings.forEach { meetingDictionary in
            guard let str = meetingDictionary["id_bigint"],
                  let sharedFormatIDs = meetingDictionary["format_shared_id_list"],
                  let id = UInt64(str)
            else { return }
            let meetingName = meetingDictionary["meeting_name"] ?? "NA Meeting"
            let formats = sharedFormatIDs.split(separator: ",").compactMap { UInt64($0) }.compactMap { inFormats[$0] }
            let meeting = LGV_MeetingSDK_BMLT_Meeting(organization: organization, id: id, name: meetingName, formats: formats)
            ret.append(meeting)
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - parameter searchType (OPTIONAL): This is the search specification main search type. Default is .none.
     - parameter searchRefinements (OPTIONAL): This is the search specification additional filters. Default is .none.
     - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
     
     - returns: An empty parse set
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                          searchRefinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                          data inData: Data) -> LGV_MeetingSDK_Meeting_Data_Set_Protocol {
        if let main_object = try? JSONSerialization.jsonObject(with: inData, options: []) as? [String: [[String: String]]],
           let meetingsObject = main_object["meetings"],
           let formatsObject = main_object["formats"] {
            let formats = _convert(theseFormats: formatsObject)
            return LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements, meetings: _convert(theseMeetings: meetingsObject, andTheseFormats: formats))
        }
        
        return LGV_MeetingSDK_Meeting_Data_Set()
    }
}
