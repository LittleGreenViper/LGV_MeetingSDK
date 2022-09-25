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
     REQUIRED - The key for this format.
     This must be unique within the context of the Meeting Instance.
     */
    var formatKey: String { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The name for this format (a short descriptive string).
     */
    var formatName: String { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The longer description for this format.
     */
    var formatDescription: String { get }
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
     REQUIRED - The location is stored as a standard placemark.
     
     **NOTE:** This should specify the [`timeZone`](https://developer.apple.com/documentation/corelocation/clplacemark/1423707-timezone) property!.
     */
    var placemark: CLPlacemark { get }

    /* ################################################################## */
    /**
     OPTIONAL - This is a direct accessor for the location (degrees Long/Lat, altitude, etc.). May be nil.
     */
    var location: CLLocation? { get }

    /* ################################################################## */
    /**
     OPTIONAL - This is a direct accessor for the coordinates (degrees Long/Lat). Nil, if no coordinates (address only).
     */
    var coordinate: CLLocationCoordinate2D? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Meeting_Physical_Protocol {
    /* ################################################################## */
    /**
     The default returns the location directly from the placemark.
     */
    var location: CLLocation? { placemark.location }

    /* ################################################################## */
    /**
     The default returns the coordinates directly from the placemark location.
     */
    var coordinate: CLLocationCoordinate2D? { location?.coordinate }
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
     
     **NOTE:** It is important to implement this, if the meeting is held in a particular timezone, and does not have a physical placemark!
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
// MARK: - The Structure of a Meeting Object -
/* ###################################################################################################################################### */
/**
 Each meeting instance will present itself as conforming to this protocol.
 */
public protocol LGV_MeetingSDK_Meeting_Protocol: LGV_MeetingSDK_Additional_Info_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The meeting organization.
     */
    var organization: LGV_MeetingSDK_Organization_Protocol { get }
    
    /* ################################################################## */
    /**
     REQUIRED - Each meeting should have a unique (in the search domain) integer ID.
     
     **NOTE:** This is positive, and 1-based. 0 is an error.
     */
    var id: UInt64 { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The meeting venue type.
     */
    var meetingType: LGV_MeetingSDK_VenueType_Enum { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - Returns an optional DateComponents object, with the time of the meeting. Nil, if one-time event.
     
     **NOTE:** This will not allow "2400" to be indicative of midnight. 2359 is the max.
     */
    var startTime: DateComponents? { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - Returns an optional DateComponents object, with the weekday and time of the meeting. Nil, if one-time event.
     */
    var startTimeAndDay: DateComponents? { get }
    
    /* ################################################################## */
    /**
     - returns: returns an integer that allows sorting quickly. Weekday is 1,000s, hours are 100s, and minutes are 1s.
     **NOTE:** This value reflects the localized start day of the week (the others do not). This is because the reason for this value is for sorting.
     That means that if the week starts on Monday, then the weekday index will be 1 if the meeting is on Monday, and 7 if on Sunday.
     */
    var timeDayAsInteger: Int { get }

    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This is false, if the combination of meeting values does not represent a valid meeting.
     */
    var isValid: Bool { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The local timezone of the meeting.
     */
    var meetingLocalTimezone: TimeZone { get }

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
     **NOTE:** Virtual-only meetings may either have no coords, or may return an invalid coordinate.
     */
    var locationCoords: CLLocationCoordinate2D? { get }

    /* ################################################################## */
    /**
     OPTIONAL -. The next meeting (from now) will start on this date (time).
     
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
     OPTIONAL - The repeating weekday for the meeting (1-based, with 1 being Sunday, and 7 being Saturday).
     
     If this is 0, then the meeting is considered to be a one-time event, and the `meetingStartTime` property should be ignored (`nextMeetingStartsOn` will have the start time and day).
     
     **NOTE:** 1 is Sunday, regardless of the current region week start day.
     */
    var weekdayIndex: Int { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The start time of the meeting, as military time (HHMM). This only applies, if `(1...7).contains(weekday)`.
     
     **NOTE:** 0 is midnight (this morning), and 2400 is midnight (tonight).
     
     A meeting that starts at midnight, on Friday night (which is actually, midnight, Saturday morning), would have a `weekday` of 6, and a `meetingStartTime` of 2400.
     
     If we wanted to say the meeting starts on Saturday morning, instead, we would make the `weekday` 7, and a `meetingStartTime` of 0.
     
     Most meetings will probably choose the 2400/previous day format, as that is more "natural" to people.
     
     The `nextMeetingStartsOn` property will have the absolute time, in any case.
     */
    var meetingStartTime: Int { get }

    /* ################################################################## */
    /**
     OPTIONAL - The duration of the meeting, in seconds.
     */
    var meetingDuration: TimeInterval { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has formats, then this contains a list of them. Empty, if no formats.
     */
    var formats: [LGV_MeetingSDK_Format_Protocol] { get }

    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has comments associated, they will be here, as a String. Empty, if no comments.
     */
    var comments: String { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a physical presence, this will have the location. Nil, if no physical location.
     
     **NOTE:** If this is not provided, then `virtualMeetingInfo` should be provided.
     */
    var physicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol? { get }

    /* ################################################################## */
    /**
     OPTIONAL - If the meeting has a virtual presence, this will have that information. Nil, if no virtual meeting.
     
     **NOTE:** If this is not provided, then `physicalLocation` should be provided.
     */
    var virtualMeetingInfo: LGV_MeetingSDK_Meeting_Virtual_Protocol? { get }
    
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
     Default figures out the meeting type, based on what venues are available.
     */
    var meetingType: LGV_MeetingSDK_VenueType_Enum {
        if nil != physicalLocation,
           nil != virtualMeetingInfo {
            return .hybrid
        } else if nil != physicalLocation {
            return .inPersonOnly
        } else if nil != virtualMeetingInfo {
            return .virtualOnly
        }
        
        return .invalid
    }
    
    /* ################################################################## */
    /**
     Default returns an optional DateComponents object, with the time of the meeting. This will not allow "2400" to be indicative of midnight. 2359 is the max.
     */
    var startTime: DateComponents? {
        guard (0...2400).contains(meetingStartTime) else { return nil }
        
        guard 2400 != meetingStartTime else { return DateComponents(hour: 0, minute: 0, second: 0) }
        
        var hour = Int(meetingStartTime / 1000)
        let minute = Int(meetingStartTime - (hour * 1000))

        return DateComponents(hour: hour, minute: minute, second: 0)
    }

    /* ################################################################## */
    /**
     Default returns an optional DateComponents object, with the weekday and time of the meeting. Returns nil, if the meeting weekday and/or start time is invalid.
     */
    var startTimeAndDay: DateComponents? {
        guard (1...7).contains(weekdayIndex),
              (0...2400).contains(meetingStartTime)
        else { return nil }
        
        var hour = Int(meetingStartTime / 1000)
        let minute = Int(meetingStartTime - (hour * 1000))
        var weekdayIndex = weekdayIndex

        // Special case for "tonight midnight."
        if (24 == hour) && (0 == minute) {
            weekdayIndex = 7 == weekdayIndex ? 1 : weekdayIndex + 1
            hour = 0
        }

        return DateComponents(hour: hour, minute: minute, second: 0, weekday: weekdayIndex)
    }

    /* ################################################################## */
    /**
     By default, this calculates and returns the date of a repeating weekly meeting, and returns the next time the meeting will gather, after now.
     
     If the meeting is not a recurring weekly meeting, this should be implemented by the conforming class.
     */
    var nextStartDate: Date? {
        guard let startTimeAndDay = startTimeAndDay else { return nil }

        return Calendar.current.nextDate(after: Date(), matching: startTimeAndDay, matchingPolicy: .nextTimePreservingSmallerComponents)
    }
    
    /* ################################################################## */
    /**
     Default simply divides the seconds duration into minutes.
     */
    var durationInMinutes: Int { Int(meetingDuration / 60) }
    
    /* ################################################################## */
    /**
     Default includes an offset of the weekday, for a different week start, as well as taking into account, the "2400" for midnight.
     */
    var timeDayAsInteger: Int {
        guard let startTimeAndDay = startTimeAndDay,
              var hour = startTimeAndDay.hour,
              let minute = startTimeAndDay.minute
        else { return 0 }
        
        var weekdayIndex = adjustedWeekdayIndex

        if 2400 == meetingStartTime {
            hour = 0
            weekdayIndex += 1
            if 0 > weekdayIndex {
                weekdayIndex += 7
            }
        }
        
        return (weekdayIndex * 10000) + (hour * 100) + minute
    }
    
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
    var locationCoords: CLLocationCoordinate2D? { isValid && .virtualOnly != meetingType ? physicalLocation?.coordinate : nil }

    /* ################################################################## */
    /**
     This is false, if the combination of meeting values does not represent a valid meeting.
     */
    var isValid: Bool { .invalid != meetingType && 0 < id && nil != nextStartDate && (nil != physicalLocation || nil != virtualMeetingInfo) }

    /* ################################################################## */
    /**
     Default tries to get the timezone from the physical address first, then the virtual, and failing that, our local timezone.
     */
    var meetingLocalTimezone: TimeZone { physicalLocation?.placemark.timeZone ?? virtualMeetingInfo?.videoMeeting?.timeZone ?? virtualMeetingInfo?.phoneMeeting?.timeZone ?? TimeZone.autoupdatingCurrent }

    /* ################################################################## */
    /**
     Default is an empty String.
     */
    var name: String { "" }
    
    /* ################################################################## */
    /**
     Default is 0
     */
    var weekdayIndex: Int { 0 }
    
    /* ################################################################## */
    /**
     Default is 0
     */
    var meetingStartTime: Int { 0 }
    
    /* ################################################################## */
    /**
     Default is 0
     */
    var meetingDuration: TimeInterval { 0 }
    
    /* ################################################################## */
    /**
     Default is an Empty Array
     */
    var formats: [LGV_MeetingSDK_Format_Protocol] { [] }

    /* ################################################################## */
    /**
     Default is an Empty String
     */
    var comments: String { "" }
    
    /* ################################################################## */
    /**
     Default is Nil
     */
    var physicalLocation: LGV_MeetingSDK_Meeting_Physical_Protocol? { nil }

    /* ################################################################## */
    /**
     Default is Nil
     */
    var virtualMeetingInfo: LGV_MeetingSDK_Meeting_Virtual_Protocol? { nil }
    
    /* ################################################################## */
    /**
     Default is Nil
     */
    var meetingURI: URL? { nil }
}
