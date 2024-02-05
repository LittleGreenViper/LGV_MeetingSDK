import Cocoa
import CreateML
import TabularData

func loadJSON() -> (meta: MeetingJSONParser.PageMeta, meetings: [MeetingJSONParser.Meeting])? {
    guard let jsonFileURL = Bundle.main.url(forResource: "all-meetings", withExtension: "json"),
          let jsonData = try? Data(contentsOf: jsonFileURL),
          let parser = MeetingJSONParser(jsonData: jsonData)
    else { return nil }
    
    return (meta: parser.meta, meetings: parser.meetings)
}

if let results = loadJSON() {
    print(results.meta)
    print("\n\n")
    print(results.meetings.first ?? "ERROR")
    print("\n\n")
    print(results.meetings.last ?? "ERROR")
}
//
//let classifier = try MLTextClassifier(trainingData: dataFrame, textColumn: "text", labelColumn: "sentiment")
//
//let metaData = MLModelMetadata(author: "Mohammad Azam", shortDescription: "Predicts the sentiments associated with financial news", version: "1.0")
//
//try classifier.write(toFile: "~/Desktop/FinancialNewsSentimentAnalysis.mlmodel", metadata: metaData)

