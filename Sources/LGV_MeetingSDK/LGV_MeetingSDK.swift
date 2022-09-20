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

/* ###################################################################################################################################### */
// MARK: - Main SDK struct -
/* ###################################################################################################################################### */
/**
 This is instantiated, in order to provide meeting search capabilities for one organization.
 */
struct LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: The Concrete Implementation of the Organization.
    /* ################################################################################################################################## */
    struct OrganizationStruct: LGV_MeetingSDK_Organization_Protocol {
        /* ############################################################## */
        /**
         The key for this organization.
         */
        let organizationKey: String
        
        /* ############################################################## */
        /**
         The name for this organization (a short descriptive string).
         */
        let organizationName: String
        
        /* ################################################################## */
        /**
         The longer description for this organization. May be nil.
         */
        var organizationDescription: String?
    }
    
    /* ################################################################################################################################## */
    // MARK: Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is the transport layer for the TCP connection to the meeting list server.
     */
    var transport: LGV_MeetingSDK_Transport?
    
    /* ################################################################## */
    /**
     This is the transport layer for the TCP connection to the meeting list server.
     */
    private var _organization: OrganizationStruct
}

/* ###################################################################################################################################### */
// MARK: LGV_MeetingSDK_Protocol Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK: LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     The search organization.
     */
    var organization: LGV_MeetingSDK_Organization_Protocol { _organization }
}
