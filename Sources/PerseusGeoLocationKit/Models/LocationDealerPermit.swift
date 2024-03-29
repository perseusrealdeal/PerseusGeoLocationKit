//
//  LocationDealerPermit.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import Foundation
import CoreLocation

public enum LocationDealerPermit: CustomStringConvertible {

    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .deniedForAllAndRestricted:
            return "deniedForAllAndRestricted"
        case .restricted:
            return "restricted"
        case .deniedForAllApps:
            return "deniedForAllApps"
        case .deniedForTheApp:
            return "deniedForTheApp"
        case .allowed:
            return "allowed"
        }
    }

    // Location service is neither restricted nor the app denided.
    case notDetermined

    // Go to Settings > General > Restrictions.
    // In case if location services turned off and the app restricted.
    case deniedForAllAndRestricted
    // In case if location services turned on and the app restricted.
    case restricted

    // Go to Settings > Privacy.
    // In case if location services turned off but the app not restricted.
    case deniedForAllApps

    // Go to Settings > The App.
    // In case if location services turned on but the app not restricted.
    case deniedForTheApp

    // Either authorizedAlways or authorizedWhenInUse.
    case allowed
}

public func getPermit(serviceEnabled: Bool,
                      status: CLAuthorizationStatus) -> LocationDealerPermit {

    // There is no status .notDetermined with serviceEnabled false.
    if status == .notDetermined { // So, serviceEnabled takes true.
        return .notDetermined
    }

    if status == .denied {
        return serviceEnabled ? .deniedForTheApp : .deniedForAllApps
    }

    if status == .restricted {
        return serviceEnabled ? .restricted : .deniedForAllAndRestricted
    }

    return .allowed
}
