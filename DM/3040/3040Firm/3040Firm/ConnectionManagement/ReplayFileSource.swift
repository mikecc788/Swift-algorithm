//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

protocol ScriptConnectionDelegate: class {
    func scriptConnected()
    func scriptDisconnected()
}

class ReplayFileSource: ConnectionFactorySource {
    private let testDevice: GaiaDevice
    private let testConnection: GaiaReplayScriptDeviceConnection

    var devices: [GaiaDeviceProtocol] {
        return [testDevice]
    }

    private (set) var isScanning: Bool = false
    private (set) var isAvailable: Bool = true
    weak var delegate: ConnectionFactorySourceDelegate?

    init(path: URL,
         notificationCenter: NotificationCenter) {
        testConnection = GaiaReplayScriptDeviceConnection(path: path)
        testDevice = GaiaDevice(connection: testConnection, notificationCenter: notificationCenter)
        testConnection.delegate = testDevice
        testConnection.scriptDelegate = self
    }

    func startScanning() {
        isScanning = true
        delegate?.didDiscoverDevice(testDevice)
    }

    func stopScanning() {
        isScanning = false
    }

    func connect(_ device: GaiaDeviceProtocol) {
        testConnection.connect()
    }

    func disconnect(_ device: GaiaDeviceProtocol) {
        testConnection.disconnect()
    }
}

extension ReplayFileSource: ScriptConnectionDelegate {
    func scriptConnected() {
        delegate?.didConnectDevice(testDevice)
    }

    func scriptDisconnected() {
        testDevice.reset()
        delegate?.didDisconnectDevice(testDevice)
    }
}
