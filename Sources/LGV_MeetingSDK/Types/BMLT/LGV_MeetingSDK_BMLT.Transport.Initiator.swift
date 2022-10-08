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
        - type: Any search type that was specified.
        - refinements: Any search refinements.
        - completion: A completion function.
     */
    public func meetingSearch(type inSearchType: LGV_MeetingSDK_Meeting_Data_Set.SearchConstraints,
                              refinements inSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>,
                              completion inCompletion: @escaping MeetingSearchCallbackClosure) {
        guard let urlRequest = (transport as? LGV_MeetingSDK_BMLT.Transport)?.ceateURLRequest(type: inSearchType, refinements: inSearchRefinements) else { return }
        #if DEBUG
            print("URL Request: \(urlRequest.debugDescription)")
        #endif
        // See if we have mock data.
        if let dataToParse = (transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse {
            (transport as? LGV_MeetingSDK_BMLT.Transport)?.debugMockDataResponse = nil
            parser.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: dataToParse) { inParsedMeetings, inError in
                if var parsedData = inParsedMeetings {
                    parsedData.extraInfo = urlRequest.url?.absoluteString ?? ""
                    inCompletion(parsedData, inError)
                } else {
                    inCompletion(nil, nil)
                }
            }
        } else {    // Otherwise, we need to execute an NSURLSession data task.
            URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
                let emptyResponse = LGV_MeetingSDK_BMLT.Data_Set(searchType: inSearchType, searchRefinements: inSearchRefinements)
                if nil == error,
                   let response = response as? HTTPURLResponse {
                    if 200 == response.statusCode {
                        #if DEBUG
                            print("Server returned success code 200")
                        #endif
                        if let data = data,
                           "application/json" == response.mimeType {
                            self?.parser.parseThis(searchType: inSearchType, searchRefinements: inSearchRefinements, data: data) { inParsedMeetings, inError in
                                if var parsedData = inParsedMeetings {
                                    parsedData.extraInfo = urlRequest.url?.absoluteString ?? ""
                                    inCompletion(parsedData, inError)
                                } else {
                                    inCompletion(emptyResponse, nil)
                                }
                            }
                        } else if let error = error {
                            #if DEBUG
                                print(String(format: "Server returned status code %d, and error %@", response.statusCode, error.localizedDescription))
                            #endif
                            inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError.generalError(error: error))
                        } else {
                            #if DEBUG
                                print(String(format: "Server returned empty data (no error)."))
                            #endif
                            inCompletion(emptyResponse, nil)
                        }
                    } else if let error = error {
                        #if DEBUG
                            print(String(format: "Server returned status code %d, and error %@", response.statusCode, error.localizedDescription))
                        #endif
                        var commError: LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError
                        
                        switch response.statusCode {
                        case 300..<400:
                            commError = .redirectionError(error: error)
                            
                        case 400..<500:
                            commError = .clientError(error: error)
                            
                        case 500...:
                            commError = .serverError(error: error)
                            
                        default:
                            commError = .generalError(error: error)
                        }
                        inCompletion(emptyResponse, commError)
                    } else {
                        #if DEBUG
                            print(String(format: "Server returned status code %d", response.statusCode))
                        #endif
                        var commError: LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError
                        
                        switch response.statusCode {
                        case 300..<400:
                            commError = .redirectionError(error: error)
                            
                        case 400..<500:
                            commError = .clientError(error: error)
                            
                        case 500...:
                            commError = .serverError(error: error)
                            
                        default:
                            commError = .generalError(error: error)
                        }
                        inCompletion(emptyResponse, commError)
                    }
                } else if let error = error {
                    var commError: LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError
                    
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                        case 300..<400:
                            commError = .redirectionError(error: error)
                            
                        case 400..<500:
                            commError = .clientError(error: error)
                            
                        case 500...:
                            commError = .serverError(error: error)
                            
                        default:
                            commError = .generalError(error: error)
                        }
                    } else {
                        commError = .generalError(error: error)
                    }
                    #if DEBUG
                        if let response = response as? HTTPURLResponse {
                            print(String(format: "Server returned error: %@, and response: %@", error.localizedDescription, response.debugDescription))
                        } else {
                            print(String(format: "Server returned error: %@", error.localizedDescription))
                        }
                    #endif
                    inCompletion(emptyResponse, commError)
                } else if let response = response as? HTTPURLResponse {
                    #if DEBUG
                        print(String(format: "Server returned response: %@", response.debugDescription))
                    #endif
                    var commError: LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError
                    
                    switch response.statusCode {
                    case 300..<400:
                        commError = .redirectionError(error: nil)
                        
                    case 400..<500:
                        commError = .clientError(error: nil)
                        
                    case 500...:
                        commError = .serverError(error: nil)
                        
                    default:
                        commError = .generalError(error: nil)
                    }
                    inCompletion(emptyResponse, commError)
                } else {
                    #if DEBUG
                        print("Unkown Response Condition!")
                    #endif
                    inCompletion(emptyResponse, LGV_MeetingSDK_Meeting_Data_Set.Error.CommunicationError.generalError(error: nil))
                }
            }.resume()
        }
    }
}
