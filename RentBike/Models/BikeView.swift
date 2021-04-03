//
//  BikeView.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 07.03.2021.
//

import Foundation
import MapKit

class BikeMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            // 1
            guard let artwork = newValue as? BikeAnnotataion else {
                return
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            // 2
            markerTintColor = artwork.markerTintColor
            glyphImage = artwork.image
        }
    }
}

class BikeView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? BikeAnnotataion else {
                return
            }

            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48)))
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "bike"), for: .normal)
            rightCalloutAccessoryView = mapsButton

            image = artwork.image

            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = artwork.subtitle
            detailCalloutAccessoryView = detailLabel
        }
    }
}
