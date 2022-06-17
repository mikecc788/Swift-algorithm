//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

enum GaiaDeviceVersion {
    case unknown
    case v2
    case v3
}

enum GaiaDeviceType{
	case unknown
    case earbud
    case headphones
}

protocol GaiaDeviceProtocol: class {
    init(connection: GaiaDeviceConnectionProtocol,
         notificationCenter: NotificationCenter)

    var version: GaiaDeviceVersion { get }
    var connected: Bool { get }
    var uuid: UUID { get }
    var name: String { get }
    var deviceType: GaiaDeviceType { get }
    var rssi: Int { get }

    var serialNumber: String { get }
    var secondEarbudSerialNumber: String? { get }
    var deviceVariant: String { get }
    var applicationVersion: String { get }
    var apiVersion: String { get }
    var isCharging: Bool { get }

    var supportedFeatures: [GaiaDevicePluginFeatureID] { get }
    func plugin(featureID: GaiaDevicePluginFeatureID) -> GaiaDevicePluginProtocol?

    func reset() // Used to tear down.
}
