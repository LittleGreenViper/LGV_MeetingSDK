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
// MARK: - BMLT Transport Extension -
/* ###################################################################################################################################### */
/**
 This adds methods to the transport class.
 */
public extension LGV_MeetingSDK_BMLT.Transport {
    /* ################################################################## */
    /**
     Creates a URL Request, for the given search parameters.
     - Parameters:
        - type: Any search type that was specified.
        - refinements: Any search refinements.
     
     - returns: A new URL Request object, ready for a task.
     */
    func ceateURLRequest(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                         refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>
    ) -> URLRequest? {
        guard var urlString = baseURL?.absoluteString else { return nil }

        let dataFields = ["id_bigint",
                          "weekday_tinyint",
                          "start_time",
                          "duration_time",
                          "formats",
                          "format_shared_id_list",
                          "longitude",
                          "latitude",
                          "distance_in_km",
                          "distance_in_miles",
                          "meeting_name",
                          "location_text",
                          "location_info",
                          "location_street",
                          "location_city_subsection",
                          "location_neighborhood",
                          "location_municipality",
                          "location_sub_province",
                          "location_province",
                          "location_postal_code_1",
                          "location_nation",
                          "comments",
                          "virtual_meeting_link",
                          "phone_meeting_number",
                          "virtual_meeting_additional_info",
                          "service_body_bigint"
        ]

        urlString += "/client_interface/json?callingApp=LGV_MeetingSDK_BMLT&switcher=GetSearchResults&get_used_formats=1&lang_enum=\(String(Locale.preferredLanguages[0].prefix(2)))&data_field_key=\(dataFields.joined(separator: ","))"
        
        switch inSearchType {
        case .none:
            break
            
        case .fixedRadius(let centerLongLat, let radiusInMeters):
            urlString += "&geo_width_km=\(radiusInMeters / 1000)&long_val=\(centerLongLat.longitude)&lat_val=\(centerLongLat.latitude)"
            
        case .autoRadius(let centerLongLat, let minimumNumberOfResults, _):
            urlString += "&geo_width=\(-Int(minimumNumberOfResults))&long_val=\(centerLongLat.longitude)&lat_val=\(centerLongLat.latitude)"

        case .meetingID(let idArray):
            urlString += "&SearchString=\(idArray.compactMap({String($0)}).joined(separator: ","))"
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        #if DEBUG
            print("URL Request Created for: \(url.absoluteString)")
        #endif
        
        let urlRequest = URLRequest(url: url)
        
        return urlRequest
    }
}
