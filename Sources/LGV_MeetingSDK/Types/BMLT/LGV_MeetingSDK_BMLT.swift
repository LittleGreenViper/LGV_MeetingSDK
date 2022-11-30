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
import Contacts

/* ###################################################################################################################################### */
// MARK: - BMLT-Specialized SDK struct -
/* ###################################################################################################################################### */
/**
 This is a subclass of the main SDK class, that is "tuned" for [the BMLT](https://bmlt.app)
 */
open class LGV_MeetingSDK_BMLT: LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: - Format Struct -
    /* ################################################################################################################################## */
    /**
     This describes one "meeting format," which is some extra information attached to a meeting, describing attributes.
     */
    public struct Format: LGV_MeetingSDK_Format_Protocol {
        /* ################################################################## */
        /**
         This is a a unique ID (in the organization/server), for the format.
         */
        public var id: UInt64
        
        /* ################################################################## */
        /**
         This is a simple text "key" for the format. It should be unique in the found set.
         */
        public var key: String
        
        /* ################################################################## */
        /**
         This is a short name for the format.
         */
        public var name: String
        
        /* ################################################################## */
        /**
         This is a longer description for the format.
         */
        public var description: String
    }

    /* ################################################################################################################################## */
    // MARK: BMLT-Specific Transport Struct
    /* ################################################################################################################################## */
    /**
     This transport is dedicated to the BMLT.
     We make this a class, so we can be weakly referenced.
     */
    public class Transport: LGV_MeetingSDK_Transport_Protocol {
        /* ############################################################################################################################## */
        // MARK: Parser
        /* ############################################################################################################################## */
        /**
         This is the parser. Most functionality will be in the extension.
         */
        public class Parser {
            /* ################################################################## */
            /**
             The initiator, for creating search commands.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _initiator: Initiator?
            
            /* ################################################################## */
            /**
             The initiator, for creating search commands.
             */
            public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol? {
                get { _initiator }
                set { _initiator = newValue as? Initiator }
            }
        }
        
        /* ############################################################################################################################## */
        // MARK: Initiator
        /* ############################################################################################################################## */
        /**
         This is an initiator. It forms queries to the BMLT Root Server. Most functionality will be in the extension.
         We make it a class, so it will be referencable.
         */
        public class Initiator {
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             We declare the stored property private, and specific to the class, so we can weakly reference it.
             */
            private weak var _transport: Transport?
            
            /* ########################################################## */
            /**
             */
            private var _parser: LGV_MeetingSDK_BMLT.Transport.Parser?
            
            /* ########################################################## */
            /**
             The parser goes here.
             */
            public var parser: LGV_MeetingSDK_Parser_Protocol {
                get { _parser! } // I hate implicit optionals, but I want this to crash, if it is deallocated.
                set { _parser = newValue as? LGV_MeetingSDK_BMLT.Transport.Parser }
            }
            
            /* ########################################################## */
            /**
             The transport to be used for this initiator.
             */
            public var transport: LGV_MeetingSDK_Transport_Protocol? {
                get { _transport }
                set { _transport = newValue as? Transport }
            }
            
            /* ########################################################## */
            /**
             Default init. we simply create a parser, and let it know about us.
             */
            public init() {
                parser = Parser()
                (parser as? Parser)?.initiator = self
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
        
        /* ########################################################## */
        /**
         The parser
         */
        public var parser: LGV_MeetingSDK_Parser_Protocol? { initiator?.parser }

        /* ################################################################################################################################## */
        // MARK: Instance Properties
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         The initiator goes here.
         */
        public var initiator: LGV_MeetingSDK_SearchInitiator_Protocol?
        
        /* ################################################################## */
        /**
         The transport organization to which this instance is assigned.
         */
        public var organization: LGV_MeetingSDK_Organization_Transport_Protocol?
        
        /* ########################################################## */
        /**
         This contains the last search result set.
         */
        public var lastSearch: LGV_MeetingSDK_Meeting_Data_Set?
        
        /* ################################################################################################################################## */
        // MARK: Mocking Properties
        /* ################################################################################################################################## */
        /* ########################################################## */
        /**
         This is a special dummy URL that we use to allow mocking.
         */
        public static let testingRootServerURL = URL(string: "https://bmlt.app.example.com/littlegreenviper")
        
        /* ########################################################## */
        /**
         This is used to "short-circuit" the actual network call.
         
         If this is non-nil, then the Data instance is sent to the callback closure as a "one-shot" call. The property is immediately cleared, after being read.
         The URL is ignored.
         */
        public var debugMockDataResponse: Data?
        
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
            initiator = Initiator()
            initiator?.transport = self
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
    // MARK: Instance Methods
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     Simple accessor to the Root Server URL String.
     */
    public var rootServerURLString: String {
        get { organization?.transport?.baseURL?.absoluteString ?? "" }
        set { organization?.transport?.baseURL = URL(string: newValue) }
    }
    
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
        - refCon (OPTIONAL): An optional (default is nil) reference context, to attach to the SDK instance.
     */
    public init(rootServerURL inRootServerURL: URL,
                organizationKey inOrganizationKey: String = LGV_MeetingSDK_BMLT.organizationKey,
                organizationName inOrganizationName: String = LGV_MeetingSDK_BMLT.organizationName,
                organizationDescription inOrganizationDescription: String = LGV_MeetingSDK_BMLT.organizationDescription,
                organizationURL inorganizationURL: URL? = LGV_MeetingSDK_BMLT.organizationURL,
                refCon: Any? = nil) {
        let organization = LGV_MeetingSDK_Generic_Organization(transport: LGV_MeetingSDK_BMLT.Transport(rootServerURL: inRootServerURL),
                                                               organizationKey: inOrganizationKey,
                                                               organizationName: inOrganizationName,
                                                               organizationDescription: inOrganizationDescription,
                                                               organizationURL: inorganizationURL
        )
        super.init(organization: organization)
    }
}
