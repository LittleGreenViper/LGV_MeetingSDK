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
import Contacts     // For the CLPlacemark class.

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
// MARK: - The Transport Layer Protocol -
/* ###################################################################################################################################### */
/**
 This defines requirements for a loosely-coupled transport layer.
 */
public protocol LGV_MeetingSDK_Transport_Protocol {
    
}

/* ###################################################################################################################################### */
// MARK: - The Structure of an Organization Object -
/* ###################################################################################################################################### */
/**
 Each meeting is given/managed by an organization (AA, NA, etc.). This defines the associated organization.
 */
public protocol LGV_MeetingSDK_Organization_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The key for this organization.
     This should be unique in the execution environment.
     */
    var organizationKey: String { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The name for this organization (a short descriptive string).
     */
    var organizationName: String { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The longer description for this organization. May be nil.
     */
    var organizationDescription: String? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The URL for this organization. May be nil.
     */
    var organizationURL: URL? { get }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Organization_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var organizationDescription: String? { nil }
    
    /* ################################################################## */
    /**
     Default is nil.
     */
    var organizationURL: URL? { nil }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of an Organization With Associated Transport -
/* ###################################################################################################################################### */
/**
 We define this as applied to classes, so it can be overloaded/ridden. The idea is to define a specific organization, with a custom transport, for each server.
 */
public protocol LGV_MeetingSDK_Organization_Transport_Protocol: LGV_MeetingSDK_Organization_Protocol, AnyObject {
    /* ################################################################## */
    /**
     REQUIRED - This allows us to have an organization-specific transport.
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? { get }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Format Object -
/* ###################################################################################################################################### */
/**
 Each meeting may have a list of associated formats, describing details about the meeting.
 */
public protocol LGV_MeetingSDK_Format_Protocol {
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
// MARK: - The Structure of a Meeting's Phyisical Component -
/* ###################################################################################################################################### */
/**
 This defines the meeting's physical location component.
 */
public protocol LGV_MeetingSDK_Meeting_Physical_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The location is stored as a standard placemark.
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
public protocol LGV_MeetingSDK_Meeting_Virtual_Venue_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This describes the meeting venue (i.e. "Video," "Zoom," "Audio-Only," "Phone," etc.).
     */
    var description: String { get }

    /* ################################################################## */
    /**
     REQUIRED - The local timezone for the meeting.
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
public protocol LGV_MeetingSDK_Meeting_Virtual_Protocol {
    /* ################################################################## */
    /**
     OPTIONAL - If there is a video meeting associated, it is defined here. May be nil.
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
public protocol LGV_MeetingSDK_Meeting_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The meeting organization.
     */
    var organization: LGV_MeetingSDK_Organization_Protocol { get }
    
    /* ################################################################## */
    /**
     OPTIONAL -, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The meeting venue type.
     */
    var meetingType: LGV_MeetingSDK_VenueType_Enum { get }
    
    /* ################################################################## */
    /**
     OPTIONAL -, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This is false, if the combination of meeting values does not represent a valid meeting.
     */
    var isValid: Bool { get }

    /* ################################################################## */
    /**
     OPTIONAL -. The next meeting (from now) will start on this date (time).
     
     If this is a one-time event, then this will be the only indicator of the meeting start time/date.
     */
    var nextMeetingStartsOn: Date? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The name for this meeting.
     */
    var meetingName: String { get }
    
    /* ################################################################## */
    /**
     OPTIONAL - The repeating weekday for the meeting (1-based, with 1 being Sunday, and 7 being Saturday).
     
     If this is 0, then the meeting is considered to be a one-time event, and the `meetingStartTime` property should be ignored (`nextMeetingStartsOn` will have the start time and day).
     
     **NOTE:** 1 is Sunday, regardless of the current region week start day.
     */
    var weekday: Int { get }
    
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
     OPTIONAL - The local timezone of the meeting.
     
     **NOTE:** It is important to implement this, if the meeting is held in a particular timezone, and does not have it specified in its location.
     */
    var meetingLocalTimezone: TimeZone { get }

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
     This is false, if the combination of meeting values does not represent a valid meeting.
     */
    var isValid: Bool { .invalid != meetingType && nil != nextMeetingStartsOn && (nil != physicalLocation || nil != virtualMeetingInfo) }

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
     By default, this calculates and returns the date of a repeating weekly meeting, and returns the next time the meeting will gather, after now.
     
     If the meeting is not a recurring weekly meeting, this should be implemented by the conforming class.
     */
    var nextMeetingStartsOn: Date? {
        return nil
    }

    /* ################################################################## */
    /**
     Default is an empty String.
     */
    var meetingName: String { "" }
    
    /* ################################################################## */
    /**
     Default is 0
     */
    var weekday: Int { 0 }
    
    /* ################################################################## */
    /**
     Default is 0
     */
    var meetingStartTime: Int { 0 }
    
    /* ################################################################## */
    /**
     Default tries to get the timezone from the physical address first, then the virtual, and failing that, our local timezone.
     */
    var meetingLocalTimezone: TimeZone { physicalLocation?.timeZone ?? virtualMeetingInfo?.videoMeeting?.timeZone ?? virtualMeetingInfo?.phoneMeeting?.timeZone ?? TimeZone.autoupdatingCurrent }

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

/* ###################################################################################################################################### */
// MARK: - The Main Implementation Protocol -
/* ###################################################################################################################################### */
/**
 This defines the requirements for the main SDK instance.
 */
public protocol LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The search organization.
     */
    var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The transport instance.
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? { get }
}
