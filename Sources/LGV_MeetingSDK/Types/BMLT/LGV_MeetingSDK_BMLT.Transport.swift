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
     These are the specific fields that we request. It shortens the response.
     */
    private static let _dataFields = ["comments",
                                      "duration_time",
                                      "format_shared_id_list",
                                      "id_bigint",
                                      "lang_enum",
                                      "latitude",
                                      "location_city_subsection",
                                      "location_info",
                                      "location_municipality",
                                      "location_nation",
                                      "location_neighborhood",
                                      "location_postal_code_1",
                                      "location_province",
                                      "location_street",
                                      "location_sub_province",
                                      "location_text",
                                      "longitude",
                                      "meeting_name",
                                      "phone_meeting_number",
                                      "service_body_bigint",
                                      "start_time",
                                      "time_zone",
                                      "venue_type",
                                      "virtual_meeting_additional_info",
                                      "virtual_meeting_link",
                                      "weekday_tinyint"
    ]
    
    /* ################################################################## */
    /**
     This prepares the "baseline" URL string for the request.
     */
    var preparedURLString: String {
        guard var urlString = baseURL?.absoluteString else { return "" }
        urlString += "/client_interface/json?callingApp=LGV_MeetingSDK_BMLT&switcher=GetSearchResults&get_used_formats=1&lang_enum=\(String(Locale.preferredLanguages[0].prefix(2)))&data_field_key=\(Self._dataFields.joined(separator: ","))"
        
        return urlString
    }
    
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
        var urlString = preparedURLString
        
        guard !urlString.isEmpty else { return nil }
        
        switch inSearchType {
        case .fixedRadius(let centerLongLat, let radiusInMeters):
            let maxRadius = (0.0..<40008000).contains(radiusInMeters) ? radiusInMeters : 0
            urlString += "&geo_width_km=\(maxRadius / 1000)&long_val=\(centerLongLat.longitude)&lat_val=\(centerLongLat.latitude)"
            
        case .autoRadius(let centerLongLat, let minimumNumberOfResults, _):
            urlString += "&geo_width=\(-Int(minimumNumberOfResults))&long_val=\(centerLongLat.longitude)&lat_val=\(centerLongLat.latitude)"

        case .meetingID(let idArray):
            urlString += "&SearchString=\(idArray.compactMap({String($0)}).joined(separator: ","))"
            
        default:
            break
        }
        
        // These refinements can actually affect the query string.
        inSearchRefinements.forEach { refinement in
            switch refinement {
            case .weekdays(let weekdays):
                weekdays.forEach { weekday in
                    urlString += "&weekdays\(1 < weekdays.count ? "[]" : "")=\(weekday.rawValue)"
                }

            case .startTimeRange(let range):
                // This makes sure the range is correct.
                guard (range.lowerBound...range.upperBound).clamped(to: (0.0...86399.0)) == (range.lowerBound...range.upperBound) else { break }
                
                let startTimeRaw = Int(range.lowerBound)
                
                var beginHours = Int(startTimeRaw / 3600)
                var beginMinutes = Int(startTimeRaw / 60) - (beginHours * 60)
                
                // We subtract one minute, because the comparison is not inclusive.
                beginMinutes -= 1
                
                if 0 > beginMinutes {
                    beginMinutes = 59
                    beginHours -= 1
                    
                    if 0 > beginHours {
                        beginMinutes = 0
                        beginHours = 0
                    }
                }
                
                // If we are at zero, then there's no need to have a start to the range.
                if 0 < beginMinutes || 0 < beginHours {
                    urlString += "&StartsAfterH=\(beginHours)&StartsAfterM=\(beginMinutes)"
                }
                
                // We add one to the end, as well (same reason). We clamp at 2359.
                var endHours = Int(range.upperBound / 3600)
                var endMinutes = Int(startTimeRaw / 60) - (beginHours * 60)

                endMinutes += 1
                
                if 59 < endMinutes {
                    endMinutes = 0
                    endHours += 1
                    
                    if 23 < endHours {
                        endHours = 23
                        endMinutes = 59
                    }
                }
                
                urlString += "&StartsBeforeH=\(endHours)&StartsBeforeM=\(endMinutes)"
                
            default:
                break
            }
        }
        
        guard let url = URL(string: urlString) else { return nil }
        
        #if DEBUG
            print("URL Request: \(urlString)")
        #endif
        
        return URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    }
}
