//
//  Models.swift
//  PerseusGeoLocationKit
//
//  Created by Mikhail Zhigulin in 7531.
//
//  Copyright © 7531 Mikhail Zhigulin of Novosibirsk.
//
//  Licensed under the MIT license. See LICENSE file.
//  All rights reserved.
//

import CoreLocation

// MARK: - Data structures and functions used in library

public enum Result<Value, Error: Swift.Error> {
    case success(Value)
    case failure(Error)
}

public struct LocationAccuracy: RawRepresentable, Equatable {
    public var rawValue: CLLocationAccuracy

    // The highest possible accuracy that uses additional sensor data.
    public static let bestForNavigation = LocationAccuracy(
        rawValue: kCLLocationAccuracyBestForNavigation)

    // The best level of accuracy available.
    public static let best = LocationAccuracy(
        rawValue: kCLLocationAccuracyBest)

    // Accurate to within ten meters of the desired target.
    public static let nearestTenMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyNearestTenMeters)

    // Accurate to within one hundred meters.
    public static let hundredMeters = LocationAccuracy(
        rawValue: kCLLocationAccuracyHundredMeters)

    // Accurate to the nearest kilometer.
    public static let kilometer = LocationAccuracy(
        rawValue: kCLLocationAccuracyKilometer)

    // Accurate to the nearest three kilometers.
    public static let threeKilometers = LocationAccuracy(
        rawValue: kCLLocationAccuracyThreeKilometers)

    public init(rawValue: CLLocationAccuracy) {
        self.rawValue = rawValue
    }
}

extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse: // iOS
            return "authorizedWhenInUse"
        }
    }
}

public enum LocationAuthorization: CustomStringConvertible {

    case whenInUse
    case always

    public var description: String {
        switch self {
        case .whenInUse:
            return "When-in-use"
        case .always:
            return "Always"
        }
    }
}

public enum LocationDealerPermit: CustomStringConvertible {

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
}

public enum LocationDealerOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: // There should be no location notifying activity.
            return "None"
        case .currentLocation:
            return "Current Location"
        case .locationUpdates:
            return "Location Updates"
        case .authorization: // Used only to invoke Current Location Diolog on macOS.
            return "Authorization"
        }
    }

    case none
    case currentLocation
    case locationUpdates
    case authorization
}

public struct PerseusLocation: CustomStringConvertible, Equatable {

    // MARK: - Data Preview

    public var description: String {
        let lat = (latitude * 10000.0).rounded(latitude > 0 ? .down : .up) / 10000.0
        let lon = (longitude * 10000.0).rounded(longitude > 0 ? .down : .up) / 10000.0

        let location100 = "[\(latitudeHundredths), \(longitudeHundredths)]"
        let location10000 = "latitude = \(lat), longitude = \(lon)"

        return location100 + ": " + location10000
    }

    // MARK: - Location Data, As Is

    let location: CLLocation

    var latitude: Double { return location.coordinate.latitude }
    var longitude: Double { return location.coordinate.longitude }

    // MARK: - Location Data, Specifics

    // Cutting off to hundredths (2 decimal places).
    var latitudeHundredths: Double {
        return (latitude * 100.0).rounded(latitude > 0 ? .down : .up) / 100.0
    }

    // Cutting off to hundredths (2 decimal places).
    var longitudeHundredths: Double {
        return (longitude * 100.0).rounded(longitude > 0 ? .down : .up) / 100.0
    }

    public init(_ location: CLLocation) {
        self.location = location
    }

    public static func == (lhs: PerseusLocation, rhs: PerseusLocation) -> Bool {
        return lhs.location == rhs.location
    }
}

extension CLLocation { public var perseus: PerseusLocation { return PerseusLocation(self) } }

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
