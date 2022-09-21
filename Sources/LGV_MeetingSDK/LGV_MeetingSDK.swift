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
// MARK: - Main SDK struct -
/* ###################################################################################################################################### */
/**
 This is instantiated, in order to provide meeting search capabilities for one organization.
 */
public struct LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: LGV_MeetingSDK_Protocol Conformance (Main Instance Stored Properties)
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the organization that applies to this search instance.
     */
    private var _organization: LGV_MeetingSDK_Organization_Transport_Protocol?

    /* ################################################################################################################################## */
    // MARK: Instance Properties
    /* ################################################################################################################################## */
    
    /* ################################################################################################################################## */
    // MARK: Main Initializer
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the default initializer for the search SDK.
     */
    public init(organization inOrganization: LGV_MeetingSDK_Organization_Transport_Protocol) {
        _organization = inOrganization
    }
}

/* ###################################################################################################################################### */
// MARK: LGV_MeetingSDK_Protocol Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK: LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     This is the organization that applies to this search instance.
     */
    public var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { _organization }

    /* ################################################################## */
    /**
     This is the transport layer for the TCP connection to the meeting list server.
     */
    public var transport: LGV_MeetingSDK_Transport_Protocol? { organization?.transport }
}

/* ###################################################################################################################################### */
// MARK: - Generic Organization struct -
/* ###################################################################################################################################### */
/**
 This is a "general-purpose" organization struct that should work for most requirements.
 */
public struct LGV_MeetingSDK_Generic_Organization: LGV_MeetingSDK_Organization_Protocol {
    /* ########################################################## */
    /**
     We store the transport in a private property, and access it, via a computed one.
     */
    private var _transport: LGV_MeetingSDK_Transport_Protocol?
    
    /* ################################################################## */
    /**
     We store the description in a private property, and access it, via a computed one.
     */
    private var _organizationDescription: String?

    /* ################################################################## */
    /**
     We store the URL in a private property, and access it, via a computed one.
     */
    private var _organizationURL: URL?

    /* ################################################################## */
    /**
     This is the unique key for the organization. This should be unique in the SDK execution environment.
     */
    public var organizationKey: String
    
    /* ################################################################## */
    /**
     This is a short name for the organization.
     */
    public var organizationName: String

    /* ########################################################## */
    /**
     This is the accessor for the transport private property.
     */
    var transport: LGV_MeetingSDK_Transport_Protocol? { _transport }
    
    /* ################################################################## */
    /**
     This is the accessor for the description private property.
     */
    public var organizationDescription: String? { _organizationDescription }

    /* ################################################################## */
    /**
     This is the accessor for the URL private property.
     */
    public var organizationURL: URL? { _organizationURL }
    
    /* ################################################################## */
    /**
     The default initializer.
     
     - Parameters:
        - transport (REQUIRED): This is a required argument. It will be the transport instance to be used with this organization.
        - organizationKey (REQUIRED): This is a required argument. The organization key. This should be unique, in the SDK execution context.
        - organizationName (OPTIONAL): The name of the organization. Default is an empty String.
        - organizationName (OPTIONAL): A longer description for the organization. Default is nil.
        - organizationURL (OPTIONAL): A URL for the organization. Default is nil.
     */
    public init(transport inTransport: LGV_MeetingSDK_Transport_Protocol,
                organizationKey inOrganizationKey: String,
                organizationName inOrganizationName: String = "",
                organizationDescription inOrganizationDescription: String? = nil,
                organizationURL inOrganizationURL: URL? = nil
        ) {
        _transport = inTransport
        organizationKey = inOrganizationKey
        organizationName = inOrganizationName
        _organizationDescription = inOrganizationDescription
        _organizationURL = inOrganizationURL
    }
}
