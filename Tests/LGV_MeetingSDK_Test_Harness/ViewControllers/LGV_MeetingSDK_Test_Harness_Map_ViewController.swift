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
import MapKit

/* ###################################################################################################################################### */
// MARK: - Map Search View Controller Class -
/* ###################################################################################################################################### */
/**
 This displays the map search controller.
 
 We display a mask, and a center circle, to indicate a search radius (or maximum radius), and a search center.
 
 The mask is attached to the map container, and allows the map to be moved around, under it.
 */
class LGV_MeetingSDK_Test_Harness_Map_ViewController: LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################## */
    /**
     We start in the center of the US.
     */
    private static let _mapCenter = CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129)

    /* ################################################################## */
    /**
     We start with a size of 2800 miles (roughly the size of the US).
     */
    private static let _mapSizeInMeters: Double = 4506163

    /* ################################################################## */
    /**
     This is how many display units we'll inset the mask (if shown) from the edges.
     */
    private static let _insetInDisplayUnits: CGFloat = 12
    
    /* ################################################################## */
    /**
     The center circle will be twice this, in diameter, in display units.
     */
    private static let _centerCircleRadiusInDisplayUnits: CGFloat = 12
    
    /* ################################################################## */
    /**
     The center circle is slightly transparent.
     */
    private static let _centerAlphaValue: CGFloat = 0.5
    
    /* ################################################################## */
    /**
     The mask is fairly transparent.
     */
    private static let _maskAlphaValue: CGFloat = 0.25

    /* ################################################################## */
    /**
     This will reference the main mask layer.
     */
    weak var circleMask: CALayer?
    
    /* ################################################################## */
    /**
     This will reference the center circle layer.
     */
    weak var centerCircle: CAShapeLayer?
    
    /* ################################################################## */
    /**
     This is the initial (default) number of meetings to be found in an auto-radius search.
     */
    private static let _defaultCount = 10

    /* ################################################################## */
    /**
     This is the segmented switch that goes between fixed radius, and auto-radius, searches.
     */
    @IBOutlet weak var modeSelectionSegmentedControl: UISegmentedControl?

    /* ################################################################## */
    /**
     This is the stack view that holds all the auto-radius extra controls.
     We hide it, when we are in fixed radius mode.
     */
    @IBOutlet weak var autoSearchStackView: UIStackView?

    /* ################################################################## */
    /**
     The label for the text entry (for the number of meetings to find, in auto-radius mode).
     */
    @IBOutlet weak var textInputLabel: UILabel?

    /* ################################################################## */
    /**
     The numerical text entry (for the number of meetings to find, in auto-radius mode).
     */
    @IBOutlet weak var textInputField: UITextField?

    /* ################################################################## */
    /**
     The switch that turns on a maximum radius for auto-radius search.
     */
    @IBOutlet weak var maxRadiusSwitch: UISwitch?

    /* ################################################################## */
    /**
     The "label" for that switch is actually a button, that toggles the switch (like a web checkbox).
     */
    @IBOutlet weak var maxRadiusLabelButton: UIButton?

    /* ################################################################## */
    /**
     This is the container for the map. We attach the two overlay layers to this.
     */
    @IBOutlet weak var mapContainerView: UIView?

    /* ################################################################## */
    /**
     The map view.
     */
    @IBOutlet weak var mapView: MKMapView?
}

/* ###################################################################################################################################### */
// MARK: Computed Properties
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     Returns true, if we should show the surrounding mask overlay.
     */
    var isCircleMaskShown: Bool {
        guard let index = modeSelectionSegmentedControl?.selectedSegmentIndex,
              let isMaxRadiusOn = maxRadiusSwitch?.isOn,
              0 == index || isMaxRadiusOn
        else { return false }
        
        return true
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        
        textInputLabel?.adjustsFontSizeToFitWidth = true
        textInputLabel?.minimumScaleFactor = 0.5
        textInputLabel?.accessibilityHint = textInputLabel?.text?.accessibilityLocalizedVariant
        textInputLabel?.text = textInputLabel?.text?.localizedVariant

        maxRadiusLabelButton?.titleLabel?.textAlignment = .left
        maxRadiusLabelButton?.setTitle(maxRadiusLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        
        for segmentIndex in (0..<(modeSelectionSegmentedControl?.numberOfSegments ?? 0)) {
            modeSelectionSegmentedControl?.setTitle(modeSelectionSegmentedControl?.titleForSegment(at: segmentIndex)?.localizedVariant, forSegmentAt: segmentIndex)
        }
        
        setAccessibilityHints()
    }
    
    /* ################################################################## */
    /**
     Called just after the subviews have been laid out.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        autoSearchStackView?.isHidden = 0 == modeSelectionSegmentedControl?.selectedSegmentIndex

        var inputText = String(Self._defaultCount)
        var mapCenter = Self._mapCenter
        var mapSizeInMeters: Double = Self._mapSizeInMeters
        
        if case let .autoRadius(centerLongLat, minimumNumberOfResults, maxRadiusInMeters) = searchData?.searchType {
            inputText = String(minimumNumberOfResults)
            mapCenter = centerLongLat
            mapSizeInMeters = maxRadiusInMeters * 2
        } else if case let .fixedRadius(centerLongLat, radiusInMeters) = searchData?.searchType {
            mapCenter = centerLongLat
            mapSizeInMeters = radiusInMeters * 2
        }

        let mapSizeInPoints = MKMapPointsPerMeterAtLatitude(mapCenter.latitude) * mapSizeInMeters
        let mapOriginInMapPoints = MKMapPoint(mapCenter)
        let offsetOrigin = MKMapPoint(x: mapOriginInMapPoints.x - (mapSizeInPoints / 2), y: mapOriginInMapPoints.y - (mapSizeInPoints / 2))
        let mapRegion = MKCoordinateRegion(MKMapRect(origin: offsetOrigin, size: MKMapSize(width: mapSizeInPoints, height: mapSizeInPoints)))
        
        textInputField?.text = inputText
        
        if let fitRegion = mapView?.regionThatFits(mapRegion) {
            mapView?.setRegion(fitRegion, animated: false)
        }

        updateTheCircleOverlay()
    }
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     This creates the main surrounding circle mask overlay.
     
     It will not be shown, if `isCircleMaskShown` is not true.
     */
    private func _setTheCircleOverlay() {
        circleMask?.removeFromSuperlayer()
        circleMask = nil
        
        if isCircleMaskShown {
            guard let mapBounds = mapContainerView?.bounds else { return }
            let squareSide = min(mapBounds.size.width, mapBounds.size.height)
            var cutoutRect = CGRect(origin: .zero, size: CGSize(width: squareSide, height: squareSide))
            cutoutRect.origin = CGPoint(x: (mapBounds.size.width - squareSide) / 2, y: (mapBounds.size.height - squareSide) / 2)
            
            let path = CGMutablePath()
            let fillPath = UIBezierPath(rect: mapBounds)
            let circlePath = UIBezierPath(ovalIn: cutoutRect)
            path.addPath(fillPath.cgPath)
            path.addPath(circlePath.cgPath)
            
            let maskLayer = CAShapeLayer()
            maskLayer.frame = mapBounds
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.path = path
            maskLayer.fillRule = .evenOdd
            
            let circleLayer = CALayer()
            circleLayer.frame = mapBounds
            circleLayer.backgroundColor = UIColor.black.withAlphaComponent(Self._maskAlphaValue).cgColor
            circleLayer.mask = maskLayer
            mapContainerView?.layer.addSublayer(circleLayer)
            circleMask = circleLayer
        }
    }
    
    /* ################################################################## */
    /**
     This creates the center circle overlay.
     */
    private func _setTheCenterOverlay() {
        centerCircle?.removeFromSuperlayer()
        centerCircle = nil
        
        guard let mapBounds = mapContainerView?.bounds else { return }
        
        let centerLayer = CAShapeLayer()
        centerLayer.fillColor = UIColor.systemRed.withAlphaComponent(Self._centerAlphaValue).cgColor
        var containerRect = CGRect(origin: .zero, size: CGSize(width: Self._centerCircleRadiusInDisplayUnits, height: Self._centerCircleRadiusInDisplayUnits))
        containerRect.origin = CGPoint(x: ((mapBounds.size.width - Self._centerCircleRadiusInDisplayUnits) / 2), y: ((mapBounds.size.height - Self._centerCircleRadiusInDisplayUnits) / 2))
        let circlePath = UIBezierPath(ovalIn: containerRect)
        centerLayer.path = circlePath.cgPath
        
        mapContainerView?.layer.addSublayer(centerLayer)
        centerCircle = centerLayer
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     This forces updates of both overlays.
     */
    func updateTheCircleOverlay() {
        _setTheCenterOverlay()
        _setTheCircleOverlay()
    }

    /* ################################################################## */
    /**
     This sets the accessibility hints.
     */
    func setAccessibilityHints() {
        textInputLabel?.accessibilityHint = "SLUG-MAX-COUNT-HINT".accessibilityLocalizedVariant
        textInputField?.accessibilityHint = "SLUG-MAX-COUNT-HINT".accessibilityLocalizedVariant
        maxRadiusSwitch?.accessibilityHint = "SLUG-MAX-RADIUS-BUTTON".accessibilityLocalizedVariant
        maxRadiusLabelButton?.accessibilityHint = "SLUG-MAX-RADIUS-BUTTON".accessibilityLocalizedVariant
        modeSelectionSegmentedControl?.accessibilityHint = "SLUG-SEGMENTED-RADIUS-SWITCH-HINT".accessibilityLocalizedVariant
    }
    
    /* ################################################################## */
    /**
     This looks at the current state of the screen, and updates the search spec (in the app delegate), to reflect it.
     */
    func recalculateSearchParameters() {
        guard let mapCenter = mapView?.centerCoordinate else { return }
        
        var requestedNumberOfMeetings = Self._defaultCount
        
        if let requestedNumberOfMeetingsText = textInputField?.text,
           let count = Int(requestedNumberOfMeetingsText) {
            requestedNumberOfMeetings = count
        }
        
        if 0 == modeSelectionSegmentedControl?.selectedSegmentIndex {
            appDelegateInstance?.searchData = LGV_MeetingSDK_BMLT.Data_Set(searchType: .fixedRadius(centerLongLat: mapCenter, radiusInMeters: 1000))
        } else {
            appDelegateInstance?.searchData = LGV_MeetingSDK_BMLT.Data_Set(searchType: .autoRadius(centerLongLat: mapCenter, minimumNumberOfResults: UInt(requestedNumberOfMeetings), maxRadiusInMeters: 1000))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     Called when the main segmented switch changes value.
     
     - parameter: ignored.
     */
    @IBAction func modeSelectionSegmentedControlHit(_: UISegmentedControl) {
        view?.setNeedsLayout()
        recalculateSearchParameters()
    }
    
    /* ################################################################## */
    /**
     This is called if either the switch, or its "label," ar hit.
     
     - parameter: Either the button, or the switch. If it is the button, the switch is toggled, and this will be called again, with the switch as the parameter.
     */
    @IBAction func maxRadiusLabelButtonOrSwitchHit(_ inButtonOrSwitch: UIControl) {
        if inButtonOrSwitch is UIButton {
            maxRadiusSwitch?.setOn(!(maxRadiusSwitch?.isOn ?? true), animated: true)
            maxRadiusSwitch?.sendActions(for: .valueChanged)
        } else {
            view?.setNeedsLayout()
            recalculateSearchParameters()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the text in the text field is changed.
     
     - parameter: ignored.
     */
    @IBAction func textChanged(_: UITextField) {
        recalculateSearchParameters()
    }
}

/* ###################################################################################################################################### */
// MARK: MKMapViewDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController: MKMapViewDelegate {
    /* ################################################################## */
    /**
     Called when the map region changes.
     
     - parameter: The map view (ignored).
     - parameter regionDidChangeAnimated: True, if the change was animated.
     */
    func mapView(_: MKMapView, regionDidChangeAnimated: Bool) {
        recalculateSearchParameters()
    }
    
    /* ################################################################## */
    /**
     Called when the map's visible region changed.
     
     - parameter: The map view (ignored).
     */
    func mapViewDidChangeVisibleRegion(_: MKMapView) {
        recalculateSearchParameters()
    }
}
