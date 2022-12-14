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
        - type (REQUIRED): Any search type that was specified.
        - refinements (REQUIRED): Any search refinements.
        - refCon (OPTIONAL): An arbitrary data attachment to the search. This will be returned in the search results set.
        - completion (REQUIRED): A completion function.
     */
    public func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                              refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                              refCon inRefCon: Any? = nil,
                              completion inCompletion: @escaping MeetingSearchCallbackClosure) {
        guard let urlRequest = transport?.ceateURLRequest(type: inSearchType, refinements: inSearchRefinements) else { return }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            let emptyResponse = LGV_MeetingSDK_Meeting_Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements)
            guard let response = response as? HTTPURLResponse else {
                inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError.missingResponseError(error: error))
                return
            }
            
            if nil == error {
                var commError: LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError?
                let statusCode = response.statusCode
                
                switch statusCode {
                case 200..<300:
                    if let data = data,
                       "application/json" == response.mimeType {
                        self.parser.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: data, refCon: inRefCon) { inParsedMeetings, inError in
                            if var parsedData = inParsedMeetings {
                                parsedData.extraInfo = urlRequest.url?.absoluteString ?? ""
                                self.transport?.sdkInstance?.lastSearch = parsedData
                                inCompletion(parsedData, inError)
                            } else {
                                inCompletion(emptyResponse, inError)
                            }
                        }
                    } else {
                        inCompletion(emptyResponse, nil)
                    }
                case 300..<400:
                    commError = .redirectionError(error: error)
                    
                case 400..<500:
                    commError = .clientError(error: error)
                    
                case 500...:
                    commError = .serverError(error: error)
                    
                default:
                    commError = .generalError(error: error)
                }
                
                if let commError = commError {
                    inCompletion(emptyResponse, commError)
                }
            } else {
                inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError.generalError(error: nil))
            }
        }.resume()
    }
}
