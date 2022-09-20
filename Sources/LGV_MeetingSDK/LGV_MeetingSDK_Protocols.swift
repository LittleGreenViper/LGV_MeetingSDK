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

/* ###################################################################################################################################### */
// MARK: - The Structure of a Format Object -
/* ###################################################################################################################################### */
/**
 */
protocol LGV_MeetingSDK_Format_Protocol {
    /* ################################################################## */
    /**
     The unique UUID for this format.
     This must be unique within the context of the SDK instance.
     */
    var formatUUIDString: String { get }
    
    /* ################################################################## */
    /**
     The unique key for this format.
     This must be unique within the context of the Meeting instance.
     */
    var formatKey: String { get }
    
    /* ################################################################## */
    /**
     The name for this format.
     */
    var formatName: String { get }
    
    /* ################################################################## */
    /**
     The longer description for this format.
     */
    var formatDescription: String { get }
}

/* ###################################################################################################################################### */
// MARK: - The Structure of a Meeting Object -
/* ###################################################################################################################################### */
/**
 */
protocol LGV_MeetingSDK_Meeting_Protocol {
    /* ################################################################## */
    /**
     The name for this meeting.
     */
    var meetingName: String { get }
    
    /* ################################################################## */
    /**
     If the meeting has formats, then this contains a list of them.
     */
    var formats: [LGV_MeetingSDK_Format_Protocol] { get }
    
    /* ################################################################## */
    /**
     If the meeting has a physical presence, then the coordinates (degrees Long/Lat) will be here. Nil, if no physical location.
     */
    var physicalLocationCoordinates: CLLocationCoordinate2D? { get }
}

/* ###################################################################################################################################### */
// MARK: - Protocol for observers of the SDK -
/* ###################################################################################################################################### */
/**
 */
protocol LGV_MeetingSDK_Observer_Protocol {
    /* ################################################################## */
    /**
     */

}
