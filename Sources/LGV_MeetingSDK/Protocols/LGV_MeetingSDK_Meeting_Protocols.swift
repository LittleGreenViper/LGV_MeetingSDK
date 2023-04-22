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

import CoreLocation // For physical venues.
import Contacts     // For the postal address

/* ###################################################################################################################################### */
// MARK: - Date Extension -
/* ###################################################################################################################################### */
/**
 This extension allows us to convert a date to a certain time zone.
 */
fileprivate extension Date {
    /* ################################################################## */
    /**
     Convert a date between two timezones.
     
     Inspired by [this SO answer](https://stackoverflow.com/a/54064820/879365)
     
     - parameter from: The source timezone.
     - paremeter to: The destination timezone.
     
     - returns: The converted date
     */
    func convert(from inFromTimeZone: TimeZone, to inToTimeZone: TimeZone) -> Date { addingTimeInterval(TimeInterval(inFromTimeZone.secondsFromGMT(for: self) - inToTimeZone.secondsFromGMT(for: self))) }
}

/* ###################################################################################################################################### */
// MARK: - Enum for the Meeting Venue -
/* ###################################################################################################################################### */
/**
 Each meeting is either in-person (has a physical location), virtual-only (no physical location), or hybrid (both).
 */
public enum LGV_MeetingSDK_VenueType_Enum: String {
    /* ################################################################## */
    /**
     There is no valid venue (the meeting is not valid).
     */
    case invalid
    
    /* ################################################################## */
    /**
     There is no physical location associated with this meeting.
     */
    case virtualOnly
    
    /* ################################################################## */
    /**
     There is only a physical location associated with this meeting.
     */
    case inPersonOnly
    
    /* ################################################################## */
    /**
     There are both a physical location, and a virtual venue, associated with this meeting.
     */
    case hybrid
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Format Object -
/* ###################################################################################################################################### */
/**
 Each meeting may have a list of associated formats, describing details about the meeting.
 */
public protocol LGV_MeetingSDK_Format_Protocol: LGV_MeetingSDK_RefCon_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The Integer ID for this format.
     This must be unique within the context of the Meeting Instance.
     */
    var id: UInt64 { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The key for this format.
     This must be unique within the context of the Meeting Instance.
     */
    var key: String { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The name for this format (a short descriptive string).
     */
    var name: String { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The longer description for this format.
     */
    var description: String { get }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Meeting's Physical Component -
/* ###################################################################################################################################### */
/**
 This defines the meeting's physical location component.
 */
public protocol LGV_MeetingSDK_Meeting_Physical_Protocol: LGV_MeetingSDK_Additional_Info_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The coordinates for the meeting.
     */
    var coords: CLLocationCoordinate2D { get }

    /* ################################################################## */
    /**
     REQUIRED - A name for the location.
     */
    var name: String { get }

    /* ################################################################## */
    /**
     REQUIRED - The location is stored as a standard postal address.
     */
    var postalAddress: CNPostalAddress? { get }

    /* ################################################################## */
    /**
     REQUIRED - The time zone.
     */
    var timeZone: TimeZone { get }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Single Venue, in A Meeting's Virtual Component -
/* ###################################################################################################################################### */
/**
 This is one of the venues in a virtual meeting specifier.
 */
public protocol LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol: LGV_MeetingSDK_Additional_Info_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This describes the meeting venue (i.e. "Video," "Zoom," "Audio-Only," "Phone," etc.).
     */
    var description: String { get }

    /* ################################################################## */
    /**
     REQUIRED - The local timezone for the meeting.
     
     > Note: It is important to implement this, if the meeting is held in a particular timezone, and does not have a physical placemark!
     */
    var timeZone: TimeZone? { get }

    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a URI, that is available here.
     */
    var url: URL? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a separate meeting ID, that is available here, as a String.
     */
    var meetingID: String? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a separate meeting password, that is available here, as a String.
     */
    var password: String? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var url: URL? { nil }
    
    /* ################################################################## */
    /**
     Default is nil.
     */
    var meetingID: String? { nil }
    
    /* ################################################################## */
    /**
     Default is nil.
     */
    var password: String? { nil }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Meeting's Virtual Component -
/* ###################################################################################################################################### */
/**
 This defines the meeting's virtual component (if any).
 */
public protocol LGV_MeetingSDK_Meeting_Virtual_Protocol: LGV_MeetingSDK_Additional_Info_Protocol {
    /* ################################################################## */
    /**
     OPTIONAL - If there is a video meeting associated, it is defined here. May be nil. This also applies to audio-only (not phone) meetings.
     */
    var videoMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If there is a phone meeting associated, it is defined here. May be nil.
     */
    var phoneMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Meeting_Virtual_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var videoMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { nil }
    
    /* ################################################################## */
    /**
     Default is nil.
     */
    var phoneMeeting: LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol? { nil }
}

/* ###################################################################################################################################### */
// MARK: - The Structure for the Time Information of a Meeting -
/* ###################################################################################################################################### */
/**
 This struct has all the various aspects of the meeting time.
 */
public struct LGV_MeetingSDK_Meeting_TimeInformation {
    /* ################################################################################################################################## */
    // MARK: Private Constants
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The number of seconds in one minute.
     */
    private static let _oneMinuteInSeconds = TimeInterval(60)
    
    /* ################################################################## */
    /**
     The number of seconds in one hour.
     */
    private static let _oneHourInSeconds = TimeInterval(_oneMinuteInSeconds * 60)
    
    /* ################################################################## */
    /**
     The number of seconds in one day.
     */
    private static let _oneDayInSeconds = TimeInterval(_oneHourInSeconds * 24)
    
    /* ################################################################## */
    /**
     The number of seconds in one week.
     */
    private static let _oneWeekInSeconds = TimeInterval(_oneDayInSeconds * 7)
    
    /* ################################################################################################################################## */
    // MARK: Private Caches
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The date, in the meeting's local tiomezone, of the next start.
     */
    private var _cachedNextStartDate: Date?
    
    /* ################################################################## */
    /**
     This is the meeting weekday (in the meeting's local timezone).
     */
    public let weekday: LGV_MeetingSDK_Meeting_Data_Set.Weekdays
    
    /* ################################################################## */
    /**
     This is the meeting start hour (0 - 24 Military time, in the meeting's local timezone).
     
     > NOTE: 00:00 is considered "midnight, this morning," and "24:00" is considered "midnight, tonight."
     */
    public let startHour: Int
    
    /* ################################################################## */
    /**
     This is the meeting start minute (Military time, in the meeting's local timezone).
     
     > NOTE: 00:00 is considered "midnight, this morning," and "24:00" is considered "midnight, tonight."
     */
    public let startMinute: Int
    
    /* ################################################################## */
    /**
     This is the duration of the meeting, in seconds.
     */
    public let durationInSeconds: TimeInterval
    
    /* ################################################################## */
    /**
     This is the timezone of the meeting. Default, is the user's current timezone.
     */
    public let timeZone: TimeZone
    
    /* ################################################################## */
    /**
     Main Initializer.
     
     - Parameters:
     - weekday: This is the meeting weekday (in the meeting's local timezone).
     - startHour: This is the meeting start hour (0 - 24 Military time, in the meeting's local timezone).
     - startMinute: This is the meeting start minute (Military time, in the meeting's local timezone).
     - durationInSeconds: This is the duration of the meeting, in seconds.
     - timeZone: This is the timezone of the meeting. Default, is the user's current timezone.
     */
    public init(weekday inWeekday: LGV_MeetingSDK_Meeting_Data_Set.Weekdays, startHour inStartHour: Int, startMinute inStartMinute: Int, durationInSeconds inDurationInSeconds: TimeInterval, timeZone inTimeZone: TimeZone = TimeZone.autoupdatingCurrent) {
        weekday = inWeekday
        startHour = inStartHour
        startMinute = inStartMinute
        durationInSeconds = inDurationInSeconds
        timeZone = inTimeZone
    }
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Meeting_TimeInformation {
    /* ################################################################## */
    /**
     The date components (weekday, hour, minute), from the meeting's native time zone.
     */
    public var dateComponents: DateComponents { DateComponents(calendar: .autoupdatingCurrent, hour: startHour, minute: startMinute, weekday: weekday.rawValue) }
}

/* ###################################################################################################################################### */
// MARK: Accessor Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Meeting_TimeInformation {
    /* ################################################################## */
    /**
     This is the start time of the next meeting, in the meeting's local timezone. The date will have the meeting's timezone set, so it will adjust to our local timezone.
     
     - parameter isAdjusted: If true (default is false), then the date will be converted to our local autoupdating timezone.
     - returns: The date of the next meeting.
     
     > NOTE: If the date is invalid, then the distant future will be returned.
     */
    public mutating func getNextStartDate(isAdjusted inAdjust: Bool = false) -> Date {
        guard nil == _cachedNextStartDate || _cachedNextStartDate! <= .now else { return _cachedNextStartDate! }
        _cachedNextStartDate = Calendar.autoupdatingCurrent.nextDate(after: .now, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)
        
        if inAdjust {
            return _cachedNextStartDate?.convert(from: timeZone, to: TimeZone.autoupdatingCurrent) ?? Date.distantFuture
        } else {
            return _cachedNextStartDate ?? Date.distantFuture
        }
    }
    
    /* ################################################################## */
    /**
     This is the start time of the previous meeting, in the meeting's local timezone. The date will have the meeting's timezone set, so it will adjust to our local timezone.
     
     - parameter isAdjusted: If true (default is false), then the date will be converted to our local autoupdating timezone.
     - returns: The date of the next meeting.

     > NOTE: If the date is invalid, then the distant future will be returned.
     */
    public mutating func getPreviousStartDate(isAdjusted inAdjust: Bool = false) -> Date {
        guard Date.distantFuture > getNextStartDate(isAdjusted: inAdjust) else { return Date.distantFuture }
        return getNextStartDate().addingTimeInterval(-Self._oneWeekInSeconds)
    }

    /* ################################################################## */
    /**
     This is the weekday index (as an Int), of the meeting's start time, in our local time.
     */
    public mutating func getWeekdayIndexInMyLocalTime() -> Int {
        let adjustedDate = getNextStartDate().convert(from: timeZone, to: TimeZone.autoupdatingCurrent)
        
        return Calendar.autoupdatingCurrent.component(.weekday, from: adjustedDate)
    }

    /* ################################################################## */
    /**
     This is the start hour of the meeting's start time, in our local time.
     */
    public mutating func getStartHourInMyLocalTime() -> Int {
        let adjustedDate = getNextStartDate().convert(from: timeZone, to: TimeZone.autoupdatingCurrent)
        
        return Calendar.autoupdatingCurrent.component(.hour, from: adjustedDate)
    }

    /* ################################################################## */
    /**
     This is the start hour of the meeting's start time, in our local time.
     */
    public mutating func getStartMinuteInMyLocalTime() -> Int {
        let adjustedDate = getNextStartDate().convert(from: timeZone, to: TimeZone.autoupdatingCurrent)
        
        return Calendar.autoupdatingCurrent.component(.minute, from: adjustedDate)
    }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Meeting Object -
/* ###################################################################################################################################### */
/**
 Each meeting instance will present itself as conforming to this protocol.
 */
public protocol LGV_MeetingSDK_Meeting_Protocol: AnyObject, LGV_MeetingSDK_Additional_Info_Protocol, LGV_MeetingSDK_AddressableEntity_Protocol, CustomDebugStringConvertible, Comparable {
    /* ################################################################## */
    /**
     REQUIRED - The meeting organization.
     */
    var organization: LGV_MeetingSDK_Organization_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED - Each meeting should have a unique (in the search domain) integer ID.
     
     > Note: This is positive, and 1-based. 0 is an error.
     */
    var id: UInt64 { get set }

    /* ################################################################## */
    /**
     REQUIRED - The repeating weekday for the meeting (1-based, with 1 being Sunday, and 7 being Saturday).
     
     If this is 0, then the meeting is considered to be a one-time event, and the `meetingStartTime` property should be ignored (`nextMeetingStartsOn` will have the start time and day).
     
     > Note: 1 is Sunday, regardless of the current region week start day.
     */
    var weekdayIndex: Int { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The start time of the meeting, as military time (HHMM). This only applies, if `(1...7).contains(weekday)`.
     
     > Note: 0 is midnight (this morning), and 2400 is midnight (tonight).
     
     A meeting that starts at midnight, on Friday night (which is actually, midnight, Saturday morning), would have a `weekday` of 6, and a `meetingStartTime` of 2400.
     
     If we wanted to say the meeting starts on Saturday morning, instead, we would make the `weekday` 7, and a `meetingStartTime` of 0.
     
     Most meetings will probably choose the 2400/previous day format, as that is more "natural" to people.
     
     The `nextMeetingStartsOn` property will have the absolute time, in any case.
     */
    var meetingStartTime: Int { get }
    
    /* ################################################################## */
    /**
     REQUIRED - If the meeting has a physical presence, this will have the location. Nil, if no physical location.
     
     > Note: If this is not provided, then `virtualMeetingInfo` should be provided.
     */
    var physicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol? { get set }

    /* ################################################################## */
    /**
     REQUIRED - If the meeting has a virtual presence, this will have that information. Nil, if no virtual meeting.
     
     > Note: If this is not provided, then `physicalLocation` should be provided.
     */
    var virtualMeetingInfo: LGV_MeetingSDK_Meeting_Virtual_Protocol? { get set }

    /* ################################################################## */
    /**
     REQUIRED - If the meeting has formats, then this contains a list of them. Empty, if no formats.
     */
    var formats: [LGV_MeetingSDK_Format_Protocol] { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The local timezone of the meeting.
     
     > Note: This may not be useful, if the meeting does not have a timezone.
     */
    var meetingLocalTimezone: TimeZone { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The various time aspects of the meeting.
     */
    var timeInformation: LGV_MeetingSDK_Meeting_TimeInformation? { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The meeting venue type.
     */
    var meetingType: LGV_MeetingSDK_VenueType_Enum { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - Returns an optional DateComponents object, with the time of the meeting. Nil, if one-time event.
     
     > Note: This will not allow "2400" to be indicative of midnight. 23:59:59 is returned, if the meeting specifies "2400."
     */
    var startTime: DateComponents? { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - Returns an optional DateComponents object, with the weekday and time of the meeting. Nil, if one-time event.
     */
    var startTimeAndDay: DateComponents? { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The start time, in seconds.
     */
    var startTimeInSeconds: TimeInterval? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The duration in minutes.
     */
    var durationInMinutes: Int { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The weekday, adjusted for the start of week.
     */
    var adjustedWeekdayIndex: Int { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - A direct accessor for the physical location coordinates.
     
     > Note: Virtual-only meetings may either have no coords, or may return an invalid coordinate.
     */
    var locationCoords: CLLocationCoordinate2D? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The local start time of the meeting.
     
     > Note: This may not be useful, if the meeting does not have a timezone. In tat case, it will return nil.
     */
    var localStartTime: Date? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This gives a "summarized" location. If the meeting is virtual-only, this will be nil.
     */
    var simpleLocationText: String? { get }

    /* ################################################################## */
    /**
     OPTIONAL - The next meeting (from now) will start on this date (time).
     
     If this is a one-time event, then this will be the only indicator of the meeting start time/date.
     
     In normal weekly meetings, this should not need to be implemented.
     */
    var nextStartDate: Date? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The name for this meeting.
     */
    var name: String { get }

    /* ################################################################## */
    /**
     OPTIONAL - The distance of this meetings from the search.
     */
    var distanceInMeters: CLLocationDistance { get set }

    /* ################################################################## */
    /**
     OPTIONAL - The duration of the meeting, in seconds.
     */
    var meetingDuration: TimeInterval { get }

    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has comments associated, they will be here, as a String. Empty, if no comments.
     */
    var comments: String { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a URI (not a virtual meeting URI -for example, a Group Web site), that is available here.
     */
    var meetingURI: URL? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Meeting_Protocol {
    /* ################################################################## */
    /**
     CustomDebugStringConvertible Conformance
     */
    var debugDescription: String { "Meeting Type: \(meetingType.rawValue), startTimeAndDay: \(startTimeAndDay?.debugDescription ?? "No Start Time And Day"),"
                                    + " location: \(locationCoords.debugDescription), location text: \(simpleLocationText ?? "No Location Text"), duration in minutes: \(durationInMinutes)" }

    /* ################################################################## */
    /**
     Default figures out the meeting type, based on what venues are available.
     */
    var meetingType: LGV_MeetingSDK_VenueType_Enum {
        let hasPhysicalLocation = nil != physicalLocation && nil != physicalLocation?.postalAddress && !(physicalLocation?.postalAddress?.street ?? "").isEmpty
        if hasPhysicalLocation,
           nil != virtualMeetingInfo {
            return .hybrid
        } else if hasPhysicalLocation {
            return .inPersonOnly
        } else if nil != virtualMeetingInfo {
            return .virtualOnly
        }
        
        return .invalid
    }
    
    /* ################################################################## */
    /**
     Default returns an optional DateComponents object, with the time of the meeting. This will not allow "2400" to be indicative of midnight. 23:59:59 is returned, if the meeting specifies "2400."
     */
    var startTime: DateComponents? {
        guard (0...2400).contains(meetingStartTime) else { return nil }
        
        guard 2400 != meetingStartTime else { return DateComponents(hour: 23, minute: 59, second: 59, nanosecond: 999999999) }
        
        let hour = Int(meetingStartTime / 100)
        let minute = Int(meetingStartTime - (hour * 100))

        return DateComponents(hour: hour, minute: minute)
    }

    /* ################################################################## */
    /**
     Default returns an optional DateComponents object, with the weekday and time of the meeting. Returns nil, if the meeting weekday and/or start time is invalid.
     */
    var startTimeAndDay: DateComponents? {
        let startTime = meetingStartTime
        
        guard (1...7).contains(weekdayIndex),
              (0...2400).contains(startTime)
        else { return nil }
        
        var hour = Int(startTime / 100)
        let minute = Int(startTime - (hour * 100))
        var weekdayIndex = weekdayIndex

        // Special case for "tonight midnight."
        if (24 == hour) && (0 == minute) {
            weekdayIndex = 7 == weekdayIndex ? 1 : weekdayIndex + 1
            hour = 0
        }

        return DateComponents(hour: hour, minute: minute, weekday: weekdayIndex)
    }

    /* ################################################################## */
    /**
     Default simply calculates the start time from the components of the military time.
     */
    var startTimeInSeconds: TimeInterval? {
        var components: DateComponents? = startTime
        
        if nil == components,
           let startDate = nextStartDate {
            components = Calendar.current.dateComponents([.hour, .minute], from: startDate)
        }
        
        let hour = components?.hour ?? -1
        let minute = components?.minute ?? -1
        
        let startTime = (hour * 100) + minute
        
        if (0...2400).contains(startTime) {
            return TimeInterval((hour * 60 * 60) + (minute * 60))
        }
        
        return nil
    }

    /* ################################################################## */
    /**
     Default mines the physical location for a postal address, and uses that.
     */
    var simpleLocationText: String? {
        guard let postalAddress = physicalLocation?.postalAddress,
              !postalAddress.street.isEmpty,
              !postalAddress.city.isEmpty,
              !postalAddress.state.isEmpty
        else { return nil }
        
        var ret = postalAddress.street + " " + postalAddress.city + " " + postalAddress.state
        
        if !postalAddress.postalCode.isEmpty {
            ret += " " + postalAddress.postalCode
        }
        
        if let venueName = physicalLocation?.name {
            ret = venueName + " " + ret
        }

        return ret
    }

    /* ################################################################## */
    /**
     By default, this calculates and returns the date of a repeating weekly meeting, and returns the next time the meeting will gather, after now.
     
     If the meeting is not a recurring weekly meeting, this should be implemented by the conforming class.
     */
    var nextStartDate: Date? {
        if let weekday = startTimeAndDay?.weekday,
           let startHour = startTimeAndDay?.hour,
           let startMinute = startTimeAndDay?.minute,
           (1...7).contains(weekday) {
            let now = Date.now
            let todaysWeekday = Calendar.autoupdatingCurrent.component(.weekday, from: now)
            let todaysMonthDay = Calendar.autoupdatingCurrent.component(.day, from: now)
            let todaysMonth = Calendar.autoupdatingCurrent.component(.month, from: now)
            let todaysYear = Calendar.autoupdatingCurrent.component(.year, from: now)
            let dayDifference = 0 <= (weekday - todaysWeekday) ? weekday - todaysWeekday : (weekday + 7) - todaysWeekday
            let newMonthDay = todaysMonthDay + dayDifference    // The date calculator will take care of date overflows.
            return Calendar.autoupdatingCurrent.date(from: DateComponents(year: todaysYear, month: todaysMonth, day: newMonthDay, hour: startHour, minute: startMinute))
        }
                                         
        return nil
// The above replaces this, which I found very slow, and rather problematic
//        guard let startTimeAndDay = startTimeAndDay else { return nil }
//        return Calendar.autoupdatingCurrent.nextDate(after: .now, matching: startTimeAndDay, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .last, direction: .forward)
    }
    
    /* ################################################################## */
    /**
     Default simply divides the seconds duration into minutes.
     */
    var durationInMinutes: Int { Int(meetingDuration / 60) }
    
    /* ################################################################## */
    /**
     Default returns the adjusted weekday. Note that this should only be used, when accounting for different week starts.
     */
    var adjustedWeekdayIndex: Int {
        var weekdayIndex = self.weekdayIndex - Calendar.current.firstWeekday
        
        if 0 > weekdayIndex {
            weekdayIndex += 7
        }
        
        return weekdayIndex
    }
    
    /* ################################################################## */
    /**
     Default gets the coordinates from the physical location. May be nil, or an invalid location.
     */
    var locationCoords: CLLocationCoordinate2D? { physicalLocation?.coords }

    /* ################################################################## */
    /**
     Default tries to adjust the next start Time to our local time.
     */
    var localStartTime: Date? {
        guard let startTime = nextStartDate else { return nil }
        let localTimeZone = meetingLocalTimezone
        return startTime.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT() - localTimeZone.secondsFromGMT()))
    }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The local timezone of the meeting.
     
     > Note: This may not be useful, if the meeting does not have a timezone.
     */
    var meetingLocalTimezone: TimeZone {
        return .autoupdatingCurrent
    }

    /* ################################################################## */
    /**
     Default is an empty String.
     */
    var name: String { "" }
    
    /* ################################################################## */
    /**
     Default is maximum value of the float.
     */
    var distanceInMeters: CLLocationDistance { Double.greatestFiniteMagnitude }

    /* ################################################################## */
    /**
     Default is 0
     */
    var meetingDuration: TimeInterval { 0 }

    /* ################################################################## */
    /**
     Default is an Empty String
     */
    var comments: String { "" }
    
    /* ################################################################## */
    /**
     Default is Nil
     */
    var meetingURI: URL? { nil }
}
