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
import RVS_Generic_Swift_Toolbox
import RVS_UIKit_Toolbox
import RVS_Checkbox
import LGV_MeetingSDK

/* ###################################################################################################################################### */
// MARK: - Base Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This provides a base substrate, for the popovers.
 */
class LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     This is our main Tab controller.
     */
    private weak var _tabController: LGV_MeetingSDK_Test_Harness_TabController?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
    /* ################################################################## */
    /**
     This is used to refer back to the main tab view controller.
     */
    override var tabController: LGV_MeetingSDK_Test_Harness_TabController? {
        get { _tabController }
        set { _tabController = newValue }
    }

    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     We use this to select Dark Mode (always), since the screens are forced Light Mode.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
    }
}

/* ###################################################################################################################################### */
// MARK: - Set Server Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This popover allows selection of a new Root Server.
 */
class LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
    /* ################################################################## */
    /**
     The desired width of the popover (as wide as possible).
     */
    private static let _popoverWidth = CGFloat(30000)
    
    /* ################################################################## */
    /**
     The desired height of the popover.
     */
    private static let _popoverHeight = CGFloat(144)
    
    /* ################################################################## */
    /**
     This will be the Root Server selection Picker.
     */
    @IBOutlet weak var rootServerPickerView: UIPickerView?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController {
    /* ################################################################## */
    /**
     The index of the currently selected Root Server
     */
    var indexOfSelectedRootServer: Int {
        get {
            let selected = LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString
            
            for rootServerEntity in Self.rootServerList.enumerated() where rootServerEntity.element.rootURL == selected {
                return rootServerEntity.offset
            }
            
            return 0
        }
        
        set {
            LGV_MeetingSDK_Test_Harness_Prefs().rootServerURLString = Self.rootServerList[newValue].rootURL
            guard let rootURL = Self.currentRootServer?.rootURL else { return }
            
            tabController?.setSDKToThisRootServerURL(rootURL)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController {
    /* ################################################################## */
    /**
     The size that we'd like our popover to be.
     */
    override var preferredContentSize: CGSize {
        get { CGSize(width: Self._popoverWidth, height: Self._popoverHeight) }
        set { super.preferredContentSize = newValue }
    }
    
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        rootServerPickerView?.selectRow(indexOfSelectedRootServer, inComponent: 0, animated: true)
    }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDataSource Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: UIPickerViewDataSource {
    /* ################################################################## */
    /**
     The number of components (always 1)
     
     - parameter in: The picker view instance (ignored).
     
     - return: 1 (always)
     */
    func numberOfComponents(in: UIPickerView) -> Int { 1 }
    
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter numberOfRowsInComponent: The component we're checking (only one, so ignored).
     
     - returns: The number of rows (the number of Root Servers).
     */
    func pickerView(_: UIPickerView, numberOfRowsInComponent: Int) -> Int { Self.rootServerList.count }
}

/* ###################################################################################################################################### */
// MARK: UIPickerViewDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Set_Server_Popover_ViewController: UIPickerViewDelegate {
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter titleForRow: The row, for the selected Root Server.
     - parameter forComponent: The component we're checking (only one, so ignored).
     
     - returns: A String, with the URL title.
     */
    func pickerView(_: UIPickerView, titleForRow inRow: Int, forComponent: Int ) -> String? { Self.rootServerList[inRow].name }
    
    /* ################################################################## */
    /**
     The number of rows in the component
     
     - parameter: The picker view instance (ignored).
     - parameter titleForRow: The row, for the selected Root Server.
     - parameter forComponent: The component we're checking (only one, so ignored).
     */
    func pickerView(_: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        indexOfSelectedRootServer = inRow
    }
}

/* ###################################################################################################################################### */
// MARK: - Select Refinements Popover View Controller Class -
/* ###################################################################################################################################### */
/**
 This popover allows selection of refinements, before a search.
 */
class LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController: LGV_MeetingSDK_Test_Harness_Base_Popover_ViewController {
    /* ################################################################################################################################## */
    // MARK: Segment Index Enum
    /* ################################################################################################################################## */
    /**
     The indexes of our segmented switch.
     */
    enum SegmentIndexes: Int {
        /* ############################################################## */
        /**
         Any start time.
         */
        case anyTime
        
        /* ############################################################## */
        /**
         Start time must fall within a certain range.
         */
        case timeRange
    }
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day1Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day1Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day2Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day2Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day3Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day3Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day4Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day4Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day5Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day5Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day6Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day6Label: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day7Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var day7Label: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var startTimeSegmentedControl: UISegmentedControl?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var timeConstraintsStackView: UIStackView?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var fromTimeLabel: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var fromStepper: UIStepper?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var toTimeLabel: UILabel?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var toStepper: UIStepper?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var searchTextTextField: UITextField?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var relateToMeSwitch: LGV_MeetingSDK_Test_Harness_CustomUISwitch?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var relateToMeLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var searchButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded and initialized.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        for segmentIndex in (0..<(startTimeSegmentedControl?.numberOfSegments ?? 0)) {
            startTimeSegmentedControl?.setTitle(startTimeSegmentedControl?.titleForSegment(at: segmentIndex)?.localizedVariant, forSegmentAt: segmentIndex)
        }

        startTimeSegmentedControl?.accessibilityHint = "SLUG-TIME-RANGE-SEGMENTED-SWITCH".accessibilityLocalizedVariant
        fromTimeLabel?.accessibilityHint = "SLUG-TIME-RANGE-LOWER".accessibilityLocalizedVariant
        toTimeLabel?.accessibilityHint = "SLUG-TIME-RANGE-UPPER".accessibilityLocalizedVariant

        searchTextTextField?.placeholder = searchTextTextField?.placeholder?.localizedVariant
        
        searchButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton?.titleLabel?.minimumScaleFactor = 0.5
        searchButton?.accessibilityHint = searchButton?.title(for: .normal)?.accessibilityLocalizedVariant
        searchButton?.setTitle(searchButton?.title(for: .normal)?.localizedVariant, for: .normal)
        
        let shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
        
        let weekdayIndexes: [Int] = (0..<7).map { localizeWeedayIndex($0) }
        day1Label?.text = shortWeekdaySymbols[weekdayIndexes[0]]
        day2Label?.text = shortWeekdaySymbols[weekdayIndexes[1]]
        day3Label?.text = shortWeekdaySymbols[weekdayIndexes[2]]
        day4Label?.text = shortWeekdaySymbols[weekdayIndexes[3]]
        day5Label?.text = shortWeekdaySymbols[weekdayIndexes[4]]
        day6Label?.text = shortWeekdaySymbols[weekdayIndexes[5]]
        day7Label?.text = shortWeekdaySymbols[weekdayIndexes[6]]
        
        setUpUI()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
    /* ################################################################## */
    /**
     This adjusts the selection to match the week start (localization).
     
     - parameter inWeekdayIndex: The 0-based index of the selected weekday, in the current locale.
     
     - returns: The adjusted weekday index, in the 0 = Sunday locale.
     */
    func normalizeWeekdayIndex(_ inWeekdayIndex: Int) -> Int {
        var weekdayIndex = (inWeekdayIndex - 1) + Calendar.current.firstWeekday
        
        if 6 < weekdayIndex {
            weekdayIndex -= 7
        }
        
        return weekdayIndex
    }
    
    /* ################################################################## */
    /**
     This adjusts the selection to match the week start (localization).
     
     - parameter inWeekdayIndex: The 0-based index of the selected weekday, in the 0 = Sunday locale.
     
     - returns: The adjusted weekday index, with 0 being the week start day.
     */
    func localizeWeedayIndex(_ inWeekdayIndex: Int) -> Int {
        var weekdayIndex = Calendar.current.firstWeekday + inWeekdayIndex
        
        if 7 < weekdayIndex {
            weekdayIndex -= 7
        }
        
        return weekdayIndex - 1
    }
    
    /* ################################################################## */
    /**
     This sets up the UI, according to the current search data refinements.
     */
    func setUpUI() {
        guard let searchRefinements = searchData?.searchRefinements else { return }
        day1Checkbox?.isOn = true
        day2Checkbox?.isOn = true
        day3Checkbox?.isOn = true
        day4Checkbox?.isOn = true
        day5Checkbox?.isOn = true
        day6Checkbox?.isOn = true
        day7Checkbox?.isOn = true
        startTimeSegmentedControl?.selectedSegmentIndex = SegmentIndexes.anyTime.rawValue
        searchRefinements.forEach { refinement in
            switch refinement {
            case let .startTimeRange(startRange):
                if !startRange.isEmpty {
                    startTimeSegmentedControl?.selectedSegmentIndex = SegmentIndexes.timeRange.rawValue
                    timeConstraintsStackView?.isHidden = false
                    fromTimeLabel?.text = String(format: "%04d", startRange.lowerBound)
                    fromStepper?.minimumValue = 0
                    fromStepper?.value = Double(startRange.lowerBound)
                    toStepper?.minimumValue = startRange.lowerBound + (fromStepper?.stepValue ?? 0)
                    toTimeLabel?.text = String(format: "%04d", startRange.upperBound)
                    fromStepper?.maximumValue = startRange.upperBound - (toStepper?.stepValue ?? 0)
                    toStepper?.value = Double(startRange.upperBound)
                } else {
                    timeConstraintsStackView?.isHidden = false
                }
                
            case let .weekdays(weekdays):
                if !weekdays.isEmpty,
                   7 > weekdays.count {
                    day1Checkbox?.isOn = false
                    day2Checkbox?.isOn = false
                    day3Checkbox?.isOn = false
                    day4Checkbox?.isOn = false
                    day5Checkbox?.isOn = false
                    day6Checkbox?.isOn = false
                    day7Checkbox?.isOn = false
                    weekdays.forEach { weekday in
                        let weekdayIndex = localizeWeedayIndex(weekday.rawValue)
                        switch weekdayIndex {
                        case 0:
                            day1Checkbox?.isOn = true
                            
                        case 1:
                            day2Checkbox?.isOn = true
                            
                        case 2:
                            day3Checkbox?.isOn = true
                            
                        case 3:
                            day4Checkbox?.isOn = true
                            
                        case 4:
                            day5Checkbox?.isOn = true
                            
                        case 5:
                            day6Checkbox?.isOn = true
                            
                        case 6:
                            day7Checkbox?.isOn = true
                            
                        default:
                            break
                        }
                    }
                }
                
            default:
                break
            }
        }
        
        timeConstraintsStackView?.isHidden = SegmentIndexes.anyTime.rawValue == startTimeSegmentedControl?.selectedSegmentIndex
    }
    
    /* ################################################################## */
    /**
     This scans the UI elements, and creates a search refinement set, based on them.
     */
    var calculatedSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>? {
        var ret: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = []
        
        if SegmentIndexes.timeRange.rawValue == startTimeSegmentedControl?.selectedSegmentIndex,
           let startValueText = fromTimeLabel?.text,
           let startTimeAsInt = Int(startValueText),
           (0..<2360).contains(startTimeAsInt),
           let endValueText = toTimeLabel?.text,
           let endTimeAsInt = Int(endValueText),
           (0..<2360).contains(endTimeAsInt),
           endTimeAsInt > startTimeAsInt {
            let startHours = startTimeAsInt / 100
            let startMinutes = startTimeAsInt - (startHours * 100)
            let endHours = endTimeAsInt / 100
            let endMinutes = endTimeAsInt - (startHours * 100)
            let lowerBound = TimeInterval((startHours * 60 * 60) + (startMinutes * 60))
            let upperBound = TimeInterval((endHours * 60 * 60) + (endMinutes * 60))
            
            ret.insert(.startTimeRange(lowerBound...upperBound))
        }
        
        var weekdays: Set<LGV_MeetingSDK_Meeting_Data_Set.Weekdays> = []
        
        if day1Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(0) + 1) {
            weekdays.insert(weekday)
        }
        
        if day2Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(1) + 1) {
            weekdays.insert(weekday)
        }
        
        if day3Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(2) + 1) {
            weekdays.insert(weekday)
        }
        
        if day4Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(3) + 1) {
            weekdays.insert(weekday)
        }
        
        if day5Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(4) + 1) {
            weekdays.insert(weekday)
        }
        
        if day6Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(5) + 1) {
            weekdays.insert(weekday)
        }
        
        if day7Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: normalizeWeekdayIndex(6) + 1) {
            weekdays.insert(weekday)
        }

        if !weekdays.isEmpty,
           7 > weekdays.count {
            ret.insert(.weekdays(weekdays))
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
    /* ################################################################## */
    /**
     */
    @IBAction func fromStepperChanged(_ inStepper: UIStepper) {
        let hours = Int(inStepper.value) / 100
        let minutes = Int(inStepper.value) - (hours * 100)
        
        guard let currentFromTimeText = fromTimeLabel?.text,
              let currentFromTime = Int(currentFromTimeText)
        else { return }
        
        let newValue = (hours * 100) + minutes
        
        if newValue < currentFromTime {
            
        } else {
            
        }
        
        fromTimeLabel?.text = String(format: "%04d", Int(newValue))
        toStepper?.minimumValue = Double(newValue + Int(inStepper.stepValue))
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func toStepperChanged(_ inStepper: UIStepper) {
        let hours = Int(inStepper.value) / 100
        let minutes = Int(inStepper.value) - (hours * 100)
        
        guard let currentToTimeText = toTimeLabel?.text,
              let currentToTime = Int(currentToTimeText)
        else { return }
        
        let newValue = (hours * 100) + minutes
        
        if newValue < currentToTime {
            
        } else {
            
        }

        toTimeLabel?.text = String(format: "%04d", Int(newValue))
        fromStepper?.maximumValue = Double(newValue - Int(inStepper.stepValue))
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func relateToMeHit(_ inControl: UIControl) {
        if inControl is UIButton {
            relateToMeSwitch?.setOn(!(relateToMeSwitch?.isOn ?? true), animated: true)
            relateToMeSwitch?.sendActions(for: .valueChanged)
        } else {
            
        }
    }

    /* ################################################################## */
    /**
     */
    @IBAction func startTimeSegmentedControlChanged(_ inStartTimeSegmentedControl: UISegmentedControl) {
        if SegmentIndexes.timeRange.rawValue == inStartTimeSegmentedControl.selectedSegmentIndex {
            timeConstraintsStackView?.isHidden = false
            fromTimeLabel?.text = "0000"
            fromStepper?.minimumValue = 0
            fromStepper?.value = 0
            toStepper?.minimumValue = 0
            toTimeLabel?.text = "2400"
            fromStepper?.maximumValue = 2355
            toStepper?.value = 2400
        } else {
            timeConstraintsStackView?.isHidden = false
        }
    }

    /* ################################################################## */
    /**
     */
    @IBAction func searchButtonHit(_: Any) {
        guard let searchType = searchData?.searchType,
              let searchRefinements = calculatedSearchRefinements,
              let searchCallbackHandler = tabController?.searchCallbackHandler
        else { return }
        
        tabController?.mapViewController?.isBusy = true
        appDelegateInstance?.searchData = LGV_MeetingSDK_BMLT.Data_Set(searchType: searchType, searchRefinements: searchRefinements)
        tabController?.selectedIndex = LGV_MeetingSDK_Test_Harness_TabController.TabIndexes.search.rawValue
        tabController?.sdk?.meetingSearch(type: searchType, refinements: searchRefinements, completion: searchCallbackHandler)
        dismiss(animated: true)
    }
}
