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
// MARK: - The Parsed Meeting Search Information Class -
/* ###################################################################################################################################### */
/**
 This defines a class, containing a "found set" of meeting data.
 It is defined as a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
 */
open class LGV_MeetingSDK_Meeting_Data_Set {
    /* ################################################################## */
    /**
     This contains any found meetings. It may be empty (no meetings found).
     */
    public let meetings: [LGV_MeetingSDK_Meeting_Protocol]

    /* ################################################################## */
    /**
     Default initializer.
     
     - parameter meetings: OPTIONAL This contains any found meetings. It may be empty or omitted (no meetings found).
     */
    public init(meetings inMeetings: [LGV_MeetingSDK_Meeting_Protocol] = []) {
        meetings = inMeetings
    }
}

/* ###################################################################################################################################### */
// MARK: - The Parser Protocol -
/* ###################################################################################################################################### */
/**
 This defines the requirements for an instance of a data parser for the transport.
 */
public protocol LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
     
     - returns: The parsed meeting information
     */
    func parseThis(data: Data) -> LGV_MeetingSDK_Meeting_Data_Set
}

/* ###################################################################################################################################### */
// MARK: - The Transport Layer Protocol -
/* ###################################################################################################################################### */
/**
 This defines requirements for a loosely-coupled transport layer.
 */
public protocol LGV_MeetingSDK_Transport_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - The parser for meeting data.
     */
    var parser: LGV_MeetingSDK_Parser_Protocol { get }
    
    /* ################################################################## */
    /**
     REQUIRED - The transport organization to which this instance is assigned. It should generally be declared weak.
     */
    var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { get set }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - The SDK instance to which this transport's organization is assigned.
     */
    var sdkInstance: LGV_MeetingSDK? { get }

    /* ################################################################## */
    /**
     OPTIONAL - The "base" URL for the transport target.
     */
    var baseURL: URL? { get }
}

/* ###################################################################################################################################### */
// MARK: - The Transport Layer Protocol -
/* ###################################################################################################################################### */
/**
 This defines requirements for a loosely-coupled transport layer.
 */
public extension LGV_MeetingSDK_Transport_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var baseURL: URL? { nil }
    
    /* ################################################################## */
    /**
     The default simply returns the organization's SDK instance.
     */
    var sdkInstance: LGV_MeetingSDK? { organization?.sdkInstance }
}
