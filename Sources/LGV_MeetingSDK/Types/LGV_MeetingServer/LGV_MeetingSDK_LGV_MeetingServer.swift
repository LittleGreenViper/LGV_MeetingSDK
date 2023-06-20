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
// MARK: - LGV_Meeting_Server-Specialized SDK struct -
/* ###################################################################################################################################### */
/**
 This is a subclass of the main SDK class, that is "tuned" for the LGV_MeetingServer.
 */
open class LGV_MeetingSDK_LGV_MeetingServer: LGV_MeetingSDK {
    /* ################################################################################################################################## */
    // MARK: Specific Transport Struct
    /* ################################################################################################################################## */
    /**
     This transport is dedicated to the LGV_MeetingServer.
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
         This is an initiator. It forms queries to the LGV_MeetingServer Server entrypoint. Most functionality will be in the extension.
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
            private var _parser: LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser?
            
            /* ########################################################## */
            /**
             The parser goes here.
             */
            public var parser: LGV_MeetingSDK_Parser_Protocol {
                get { _parser! } // I hate implicit optionals, but I want this to crash, if it is deallocated.
                set { _parser = newValue as? LGV_MeetingSDK_LGV_MeetingServer.Transport.Parser }
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
         This will contain the URL to the main Server that is being accessed by this transport instance.
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
        public static let testingEntrypointURL = URL(string: "https://bmlt.app.example.com/littlegreenviper")
        
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
         
         - parameter entrypointURL: The URL to the LGV_MeetingServer Server that will be accessed by this instance.
         */
        public init(entrypointURL inEntrypointURL: URL) {
            baseURL = inEntrypointURL
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
    public static let organizationKey: String = "NA"
    
    /* ################################################################## */
    /**
     The name to use for the test organization.
     */
    public static let organizationName: String = "Narcotics Anonymous"
    
    /* ################################################################## */
    /**
     The description to use for the test organization.
     */
    public static let organizationDescription = ""
    
    /* ################################################################## */
    /**
     The URL to use for the test organization.
     */
    public static let organizationURL = URL(string: "https://na.org")
    
    /* ###################################################################################################################################### */
    // MARK: Instance Methods
    /* ###################################################################################################################################### */
    /* ################################################################## */
    /**
     Simple accessor to the Root Server URL String.
     */
    public var entrypointURLString: String {
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
        - entrypointURL (REQUIRED): The URL to the Meeting Server that will be accessed by this instance.
        - organizationKey (OPTIONAL): The organization key. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationKey`
        - organizationName (OPTIONAL): The name of the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationName`.
        - organizationName (OPTIONAL): A longer description for the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationDescription`.
        - organizationURL (OPTIONAL): A URL for the organization. Default is `LGV_MeetingSDK_LGV_MeetingServer.organizationURL`.
        - refCon (OPTIONAL): An optional (default is nil) reference context, to attach to the SDK instance.
     */
    public init(entrypointURL inEntrypointURL: URL,
                organizationKey inOrganizationKey: String = LGV_MeetingSDK_LGV_MeetingServer.organizationKey,
                organizationName inOrganizationName: String = LGV_MeetingSDK_LGV_MeetingServer.organizationName,
                organizationDescription inOrganizationDescription: String = LGV_MeetingSDK_LGV_MeetingServer.organizationDescription,
                organizationURL inorganizationURL: URL? = LGV_MeetingSDK_LGV_MeetingServer.organizationURL,
                refCon: Any? = nil) {
        let organization = LGV_MeetingSDK_Generic_Organization(transport: LGV_MeetingSDK_LGV_MeetingServer.Transport(entrypointURL: inEntrypointURL),
                                                               organizationKey: inOrganizationKey,
                                                               organizationName: inOrganizationName,
                                                               organizationDescription: inOrganizationDescription,
                                                               organizationURL: inorganizationURL
        )
        super.init(organization: organization)
    }
}
