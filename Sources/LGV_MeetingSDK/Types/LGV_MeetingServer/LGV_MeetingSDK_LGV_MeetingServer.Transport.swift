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
public extension LGV_MeetingSDK_LGV_MeetingServer.Transport {
    /* ################################################################## */
    /**
     This prepares the "baseline" URL string for the request.
     */
    var preparedURLString: String {
        guard var urlString = baseURL?.absoluteString else { return "" }
        urlString += "?query"
        
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
        /* ############################################################## */
        /**
         Unwinds the "composite" IDs that we use, into the "aggregate" ones, used by the server.
         
         The first 20 bits are the server ID, and the second 44 bits, are the meeting ID.
         
         - returns: An Array of tuples, containing the bifurcated IDs.
         */
        func unwindIDArray(_ inIDArray: [UInt64]) -> [(Int, Int)] {
            inIDArray.map {
                let serverID = Int($0 >> 44)
                let meetingID = Int($0 & 0x00000FFFFFFFFFFF)
                return (serverID, meetingID)
            }
        }
        
        var urlString = preparedURLString
        
        guard !urlString.isEmpty else { return nil }
        
        switch inSearchType {
        case .fixedRadius(let centerLongLat, let radiusInMeters):
            urlString += "&geo_radius=\(radiusInMeters / 1000)&geocenter_lng=\(centerLongLat.longitude)&geocenter_lat=\(centerLongLat.latitude)"
            
        case .autoRadius(let centerLongLat, let minimumNumberOfResults, let maximumRadiusInMeters):
            urlString += "&minimum_found=\(Int(minimumNumberOfResults))&geocenter_lng=\(centerLongLat.longitude)&geocenter_lat=\(centerLongLat.latitude)"

            if 0 < maximumRadiusInMeters {
                urlString += "&geo_radius=\(maximumRadiusInMeters / 1000)"
            }
        
        case .meetingID(let idArray):
            let compositeArray = unwindIDArray(idArray)
            urlString += "&ids=\(compositeArray.map({String(format: "(%d,%d)", $0.0, $0.1)}).joined(separator: ","))"

        default:
            break
        }
        
        // These refinements can actually affect the query string.
        inSearchRefinements.forEach { refinement in
            switch refinement {
            case .weekdays(let weekdays):
                if !weekdays.isEmpty {
                    urlString += "&weekdays=\(weekdays.map({String($0.rawValue)}).joined(separator: ","))"
                }

            case .startTimeRange(let range):
                // This makes sure the range is correct.
                guard (range.lowerBound...range.upperBound).clamped(to: (0.0...86399)) == (range.lowerBound...range.upperBound) else { break }
                
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
                
                let startTime = (beginHours * 3600) + (beginMinutes * 60)
                // If we are at zero, then there's no need to have a start to the range.
                if (1..<86400).contains(startTime) {
                    urlString += "&start_time=\(startTime)"
                }
                
                let endTimeRaw = Int(range.upperBound)
                // We add one to the end, as well (same reason). We clamp at 2359.
                var endHours = Int(endTimeRaw / 3600)
                var endMinutes = Int(endTimeRaw / 60) - (endHours * 60)
                
                endMinutes += 1
                
                if 59 < endMinutes {
                    endMinutes = 0
                    endHours += 1
                    
                    if 23 < endHours {
                        endHours = 23
                        endMinutes = 59
                    }
                }
                
                let endTime = (endHours * 3600) + (endMinutes * 60)
                if (startTime..<86400).contains(endTime) {
                    urlString += "&end_time=\(endTime)"
                }

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
