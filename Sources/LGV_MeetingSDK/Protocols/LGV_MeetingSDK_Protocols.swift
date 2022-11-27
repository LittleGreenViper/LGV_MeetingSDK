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
 
 Version: 2.0.2
 */

import CoreLocation

/* ###################################################################################################################################### */
// MARK: - A Simple "Reference Context" Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, that describes a simple `extraInfo` String, allowing conformant types to store string information.
 */
public protocol LGV_MeetingSDK_RefCon_Protocol {
    /* ############################################################## */
    /**
     OPTIONAL - This allows the SDK to declare a "refcon" (reference context), attaching any data to the object.
     
     Reference contexts are an old pattern, and aren't used as much, these days, because of context-aware closures.
     However, they can be very useful. For instance, you can attach an enumeration, or UUID to a network call,
     and return all of the calls to the same closure, and the refcon can help to differentiate the various calls.
     */
    var refCon: Any? { get set }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_RefCon_Protocol {
    /* ############################################################## */
    /**
     Default is nil.
     */
    var refCon: Any? {
        get { nil }
        set { _ = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - A Simple "Extra Info" Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, that declares a simple `extraInfo` String, allowing conformant types to store string information.
 */
public protocol LGV_MeetingSDK_Additional_Info_Protocol {
    /* ############################################################## */
    /**
     OPTIONAL - This will return any "extra info," applied to the conformant instance.
     */
    var extraInfo: String { get set }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Additional_Info_Protocol {
    /* ############################################################## */
    /**
     Default is an empty String.
     */
    var extraInfo: String {
        get { "" }
        set { _ = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Parsed Meeting Search Information Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, containing a "found set" of meeting data.
 
 It is defined for a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
 */
public protocol LGV_MeetingSDK_Meeting_Data_Set_Protocol: AnyObject, LGV_MeetingSDK_Additional_Info_Protocol, LGV_MeetingSDK_RefCon_Protocol, CustomDebugStringConvertible {
    /* ############################################################## */
    /**
     REQUIRED - This is the search specification main search type.
     */
    var searchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints { get }
    
    /* ############################################################## */
    /**
     REQUIRED - This is the search specification additional filters.
     */
    var searchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> { get }
    
    /* ############################################################## */
    /**
     REQUIRED - This contains any found meetings. It may be empty (no meetings found).
     */
    var meetings: [LGV_MeetingSDK_Meeting_Protocol] { get set }
}

/* ###################################################################################################################################### */
// MARK: CustomDebugStringConvertible Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Meeting_Data_Set_Protocol {
    /* ############################################################## */
    /**
     CustomDebugStringConvertible Conformance
     */
    public var debugDescription: String {
        "\nLGV_MeetingSDK_Meeting_Data_Set_Protocol\n\textraInfo: \"" + extraInfo + "\"" +
        "\n\trefCon: " + String(describing: refCon) +
        "\n\tsearchType: " + searchType.debugDescription +
        "\n\tsearchRefinements: " + searchRefinements.debugDescription +
        "\n\tmeetings: " + meetings.debugDescription
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main Implementation Protocol -
/* ###################################################################################################################################### */
/**
 This defines the requirements for the main SDK instance.
 */
public protocol LGV_MeetingSDK_Protocol: LGV_MeetingSDK_RefCon_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The search organization. This needs to be the "transport" version of the organization.
     */
    var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { get }

    /* ################################################################## */
    /**
     REQUIRED - The "cached" last search. It may be nil (no last search cached).
     */
    var lastSearch: LGV_MeetingSDK_Meeting_Data_Set_Protocol? { get set }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This executes a meeting search.
     - Parameters:
        - type (OPTIONAL): The main search type. Default is none (whole set, or none).
        - refinements (OPTIONAL): a set of search filter refinements. Default is no constraints.
        - refCon (OPTIONAL): An arbitrary data attachment to the search. This will be returned in the search results set. Default is nil.
        - completion (REQUIRED): The completion closure. > Note: This may be called in any thread, and it is escaping (should capture arguments).
     */
    func meetingSearch(type: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                       refinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                       refCon: Any?,
                       completion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure)
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This executes a special "Find nearby meetings that I can attend" meeting search.
     - Parameters:
        - centerLongLat (REQUIRED): The longitude and latitude (in degrees), of the search center.
        - minimumNumberOfResults (OPTIONAL): The minimum number of results we require.
        - maxRadiusInMeters (OPTIONAL): The maximum radius of the search, in meters.
        - refinements (OPTIONAL): a set of search filter refinements.
        - refCon (OPTIONAL): An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion (REQUIRED): The completion closure. > Note: This may be called in any thread, and it is escaping (should capture arguments).
     */
    func findNextMeetingsSearch(centerLongLat: CLLocationCoordinate2D,
                                minimumNumberOfResults: UInt,
                                maxRadiusInMeters: CLLocationDistance,
                                refinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                                refCon: Any?,
                                completion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     Default runs, using the built-in organization->transport->initiator method.
     */
    func meetingSearch(type inType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints = .none,
                       refinements inRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                       refCon inRefCon: Any? = nil,
                       completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        organization?.transport?.initiator?.meetingSearch(type: inType, refinements: inRefinements, refCon: inRefCon, completion: inCompletion)
    }
    
    /* ################################################################## */
    /**
     WHAT'S ALL THIS, THEN?
     
     This method will be a bit complex, because, what we are doing, is successive auto radius calls, until a minimum number of aggregated results are found.
     
     Sounds like a standard auto radius call, eh? But there's a difference. This is a "Next Available Meetings" call. The result will be a series of meetings, sorted by weekday and time, then by distance, after now.
     
     The caller can specify refinements, like "Only look at meetings on weekdays, between 6PM and 9PM."
     
     The search will continue until the minimum number of search results has been found, or until all seven days have been exhausted. The caller can also specify a maximum radius.

     - default minimumNumberOfResults is 10
     - default maxRadiusInMeters is 10,000 Km
     - default refinements is an empty set
     - default refCon is nil
     */
    func findNextMeetingsSearch(centerLongLat inCenterLongLat: CLLocationCoordinate2D,
                                minimumNumberOfResults inMinimumNumberOfResults: UInt = 10,
                                maxRadiusInMeters inMaxRadiusInMeters: CLLocationDistance = 10000000,
                                refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = [],
                                refCon inRefCon: Any? = nil,
                                completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        var minResultCount = Int(inMinimumNumberOfResults)
        var currentWeekdayIndex = 0
        var aggregatedMeetings = [LGV_MeetingSDK_Meeting_Protocol]()
        var searchUnderWay = false

        /* ############################################################## */
        /**
         This is our own internal completion callback. We use this to aggregate the search results.
         
         > NOTE: I don't want to recurse, because I don't want long stack chains. We're calling a remote service, and it could be dicey. Instead, I will use a rather primitive loop.
         
         - parameter inData: The data returned from the search.
         - parameter inError: Any errors encountered (may be nil).
         */
        func searchCallback(_ inData: LGV_MeetingSDK_Meeting_Data_Set_Protocol?, _ inError: Error?) {
            searchUnderWay = false
            guard let meetings = inData?.meetings,
                !meetings.isEmpty
            else { return }
            minResultCount -= meetings.count
            currentWeekdayIndex += 1
            aggregatedMeetings.append(contentsOf: meetings)
        }
        
        // This sets us up for the current time and weekday.
        let todayWeekday = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let secondsSinceMidnightThisMorning = TimeInterval(Int(Date().timeIntervalSince(Calendar.current.startOfDay(for: Date()))))
        
        // Save the requested refinements for weekday and start time range. These can be empty arrays
        let weekdayRefinement = Array(inSearchRefinements.filter { $0.hashKey == "weekdays" })
        let startTimeRangeRefinement = Array(inSearchRefinements.filter { $0.hashKey == "startTimeRange" })
        // Now, remove them from our basic refinements.
        let baselineRefinements = inSearchRefinements.filter { $0.hashKey != "weekdays" && $0.hashKey != "startTimeRange" }
        
        // We build a "pool" of weekdays to search, starting from today's weekday, and extending for a week.
        // We will be searching only these weekdays. We won't worry about when the week starts in the calendar, but we will be going from today, on. It's an array, because order is important.
        var weekdayPool = [LGV_MeetingSDK_Meeting_Data_Set.Weekdays]()
        
        for index in todayWeekday...(todayWeekday + 6) {
            // If we have a weekday refinement, we only add weekdays that are in it.
            if let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: 0 < index ? (8 > index ? index : index - 7) : index + 7) {
                if !weekdayRefinement.isEmpty {
                    if case let .weekdays(weekdayArray) = weekdayRefinement[0],
                       weekdayArray.contains(weekday) {
                        weekdayPool.append(weekday)
                    }
                } else {    // Otherwise, we add all seven weekdays.
                    weekdayPool.append(weekday)
                }
            }
        }
        
        if !weekdayPool.isEmpty {
            var eachDayTimeRange = TimeInterval(0)...TimeInterval(86399)
            var firstDayTimeRange = eachDayTimeRange
            
            if let startTimeRange = startTimeRangeRefinement.first {
                if case let .startTimeRange(startTimeRangeVal) = startTimeRange {
                    eachDayTimeRange = startTimeRangeVal
                    if todayWeekday == weekdayPool[0].rawValue {    // If we are starting today, we may need to clamp the range.
                        firstDayTimeRange = (max(eachDayTimeRange.lowerBound, secondsSinceMidnightThisMorning)...eachDayTimeRange.upperBound)
                    }
                }
            }
            
            var currentTimeRange = firstDayTimeRange
            
            while 0 < minResultCount,
                  currentWeekdayIndex < weekdayPool.count {
                let searchType = LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints.autoRadius(centerLongLat: inCenterLongLat, minimumNumberOfResults: inMinimumNumberOfResults, maxRadiusInMeters: inMaxRadiusInMeters)
                // Each sweep adds the next weekday in our list.
                var refinements = baselineRefinements.union([LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements.weekdays([weekdayPool[currentWeekdayIndex]])])
                if 0 < currentTimeRange.lowerBound || 86399 > currentTimeRange.upperBound {    // We don't specify a time range, at all, if we never specified a constrained one.
                    refinements = refinements.union([LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements.startTimeRange(currentTimeRange)])
                }
                
                currentTimeRange = eachDayTimeRange
                
                if !searchUnderWay {
                    searchUnderWay = true
                    meetingSearch(type: searchType, refinements: refinements, refCon: inRefCon, completion: searchCallback)
                }
            }
            
            aggregatedMeetings = aggregatedMeetings.sorted { a, b in
                guard a.weekdayIndex == b.weekdayIndex, // If the weekdays aren't the same, then no further sorting.
                      let aStartTime = a.startTimeInSeconds,
                      let bStartTime = b.startTimeInSeconds
                else { return false }

                guard aStartTime == bStartTime else { return aStartTime < bStartTime }
                
                return a.distanceInMeters < b.distanceInMeters
            }
        }
        
        inCompletion(LGV_MeetingSDK_Meeting_Data_Set(searchType: .nextMeetings(centerLongLat: inCenterLongLat, minimumNumberOfResults: inMinimumNumberOfResults, maxRadiusInMeters: inMaxRadiusInMeters), searchRefinements: inSearchRefinements, meetings: aggregatedMeetings), nil)
    }
}
