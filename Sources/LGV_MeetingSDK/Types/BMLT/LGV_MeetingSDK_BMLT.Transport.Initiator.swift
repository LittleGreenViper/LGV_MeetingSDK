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
// MARK: - BMLT Parser Extension -
/* ###################################################################################################################################### */
/**
 This adds methods to the initiator struct.
 */
extension LGV_MeetingSDK_BMLT.Transport.Initiator: LGV_MeetingSDK_SearchInitiator_Protocol {
    /* ########################################################## */
    /**
     This executes a meeting search.
     
     - Parameters:
        - type: Any search type that was specified.
        - refinements: Any search refinements.
        - completion: A completion function.
     */
    public func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                              refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                              completion inCompletion: MeetingSearchCallbackClosure) {
        let urlRequest = (transport as? LGV_MeetingSDK_BMLT.Transport)?.ceateURLRequest(type: inSearchType, refinements: inSearchRefinements)
        #if DEBUG
            print("URL Request: \(urlRequest.debugDescription)")
        #endif
        inCompletion(parser.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: Data()), nil)
    }
}
