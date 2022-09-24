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
// MARK: - BMLT-Specialized SDK struct -
/* ###################################################################################################################################### */
/**
 This is a subclass of the main SDK class, that is "tuned" for [the BMLT](https://bmlt.app)
 */
open class LGV_MeetingSDK_BMLT: LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: BMLT-Specific Transport Struct
    /* ################################################################################################################################## */
    /**
     This transport is dedicated to the BMLT.
     We make this a class, so we can be weakly referenced.
     */
    public class Transport: LGV_MeetingSDK_Transport_Protocol {
        /* ########################################################## */
        /**
         This is a special dummy URL that we use to allow mocking.
         */
        public static let testingRootServerURL = URL(string: "https://bmlt.app.example.com/littlegreenviper")
        
        /* ############################################################################################################################## */
        // MARK: Parser
        /* ############################################################################################################################## */
        /**
         This is the parser. Most functionality will be in the extension.
         */
        public struct Parser { }
        
        /* ############################################################################################################################## */
        // MARK: Initiator
        /* ############################################################################################################################## */
        /**
         This is an initiator. It forms queries to the BMLT Root Server. Most functionality will be in the extension.
         */
        public struct Initiator {
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _transport: Transport?
            
            /* ########################################################## */
            /**
             The parser goes here.
             */
            public var parser: LGV_MeetingSDK_Parser_Protocol = Parser()
            
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             */
            public var transport: LGV_MeetingSDK_Transport_Protocol? {
                get { _transport }
                set { _transport = newValue as? Transport }
            }
        }
        
        /* ################################################################################################################################## */
        // MARK: LGV_MeetingSDK_Transport_Protocol Conformance
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         This will contain the URL to the Root Server that is being accessed by this transport instance.
         */
        public var baseURL: URL?

        /* ################################################################################################################################## */
        // MARK: Instance Properties
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         The initiator goes here.
         */
        public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol = Initiator()
        
        /* ################################################################## */
        /**
         The transport organization to which this instance is assigned.
         */
        public weak var organization: LGV_MeetingSDK_Organization_Transport_Protocol?
        
        /* ########################################################## */
        /**
         This contains the last search result set.
         */
        public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
        
        /* ################################################################################################################################## */
        // MARK: Initializer
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         Default initializer.
         
         - parameter rootServerURL: The URL to the BMLT Root Server that will be accessed by this instance.
         */
        public init(rootServerURL inRootServerURL: URL) {
            baseURL = inRootServerURL
            initiator.transport = self
        }
    }
    
    /* ###################################################################################################################################### */
    // MARK: Type Properties
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     The organization key to use for the test organization.
     */
    public static let organizationKey: String = "BMLT"
    
    /* ################################################################## */
    /**
     The name to use for the test organization.
     */
    public static let organizationName: String = "BMLT-Enabled"
    
    /* ################################################################## */
    /**
     The description to use for the test organization.
     */
    public static let organizationDescription = "BMLT-Enabled is an independent, non-profit management entity for the Basic Meeting List Toolbox Initiative."
    
    /* ################################################################## */
    /**
     The URL to use for the test organization.
     */
    public static let organizationURL = URL(string: "https://bmlt.app")
    
    /* ###################################################################################################################################### */
    // MARK: Initializer
    /* ###################################################################################################################################### */
    /* ############################################################## */
    /**
     Default initializer.
     
     - Parameters:
         - rootServerURL (REQUIRED): The URL to the BMLT Root Server that will be accessed by this instance.
         - organizationKey (OPTIONAL): The organization key. Default is `LGV_MeetingSDK_BMLT.organizationKey`
         - organizationName (OPTIONAL): The name of the organization. Default is `LGV_MeetingSDK_BMLT.organizationName`.
         - organizationName (OPTIONAL): A longer description for the organization. Default is `LGV_MeetingSDK_BMLT.organizationDescription`.
         - organizationURL (OPTIONAL): A URL for the organization. Default is `LGV_MeetingSDK_BMLT.organizationURL`.
     */
    public init(rootServerURL inRootServerURL: URL,
                organizationKey inOrganizationKey: String = LGV_MeetingSDK_BMLT.organizationKey,
                organizationName inOrganizationName: String = LGV_MeetingSDK_BMLT.organizationName,
                organizationDescription inOrganizationDescription: String = LGV_MeetingSDK_BMLT.organizationDescription,
                organizationURL inorganizationURL: URL? = LGV_MeetingSDK_BMLT.organizationURL) {
        let organization = LGV_MeetingSDK_Generic_Organization(transport: LGV_MeetingSDK_BMLT.Transport(rootServerURL: inRootServerURL),
                                                               organizationKey: inOrganizationKey,
                                                               organizationName: inOrganizationName,
                                                               organizationDescription: inOrganizationDescription,
                                                               organizationURL: inorganizationURL
        )
        super.init(organization: organization)
    }
}
