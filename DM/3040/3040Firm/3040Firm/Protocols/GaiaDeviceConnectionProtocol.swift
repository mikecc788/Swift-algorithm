//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc enum GaiaDeviceConnectionChannel: Int { // <- Cruft required for Obj-C interop.
    case command
    case response
    case data
}

@objc protocol GaiaDeviceConnectionProtocol: class { // <- Cruft required for Obj-C interop.
    var delegate: GaiaDeviceConnectionDelegate? { get set }

    var uuid: UUID { get }
    var name: String { get }
    var connected: Bool { get }
    var available: Bool { get }
    var rssi: Int { get }

    var isDataLengthExtensionSupported: Bool { get }
    var maximumWriteLength: Int { get }
    var maximumWriteWithoutResponseLength: Int { get }

    func sendData(channel: GaiaDeviceConnectionChannel, payload:Data, responseExpected: Bool)
    func fetchValue(channel: GaiaDeviceConnectionChannel)
}

@objc protocol GaiaDeviceConnectionDelegate: class { // <- Cruft required for Obj-C interop.
    func rssiDidChange()
    func connectionAvailable()
    func connectionUnavailable()

    func dataReceived(_ data: Data, channel: GaiaDeviceConnectionChannel)
    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?)
}
