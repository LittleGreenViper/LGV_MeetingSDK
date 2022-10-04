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

import UIKit
import LGV_MeetingSDK
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Each Search Result Table Row -
/* ###################################################################################################################################### */
/**
 This class defines a custom table cell for each row of the results table.
 */
class LGV_MeetingSDK_Test_Harness_Results_TableViewCell: UITableViewCell {
    /* ################################################################## */
    /**
     */
    var meetingObject: LGV_MeetingSDK_Meeting_Protocol?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var weekdayLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var startTimeLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var meetingNameLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var addressLabel: UILabel?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_TableViewCell {
    /* ################################################################## */
    /**
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let meetingObject = meetingObject else { return }
        let shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
        weekdayLabel?.text = shortWeekdaySymbols[Int.localizeWeedayIndex(meetingObject.weekdayIndex - 1)]
        startTimeLabel?.text = String(format: "%04d", meetingObject.meetingStartTime)
        meetingNameLabel?.text = meetingObject.name
        if .virtualOnly == meetingObject.meetingType {
            addressLabel?.text = "SLUG-VIRTUAL-ONLY-TEXT".localizedVariant
        } else {
            addressLabel?.text = meetingObject.simpleLocationText
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Manual Search View Controller Class -
/* ###################################################################################################################################### */
/**
 This displays the manual search controller.
 */
class LGV_MeetingSDK_Test_Harness_Results_ViewController: LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var resulsTableView: UITableView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController {
    /* ################################################################## */
    /**
     */
    func startEditMode() {
        
    }
    
    /* ################################################################## */
    /**
     */
    func endEditMode() {
        
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController {
}

/* ###################################################################################################################################### */
// MARK: UITableViewDataSource Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int { appDelegateInstance?.searchData?.meetings.count ?? 0 }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let meeting = appDelegateInstance?.searchData?.meetings[inIndexPath.row],
           let cell = inTableView.dequeueReusableCell(withIdentifier: "LGV_MeetingSDK_Test_Harness_Results_TableViewCell") as? LGV_MeetingSDK_Test_Harness_Results_TableViewCell {
            cell.meetingObject = meeting
            return cell
        }
        return UITableViewCell()
    }
}

/* ###################################################################################################################################### */
// MARK: UITableViewDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController: UITableViewDelegate {
    
}
