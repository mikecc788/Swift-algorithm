//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ConnectionFactoryDelegate: class {
    func didChangeState()
    func didDiscoverDevice(_ device: GaiaDeviceProtocol)
    func didConnectDevice(_ device: GaiaDeviceProtocol)
    func didFailToConnectDevice(_ device: GaiaDeviceProtocol)
    func didDisconnectDevice(_ device: GaiaDeviceProtocol)
}

protocol ConnectionFactorySourceDelegate: class {
    func didChangeState()
    func didDiscoverDevice(_ device: GaiaDeviceProtocol)
    func didConnectDevice(_ device: GaiaDeviceProtocol)
    func didFailToConnectDevice(_ device: GaiaDeviceProtocol)
    func didDisconnectDevice(_ device: GaiaDeviceProtocol)
}

protocol ConnectionFactorySource {
    var isScanning: Bool { get }
    var isAvailable: Bool { get }
    var devices: [GaiaDeviceProtocol] { get }
    var delegate: ConnectionFactorySourceDelegate? { get set }
    func startScanning()
    func stopScanning()
    func connect(_ device: GaiaDeviceProtocol)
    func disconnect(_ device: GaiaDeviceProtocol)
}

class ConnectionFactory {
    enum ConnectionFactoryKind {
        case ble
        case replayFile(path: URL)
    }

    let kind: ConnectionFactoryKind
    weak var delegate: ConnectionFactoryDelegate?

    // BLE State
    private var connectionMethod: ConnectionFactorySource

    required init(kind: ConnectionFactoryKind, notificationCenter: NotificationCenter) {
        self.kind = kind

        switch kind {
        case .ble:
            connectionMethod = BLESource(notificationCenter: notificationCenter)
        case .replayFile(let path):
            connectionMethod = ReplayFileSource(path: path, notificationCenter: notificationCenter)
        }
        connectionMethod.delegate = self
    }

    var isScanning: Bool {
        return connectionMethod.isScanning
    }

    var isAvailable: Bool {
        return connectionMethod.isAvailable
    }

    var devices: [GaiaDeviceProtocol] {
        return connectionMethod.devices
    }

    func startScanning() {
		connectionMethod.startScanning()
    }

    func stopScanning() {
        connectionMethod.stopScanning()
    }

    func connect(_ device: GaiaDeviceProtocol) {
        connectionMethod.connect(device)
    }

    func disconnect(_ device: GaiaDeviceProtocol) {
        connectionMethod.disconnect(device)
    }
}

extension ConnectionFactory: ConnectionFactorySourceDelegate {
    func didDiscoverDevice(_ device: GaiaDeviceProtocol) {
        delegate?.didDiscoverDevice(device)
    }

    func didConnectDevice(_ device: GaiaDeviceProtocol) {
        delegate?.didConnectDevice(device)
    }

    func didFailToConnectDevice(_ device: GaiaDeviceProtocol) {
        delegate?.didFailToConnectDevice(device)
    }

    func didDisconnectDevice(_ device: GaiaDeviceProtocol) {
        delegate?.didDisconnectDevice(device)
    }

    func didChangeState() {
        delegate?.didChangeState()
    }
}
