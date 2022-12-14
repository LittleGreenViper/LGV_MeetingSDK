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
// MARK: - The Structure of an Organization Object -
/* ###################################################################################################################################### */
/**
 Each meeting is given/managed by an organization (AA, NA, etc.). This defines the associated organization.
 */
public protocol LGV_MeetingSDK_Organization_Protocol: LGV_MeetingSDK_Additional_Info_Protocol, AnyObject {
    /* ################################################################## */
    /**
     REQUIRED - The key for this organization.
     
     This should be unique in the execution environment.
     */
    var organizationKey: String { get set }
    
    /* ################################################################## */
    /**
     REQUIRED - The SDK instance to which this organization is assigned. This should generally be declared weak.
     */
    var sdkInstance: LGV_MeetingSDK? { get set }

    /* ################################################################## */
    /**
     REQUIRED - The name for this organization (a short descriptive string).
     */
    var organizationName: String { get set }
    
    /* ################################################################## */
    /**
     REQUIRED - The longer description for this organization. May be nil.
     */
    var organizationDescription: String? { get set }
    
    /* ################################################################## */
    /**
     OPTIONAL - The URL for this organization. May be nil.
     */
    var organizationURL: URL? { get set }
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
     REQUIRED - This allows us to have an organization-specific transport. This should be a strong reference (if the transport is a class).
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? { get }
}
