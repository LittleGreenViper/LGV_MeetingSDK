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
        - modifiers: a set of search filter modifiers.
        - completion: The completion closure.
     */
    func meetingSearch(type: LGV_MeetingSDK_Meeting_Data_Set.SearchType,
                       modifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>,
                       completion: LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure)
}

/* ###################################################################################################################################### */
// MARK: Protocol Defaults
/* ###################################################################################################################################### */
public extension LGV_MeetingSDK_Protocol {
    /* ################################################################## */
    /**
     Default runs, using the built-in organization->transport->initiator method.
     */
    func meetingSearch(type inType: LGV_MeetingSDK_Meeting_Data_Set.SearchType,
                       modifiers inModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers>,
                       completion inCompletion: LGV_MeetingSDK_SearchInitiator_Protocol.MeetingSearchCallbackClosure) {
        organization?.transport?.initiator.meetingSearch(type: inType, modifiers: inModifiers, completion: inCompletion)
    }
}
