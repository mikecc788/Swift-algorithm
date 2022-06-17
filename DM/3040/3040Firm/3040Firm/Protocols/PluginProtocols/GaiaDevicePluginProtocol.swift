//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

enum GaiaDevicePluginFeatureID: UInt8 {
    case basic = 0x00
    case earbud = 0x01
    case noiseCancellation = 0x02
    case voiceAssistant = 0x03
    case debug = 0x04
    case upgrade = 0x06
    case unknown = 0x7f
}

protocol GaiaDevicePluginProtocol: class {
    init(version: UInt8,
         device: GaiaDeviceProtocol,
         connection: GaiaDeviceConnectionProtocol,
         notificationCenter: NotificationCenter)

    static var featureID: GaiaDevicePluginFeatureID { get }

    var featureID: GaiaDevicePluginFeatureID { get }
    var title: String { get }
    var subtitle: String? { get }
    
    func startPlugin()
    func stopPlugin()

    func responseReceived(messageDescription: IncomingMessageDescription)

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?)
}

extension GaiaDevicePluginProtocol {
    var featureID: GaiaDevicePluginFeatureID {
        get {
            return Self.featureID
        }
    }
}
