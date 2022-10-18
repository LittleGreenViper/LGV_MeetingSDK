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
    // MARK: Start Time Segment Index Enum
    /* ################################################################################################################################## */
    /**
     The indexes of our time range segmented switch.
     */
    enum StartTimeSegmentIndexes: Int {
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
    
    /* ################################################################################################################################## */
    // MARK: Venue Type Segment Index Enum
    /* ################################################################################################################################## */
    /**
     The indexes of our venue type segmented switch.
     */
    enum VenueTypeSegmentIndexes: Int {
        /* ############################################################## */
        /**
         Any venue.
         */
        case anyVenue
        
        /* ############################################################## */
        /**
         Choose venue type[s].
         */
        case selectedVenues
    }
    
    /* ################################################################## */
    /**
     The desired width of the popover (as wide as possible).
     */
    private static let _popoverWidth = CGFloat(300)
    
    /* ################################################################## */
    /**
     The desired height of the popover.
     */
    private static let _popoverHeight = CGFloat(454)
    
    /* ################################################################## */
    /**
     The checkbox for the first weekday.
     */
    @IBOutlet weak var day1Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the first weekday.
     */
    @IBOutlet weak var day1Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the second weekday.
     */
    @IBOutlet weak var day2Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the second weekday.
     */
    @IBOutlet weak var day2Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the third weekday.
     */
    @IBOutlet weak var day3Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the third weekday.
     */
    @IBOutlet weak var day3Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the fourth weekday.
     */
    @IBOutlet weak var day4Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the fourth weekday.
     */
    @IBOutlet weak var day4Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the fifth weekday.
     */
    @IBOutlet weak var day5Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the fifth weekday.
     */
    @IBOutlet weak var day5Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the sixth weekday.
     */
    @IBOutlet weak var day6Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the sixth weekday.
     */
    @IBOutlet weak var day6Label: UILabel?

    /* ################################################################## */
    /**
     The checkbox for the seventh weekday.
     */
    @IBOutlet weak var day7Checkbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the seventh weekday.
     */
    @IBOutlet weak var day7Label: UILabel?
    
    /* ################################################################## */
    /**
     The segmented control that determines whether or not we will specify a start time range.
     */
    @IBOutlet weak var startTimeSegmentedControl: UISegmentedControl?

    /* ################################################################## */
    /**
     The stack view that contains the text items and steppers for our start time range.
     */
    @IBOutlet weak var timeConstraintsStackView: UIStackView?

    /* ################################################################## */
    /**
     The label that displays the lower bound of the range (in military time).
     */
    @IBOutlet weak var fromTimeLabel: UILabel?

    /* ################################################################## */
    /**
     The stepper that increments or decrements the lower bound.
     */
    @IBOutlet weak var fromStepper: UIStepper?
    
    /* ################################################################## */
    /**
     The label that displays the upper bound of the range (in military time).
     */
    @IBOutlet weak var toTimeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The stepper that increments or decrements the upper bound.
     */
    @IBOutlet weak var toStepper: UIStepper?
    
    /* ################################################################## */
    /**
     The text field for entering a text search filter.
     */
    @IBOutlet weak var searchTextTextField: UITextField?
    
    /* ################################################################## */
    /**
     The switch that says "relate the locations to me."
     */
    @IBOutlet weak var relateToMeSwitch: LGV_MeetingSDK_Test_Harness_CustomUISwitch?
    
    /* ################################################################## */
    /**
     The "label" for the above (It's really a button).
     */
    @IBOutlet weak var relateToMeLabelButton: UIButton?
    
    /* ################################################################## */
    /**
     The segmented control that determines whether or not we will be choosing a venue type.
     */
    @IBOutlet weak var venueTypeSegmentedControl: UISegmentedControl?
    
    /* ################################################################## */
    /**
     The view that holds the venue type checkboxes.
     */
    @IBOutlet weak var venueTypeView: UIView?
    
    /* ################################################################## */
    /**
     The checkbox for the phyiscal meeting location.
     */
    @IBOutlet weak var physicalVenueTypeCheckbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the phyiscal meeting location.
     */
    @IBOutlet weak var physicalVenueTypeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The checkbox for the virtual meeting location.
     */
    @IBOutlet weak var virtualVenueTypeCheckbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the virtual meeting location.
     */
   @IBOutlet weak var virtualVenueTypeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The checkbox for the hybrid meeting location.
     */
    @IBOutlet weak var hybridVenueTypeCheckbox: RVS_Checkbox?
    
    /* ################################################################## */
    /**
     The label for the hybrid meeting location.
    */
    @IBOutlet weak var hybridVenueTypeLabel: UILabel?
    
    /* ################################################################## */
    /**
     The button for executing a search.
     */
    @IBOutlet weak var searchButton: UIButton?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
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
     Called when the view hierarchy has loaded and initialized.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        for segmentIndex in (0..<(startTimeSegmentedControl?.numberOfSegments ?? 0)) {
            startTimeSegmentedControl?.setTitle(startTimeSegmentedControl?.titleForSegment(at: segmentIndex)?.localizedVariant, forSegmentAt: segmentIndex)
        }

        startTimeSegmentedControl?.accessibilityHint = "SLUG-TIME-RANGE-SEGMENTED-SWITCH".accessibilityLocalizedVariant
        fromStepper?.accessibilityHint = "SLUG-TIME-RANGE-LOWER".accessibilityLocalizedVariant
        toStepper?.accessibilityHint = "SLUG-TIME-RANGE-UPPER".accessibilityLocalizedVariant
        fromTimeLabel?.accessibilityHint = "SLUG-TIME-RANGE-LOWER".accessibilityLocalizedVariant
        toTimeLabel?.accessibilityHint = "SLUG-TIME-RANGE-UPPER".accessibilityLocalizedVariant

        searchTextTextField?.placeholder = searchTextTextField?.placeholder?.localizedVariant
        
        let shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
        
        let weekdayIndexes: [Int] = (0..<7).map { Int.localizeWeedayIndex($0) }
        day1Label?.text = shortWeekdaySymbols[weekdayIndexes[0]]
        day2Label?.text = shortWeekdaySymbols[weekdayIndexes[1]]
        day3Label?.text = shortWeekdaySymbols[weekdayIndexes[2]]
        day4Label?.text = shortWeekdaySymbols[weekdayIndexes[3]]
        day5Label?.text = shortWeekdaySymbols[weekdayIndexes[4]]
        day6Label?.text = shortWeekdaySymbols[weekdayIndexes[5]]
        day7Label?.text = shortWeekdaySymbols[weekdayIndexes[6]]
        
        relateToMeSwitch?.accessibilityHint = relateToMeLabelButton?.title(for: .normal)?.accessibilityLocalizedVariant
        
        relateToMeLabelButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        relateToMeLabelButton?.titleLabel?.minimumScaleFactor = 0.5
        relateToMeLabelButton?.titleLabel?.textAlignment = .left
        relateToMeLabelButton?.accessibilityHint = relateToMeLabelButton?.title(for: .normal)?.accessibilityLocalizedVariant
        relateToMeLabelButton?.setTitle(relateToMeLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        
        for segmentIndex in (0..<(venueTypeSegmentedControl?.numberOfSegments ?? 0)) {
            venueTypeSegmentedControl?.setTitle(venueTypeSegmentedControl?.titleForSegment(at: segmentIndex)?.localizedVariant, forSegmentAt: segmentIndex)
        }
        
        physicalVenueTypeLabel?.text = physicalVenueTypeLabel?.text?.localizedVariant
        virtualVenueTypeLabel?.text = virtualVenueTypeLabel?.text?.localizedVariant
        hybridVenueTypeLabel?.text = hybridVenueTypeLabel?.text?.localizedVariant
        
        searchButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton?.titleLabel?.minimumScaleFactor = 0.5
        searchButton?.accessibilityHint = searchButton?.title(for: .normal)?.accessibilityLocalizedVariant
        searchButton?.setTitle(searchButton?.title(for: .normal)?.localizedVariant, for: .normal)

        setUpUI()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Refinements_Popover_ViewController {
    /* ################################################################## */
    /**
     This sets up the UI, as defaults.
     */
    func setUpUI() {
        day1Checkbox?.isOn = true
        day2Checkbox?.isOn = true
        day3Checkbox?.isOn = true
        day4Checkbox?.isOn = true
        day5Checkbox?.isOn = true
        day6Checkbox?.isOn = true
        day7Checkbox?.isOn = true
        startTimeSegmentedControl?.selectedSegmentIndex = StartTimeSegmentIndexes.anyTime.rawValue
        timeConstraintsStackView?.isHidden = true
        fromTimeLabel?.text = "0000"
        toTimeLabel?.text = "2400"
        fromStepper?.minimumValue = 0
        fromStepper?.maximumValue = 1435
        fromStepper?.stepValue = 5
        fromStepper?.value = 0
        toStepper?.minimumValue = 5
        toStepper?.maximumValue = 1440
        toStepper?.stepValue = 5
        toStepper?.value = 1440
        searchTextTextField?.text = ""
        relateToMeSwitch?.isOn = false
        venueTypeSegmentedControl?.selectedSegmentIndex = VenueTypeSegmentIndexes.anyVenue.rawValue
        venueTypeView?.isHidden = true
    }
    
    /* ################################################################## */
    /**
     This scans the UI elements, and creates a search refinement set, based on them.
     */
    var calculatedSearchRefinements: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements>? {
        var ret: Set<LGV_MeetingSDK_Meeting_Data_Set.Search_Refinements> = []
        
        if StartTimeSegmentIndexes.timeRange.rawValue == startTimeSegmentedControl?.selectedSegmentIndex,
           let startTime = fromStepper?.value,
           let endTime = toStepper?.value,
           (0..<1436).contains(startTime),
           endTime > startTime,
           (startTime..<1441).contains(endTime) {
            
            ret.insert(.startTimeRange(TimeInterval(startTime * 60)...TimeInterval(endTime * 60)))
        }
        
        var weekdays: Set<LGV_MeetingSDK_Meeting_Data_Set.Weekdays> = []
        
        if day1Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(0) + 1) {
            weekdays.insert(weekday)
        }
        
        if day2Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(1) + 1) {
            weekdays.insert(weekday)
        }
        
        if day3Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(2) + 1) {
            weekdays.insert(weekday)
        }
        
        if day4Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(3) + 1) {
            weekdays.insert(weekday)
        }
        
        if day5Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(4) + 1) {
            weekdays.insert(weekday)
        }
        
        if day6Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(5) + 1) {
            weekdays.insert(weekday)
        }
        
        if day7Checkbox?.isOn ?? false,
           let weekday = LGV_MeetingSDK_Meeting_Data_Set.Weekdays(rawValue: Int.normalizeWeekdayIndex(6) + 1) {
            weekdays.insert(weekday)
        }

        if !weekdays.isEmpty,
           7 > weekdays.count {
            ret.insert(.weekdays(weekdays))
        }
        
        if let searchString = searchTextTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !searchString.isEmpty {
            ret.insert(.string(searchString: searchString))
        }
        
        if relateToMeSwitch?.isOn ?? false,
           let myLocation = LGV_MeetingSDK_Test_Harness_TabController.currentLocation {
            ret.insert(.distanceFrom(thisLocation: myLocation))
        }
        
        if VenueTypeSegmentIndexes.anyVenue.rawValue != venueTypeSegmentedControl?.selectedSegmentIndex,
           physicalVenueTypeCheckbox?.isOn ?? false || virtualVenueTypeCheckbox?.isOn ?? false || hybridVenueTypeCheckbox?.isOn ?? false,
           !(physicalVenueTypeCheckbox?.isOn ?? false && virtualVenueTypeCheckbox?.isOn ?? false && hybridVenueTypeCheckbox?.isOn ?? false) {
            var venueTypes = Set<LGV_MeetingSDK_VenueType_Enum>()
            if physicalVenueTypeCheckbox?.isOn ?? false {
                venueTypes.insert(.inPersonOnly)
            }
            if virtualVenueTypeCheckbox?.isOn ?? false {
                venueTypes.insert(.virtualOnly)
            }
            if hybridVenueTypeCheckbox?.isOn ?? false {
                venueTypes.insert(.hybrid)
            }
            
            ret.insert(.venueTypes(venueTypes))
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
     Called when one of the start time range steppers is hit.
     
     - parameter inStepper: The control that was hit.
     */
    @IBAction func stepperChanged(_ inStepper: UIStepper) {
        let hours = Int(inStepper.value / 60)
        let minutes = Int(inStepper.value) - (hours * 60)
        
        let value = Double(max(0, min(1440, (hours * 60) + minutes)))
        
        let displayedValue = String(format: "%02d%02d", hours, minutes)
        
        if inStepper == fromStepper {
            fromTimeLabel?.text = displayedValue
            toStepper?.minimumValue = max(0, value + inStepper.stepValue)
        } else {
            toTimeLabel?.text = displayedValue
            fromStepper?.maximumValue = max(1435, value - inStepper.stepValue)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the button "label" for the "Relate to Me" switch is hit.
     
     We use this to toggle the switch.
     
     - parameter: The button (ignored).
     */
    @IBAction func relateToMeHit(_: Any) {
        relateToMeSwitch?.setOn(!(relateToMeSwitch?.isOn ?? true), animated: true)
        relateToMeSwitch?.sendActions(for: .valueChanged)
    }

    /* ################################################################## */
    /**
     Called when the segmented control for the start time range is hit.
     
     - parameter inStartTimeSegmentedControl: The start time segmented control.
     */
    @IBAction func startTimeSegmentedControlChanged(_ inStartTimeSegmentedControl: UISegmentedControl) {
        timeConstraintsStackView?.isHidden = StartTimeSegmentIndexes.anyTime.rawValue == inStartTimeSegmentedControl.selectedSegmentIndex
    }

    /* ################################################################## */
    /**
     Called when the segmented control for the venue type is hit.
     
     - parameter inStartTimeSegmentedControl: The venue type segmented control.
     */
    @IBAction func venueTypeSegmentedControlChanged(_ inVenueTypeSegmentedControl: UISegmentedControl) {
        venueTypeView?.isHidden = VenueTypeSegmentIndexes.anyVenue.rawValue == inVenueTypeSegmentedControl.selectedSegmentIndex
    }

    /* ################################################################## */
    /**
     Called when the search button is hit.
     
     - parameter: ignored.
     */
    @IBAction func searchButtonHit(_: Any) {
        guard let searchType = searchData?.searchType,
              let searchRefinements = calculatedSearchRefinements,
              let searchCallbackHandler = tabController?.searchCallbackHandler
        else { return }
        
        tabController?.mapViewController?.isBusy = true
        appDelegateInstance?.searchData = LGV_MeetingSDK_BMLT.Data_Set(searchType: searchType, searchRefinements: searchRefinements)
        tabController?.selectedIndex = LGV_MeetingSDK_Test_Harness_TabController.TabIndexes.search.rawValue
        tabController?.sdk?.meetingSearch(type: searchType, refinements: searchRefinements, refCon: nil, completion: searchCallbackHandler)
        dismiss(animated: true)
    }
}
