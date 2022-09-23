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
 This adds methods to the parser struct.
 */
extension LGV_MeetingSDK_BMLT.Transport.Parser: LGV_MeetingSDK_Parser_Protocol {
    /* ################################################################## */
    /**
     REQUIRED - This parses data, and returns meetings.
     
     - parameter searchType: OPTIONAL This is the search specification main search type. Default is .none.
     - parameter searchModifiers: OPTIONAL This is the search specification additional filters. Default is .none.
     - parameter data: The unparsed data, from the transport. It should consist of a meeting data set.
     
     - returns: An empty parse set
     */
    public func parseThis(searchType inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchType = .none,
                          searchModifiers inSearchModifiers: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Modifiers> = [],
                          data inData: Data) -> LGV_MeetingSDK_Meeting_Data_Set_Protocol {
        LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchModifiers: inSearchModifiers, meetings: [])
    }
}
