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
 */
class LGV_MeetingSDK_Test_Harness_Map_ViewController: LGV_MeetingSDK_Test_Harness_Base_ViewController {
    /* ################################################################################################################################## */
    // MARK: Custom Marker Annotation Class
    /* ################################################################################################################################## */
    /**
     */
    class CustomCenterMarkerAnnotation: MKPointAnnotation {
        /* ############################################################## */
        /**
         */
        private var _coords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        /* ############################################################## */
        /**
         */
        override var coordinate: CLLocationCoordinate2D {
            get { _coords }
            set { _coords = newValue }
        }
        
        /* ############################################################## */
        /**
         */
        var image: UIImage? { UIImage(named: "Marker") }
        
        /* ############################################################## */
        /**
         */
        init(coordinate inCoords: CLLocationCoordinate2D) {
            _coords = inCoords
        }
    }
    
    /* ################################################################## */
    /**
     */
    private static let _insetCoefficient: Double = 0.025
    
    /* ################################################################## */
    /**
     */
    weak var circleOverlay: MKCircle?
    
    /* ################################################################## */
    /**
     */
    var markerAnnotation: MKAnnotation?
    
    /* ################################################################## */
    /**
     */
    private static let _defaultCount = 10
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var mainVerticalStackView: UIStackView?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var modeSelectionSegmentedControl: UISegmentedControl?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var autoSearchStackView: UIStackView?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var textInputLabel: UILabel?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var textInputField: UITextField?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var maxRadiusSwitch: UISwitch?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var maxRadiusLabelButton: UIButton?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var mapContainerView: UIView?

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var mapView: MKMapView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
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
        autoStuffShownOrNot()
        updateTheCircleOverlay()
        setAccessibilityHints()
    }
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     */
    private func _setTheCircleOverlay() {
        if let index = modeSelectionSegmentedControl?.selectedSegmentIndex,
           0 == index || (1 == index && maxRadiusSwitch?.isOn ?? false),
           let mapRect = mapView?.visibleMapRect {
            var mapRectangle = mapRect
            let center = MKMapPoint(x: (mapRect.size.width / 2) + mapRect.origin.x, y: (mapRect.size.height / 2) + mapRect.origin.y)
            mapRectangle.size.width = min(mapRect.size.width, mapRect.size.height)
            mapRectangle.size.height = min(mapRect.size.width, mapRect.size.height)
            mapRectangle.origin = MKMapPoint(x: center.x - (mapRectangle.size.width / 2), y: center.y - (mapRectangle.size.height / 2))
            mapRectangle = mapRectangle.insetBy(dx: mapRectangle.size.width * Self._insetCoefficient, dy: mapRectangle.size.height * Self._insetCoefficient)
            let circle = MKCircle(mapRect: mapRectangle)
            circleOverlay = circle
            mapView?.addOverlay(circle)
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _setTheCenterMarker() {
        if let index = modeSelectionSegmentedControl?.selectedSegmentIndex,
           1 == index,
           let center = mapView?.centerCoordinate {
            markerAnnotation = CustomCenterMarkerAnnotation(coordinate: center)
        }
    }

    /* ################################################################## */
    /**
     */
    func autoStuffShownOrNot() {
        autoSearchStackView?.isHidden = 0 == modeSelectionSegmentedControl?.selectedSegmentIndex
        textInputField?.text = String(Self._defaultCount)
        maxRadiusSwitch?.isOn = false
    }
    
    /* ################################################################## */
    /**
     */
    func updateTheCircleOverlay() {
        if let circle = circleOverlay {
            mapView?.removeOverlay(circle)
            circleOverlay = nil
        }
        
        if let marker = markerAnnotation {
            mapView?.removeAnnotation(marker)
        }
        
        _setTheCircleOverlay()
        _setTheCenterMarker()
    }
    
    /* ################################################################## */
    /**
     */
    func setAccessibilityHints() {
        textInputLabel?.accessibilityHint = "SLUG-MAX-COUNT-HINT".accessibilityLocalizedVariant
        textInputField?.accessibilityHint = "SLUG-MAX-COUNT-HINT".accessibilityLocalizedVariant
        maxRadiusSwitch?.accessibilityHint = "SLUG-MAX-RADIUS-BUTTON".accessibilityLocalizedVariant
        maxRadiusLabelButton?.accessibilityHint = "SLUG-MAX-RADIUS-BUTTON".accessibilityLocalizedVariant
        modeSelectionSegmentedControl?.accessibilityHint = "SLUG-SEGMENTED-RADIUS-SWITCH-HINT".accessibilityLocalizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController {
    /* ################################################################## */
    /**
     */
    @IBAction func modeSelectionSegmentedControlHit(_ inSelectionSwitch: UISegmentedControl) {
        autoStuffShownOrNot()
        updateTheCircleOverlay()
    }

    /* ################################################################## */
    /**
     */
    @IBAction func textInputFieldTextChanged(_ inTextField: UITextField) {
    }

    /* ################################################################## */
    /**
     */
    @IBAction func maxRadiusLabelButtonOrSwitchHit(_ inButtonOrSwitch: UIControl) {
        if inButtonOrSwitch is UIButton {
            maxRadiusSwitch?.setOn(!(maxRadiusSwitch?.isOn ?? true), animated: true)
            maxRadiusSwitch?.sendActions(for: .valueChanged)
        } else {
            updateTheCircleOverlay()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: MKMapViewDelegate Conformance
/* ###################################################################################################################################### */
extension LGV_MeetingSDK_Test_Harness_Map_ViewController: MKMapViewDelegate {
    /* ################################################################## */
    /**
     */
    func mapView(_: MKMapView, rendererFor inOverlay: MKOverlay) -> MKOverlayRenderer {
        if inOverlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: inOverlay)
            circleRenderer.strokeColor = .red
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    /* ################################################################## */
    /**
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateTheCircleOverlay()
    }
    
    /* ################################################################## */
    /**
     */
    func mapViewDidChangeVisibleRegion(_: MKMapView) {
        updateTheCircleOverlay()
    }
    
    /* ################################################################## */
    /**
     */
    func mapView(_: MKMapView, viewFor inAnnotation: MKAnnotation) -> MKAnnotationView? {
        guard !(inAnnotation is MKUserLocation),
              let annotation = inAnnotation as? CustomCenterMarkerAnnotation
        else { return nil }
        
        var annotationView = mapView?.dequeueReusableAnnotationView(withIdentifier: "centerMarker")
        
        annotationView = annotationView ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "centerMarker")

        annotationView?.annotation = annotation
        
        annotationView?.image = annotation.image
        
        return annotationView
    }
}
