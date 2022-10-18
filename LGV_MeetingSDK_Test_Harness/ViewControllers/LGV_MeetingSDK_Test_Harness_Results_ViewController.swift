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
     The meeting that is being represented by this cell.
     */
    var meetingObject: LGV_MeetingSDK_Meeting_Protocol?
    
    /* ################################################################## */
    /**
     The label that displays the day of the week.
     */
    @IBOutlet weak var weekdayLabel: UILabel?
    
    /* ################################################################## */
    /**
     The label that displays the start time.
     */
    @IBOutlet weak var startTimeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The label that displays the meeting name.
     */
    @IBOutlet weak var meetingNameLabel: UILabel?
    
    /* ################################################################## */
    /**
     The label that displays the physical address of the meeting.
     */
    @IBOutlet weak var addressLabel: UILabel?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_TableViewCell {
    /* ################################################################## */
    /**
     Called as the cell is about to lay out everything.
     We use this to initialize everything.
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
        
        selectedBackgroundView = UIView(frame: bounds)
        selectedBackgroundView?.backgroundColor = .white.withAlphaComponent(0.15)
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
     The table that displays the results.
     */
    @IBOutlet weak var resulsTableView: UITableView?
    
    /* ################################################################## */
    /**
     The bar button item that displays our edit button.
     **NOTE:** This is displayed in the Tab Controller NavBar Item; not ours.
     */
    weak var editBarButtonItem: UIBarButtonItem?
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController {
    /* ################################################################## */
    /**
     This looks at the current selection, and enables/disables the search bar button, accordingly.
     */
    func checkSelection() {
        if let meetings = appDelegateInstance?.searchData?.meetings {
            if resulsTableView?.isEditing ?? false,
               let selectedRowIndexes = resulsTableView?.indexPathsForSelectedRows,
               !meetings.isEmpty {
                let ids = selectedRowIndexes.map { meetings[$0.row].id }
                tabController?.searchBarButtonItem?.isEnabled = !ids.isEmpty
            } else {
                tabController?.searchBarButtonItem?.isEnabled = false
            }
        }
    }
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
    
    /* ################################################################## */
    /**
     Called when the view is going to appear.
     
     - parameter inAnimated: True, if the appearance is to be animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        let newBarButton = UIBarButtonItem(title: "ERROR", style: .plain, target: self, action: #selector(startEditMode))
        editBarButtonItem = newBarButton
        tabController?.navigationItem.rightBarButtonItems?.append(newBarButton)
    }
    
    /* ################################################################## */
    /**
     Called when the view has appeared.
     
     - parameter inAnimated: True, if the appearance is to be animated.
     */
    override func viewDidAppear(_ inAnimated: Bool) {
        super.viewDidAppear(inAnimated)
        endEditMode()
    }

    /* ################################################################## */
    /**
     Called when the view is going to disappear.
     
     - parameter inAnimated: True, if the disappearance is to be animated.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        guard let items = tabController?.navigationItem.rightBarButtonItems else { return }
        endEditMode()
        for item in items.enumerated() where item.element == editBarButtonItem {
            tabController?.navigationItem.rightBarButtonItems?.remove(at: item.offset)
            break
        }
    }
    
    /* ################################################################## */
    /**
     Called when the search bar button is hit. The Tab Controller calls this, first, to handle any issues.
     We use it to populate the Search Type with an ID search.
     
     - parameter: The Bar Button Item (ignored).
     */
    override func searchBarButtonItemHit(_: UIBarButtonItem) {
        if let meetings = appDelegateInstance?.searchData?.meetings,
           let selectedRowIndexes = resulsTableView?.indexPathsForSelectedRows,
           !meetings.isEmpty {
            let ids = selectedRowIndexes.map { meetings[$0.row].id }
            appDelegateInstance?.searchData = LGV_MeetingSDK_BMLT.Data_Set(searchType: .meetingID(ids: ids))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController {
    /* ################################################################## */
    /**
     Called when the edit bar button item is hit.
     
     - parameter: The Bar Button Item (ignored).
     */
    @objc func startEditMode(_: UIBarButtonItem! = nil) {
        editBarButtonItem?.title = "SLUG-CANCEL-BUTTON-TEXT".localizedVariant
        editBarButtonItem?.accessibilityHint = "SLUG-CANCEL-BUTTON-TEXT".accessibilityLocalizedVariant
        editBarButtonItem?.target = self
        editBarButtonItem?.action = #selector(endEditMode)
        resulsTableView?.isEditing = true
        checkSelection()
    }
    
    /* ################################################################## */
    /**
     Called when the cancel Bar Button Item is hit.
     
     - parameter: The Bar Button Item (ignored).
     */
    @objc func endEditMode(_: UIBarButtonItem! = nil) {
        editBarButtonItem?.title = "SLUG-EDIT-BUTTON-TEXT".localizedVariant
        editBarButtonItem?.accessibilityHint = "SLUG-EDIT-BUTTON-TEXT".accessibilityLocalizedVariant
        editBarButtonItem?.target = self
        editBarButtonItem?.action = #selector(startEditMode)
        resulsTableView?.isEditing = false
        resulsTableView?.reloadData()
        tabController?.searchBarButtonItem?.isEnabled = false
    }
    
    /* ################################################################## */
    /**
     Forces the table to update, and scrolls to the top.
     */
    func updateUI() {
        endEditMode()
        if !(searchData?.meetings.isEmpty ?? true) {
            resulsTableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UITableViewDataSource Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Results_ViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     Returns the number of rows.
     
     - parameter: The table instance (ignored).
     - parameter numberOfRowsInSection: The section index (also ignored).
     
     - returns: The number of rows (the number of found meetings).
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int {
        let ret = appDelegateInstance?.searchData?.meetings.count ?? 0
        
        if 0 == ret {
            resulsTableView?.isEditing = false
            tabController?.searchBarButtonItem?.isEnabled = false
        } else {
            tabController?.searchBarButtonItem?.isEnabled = (resulsTableView?.isEditing ?? false)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Makes one meeting row.
     
     - parameter inTableView: The table asking for the row.
     - parameter cellForRowAt: The IndexPath of the requested row.
     
     - returns: A new meeting cell.
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
    /* ################################################################## */
    /**
     Called when the user selects a row.
     
     - parameter inTableView: The table view.
     - parameter didSelectRowAt: The IndexPath of the row we are selecting.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        checkSelection()
    }
    
    /* ################################################################## */
    /**
     Called when the user deselects a row.
     
     - parameter inTableView: The table view.
     - parameter didDeselectRowAt: The IndexPath of the row we are un-selecting.
     */
    func tableView(_ inTableView: UITableView, didDeselectRowAt inIndexPath: IndexPath) {
        checkSelection()
    }
}
