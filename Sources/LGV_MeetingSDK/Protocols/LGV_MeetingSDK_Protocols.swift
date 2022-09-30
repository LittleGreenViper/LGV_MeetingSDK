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
// MARK: - A Simple "Reference Context" Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, that defines a simple `extraInfo` String, allowing conformant types to store string information.
 */
public protocol LGV_MeetingSDK_RefCon_Protocol {
    /* ############################################################## */
    /**
     OPTIONAL - This allows the SDK to declare a "refcon" (reference context), attaching any data to the object.
     */
    var refCon: Any? { get set }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_RefCon_Protocol {
    /* ############################################################## */
    /**
     Default is nil.
     */
    var refCon: Any? {
        get { nil }
        set { _ = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - A Simple "Extra Info" Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, that declares a simple `extraInfo` String, allowing conformant types to store string information.
 */
public protocol LGV_MeetingSDK_Additional_Info_Protocol {
    /* ############################################################## */
    /**
     OPTIONAL - This will return any "extra info," applied to the conformant instance.
     */
    var extraInfo: String { get set }
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Additional_Info_Protocol {
    /* ############################################################## */
    /**
     Default is an empty String.
     */
    var extraInfo: String {
        get { "" }
        set { _ = newValue }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Parsed Meeting Search Information Protocol -
/* ###################################################################################################################################### */
/**
 This defines a protocol, containing a "found set" of meeting data.
 It is defined for a class, so it can be referenced (possibly weakly), in order to avoid data duplication.
 */
public protocol LGV_MeetingSDK_Meeting_Data_Set_Protocol: AnyObject, LGV_MeetingSDK_Additional_Info_Protocol, LGV_MeetingSDK_RefCon_Protocol, CustomDebugStringConvertible {
    /* ############################################################## */
    /**
     REQUIRED - This is the search specification main search type.
     */
    var searchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints { get }
    
    /* ############################################################## */
    /**
     REQUIRED - This is the search specification additional filters.
     */
    var searchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> { get }
    
    /* ############################################################## */
    /**
     REQUIRED - This contains any found meetings. It may be empty (no meetings found).
     */
    var meetings: [LGV_MeetingSDK_Meeting_Protocol] { get set }
}

/* ###################################################################################################################################### */
// MARK: CustomDebugStringConvertible Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Meeting_Data_Set_Protocol {
    /* ############################################################## */
    /**
     CustomDebugStringConvertible Conformance
     */
    public var debugDescription: String {
        "\nLGV_MeetingSDK_Meeting_Data_Set_Protocol\n\textraInfo: \"" + extraInfo + "\"" +
        "\n\trefCon: " + String(describing: refCon) +
        "\n\tsearchType: " + searchType.debugDescription +
        "\n\tsearchRefinements: " + searchRefinements.debugDescription +
        "\n\tmeetings: " + meetings.debugDescription
    }
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
     REQUIRED - The search organization. This needs to be the "transport" version of the organization.
     */
    var organization: LGV_MeetingSDK_Organization_Transport_Protocol? { get }

    /* ################################################################## */
    /**
     REQUIRED - The "cached" last search. It may be nil (no last search cached).
     */
    var lastSearch: LGV_MeetingSDK_Meeting_Data_Set? { get }
    
    /* ################################################################## */
    /**
     OPTIONAL, AND SHOULD GENERALLY NOT BE IMPLEMENTED - This executes a meeting search.
     - Parameters:
        - type: The main search type.
        - refinements: a set of search filter refinements.
        - completion: The completion closure. **NOTE:** This may be called in any thread, and it is escaping (should capture arguments).
     */
    func meetingSearch(type: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                       refinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                       completion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     Default runs, using the built-in organization->transport->initiator method.
     */
    func meetingSearch(type inType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                       refinements inRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                       completion inCompletion: @escaping LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        organization?.transport?.initiator?.meetingSearch(type: inType, refinements: inRefinements, completion: inCompletion)
    }
}
