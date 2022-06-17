//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLESource: NSObject, ConnectionFactorySource {
    struct DeviceContainer {
        let index: Int
        let cbPeripheral: CBPeripheral
        let gaiaDevice: GaiaDeviceProtocol
    }
    private var _devices = [UUID: DeviceContainer] ()
    var devices: [GaiaDeviceProtocol] {
        return _devices.values.sorted(by: { $0.index < $1.index }).map { $0.gaiaDevice }
    }

    private let notificationCenter: NotificationCenter // only used to set up devices.
    private var centralManager: CBCentralManager!
    weak var delegate: ConnectionFactorySourceDelegate?

    var isScanning: Bool {
        return centralManager.isScanning
    }

    var isAvailable: Bool {
        return centralManager.state == . poweredOn
    }

    init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        if !isScanning && isAvailable {
            let services = [CBUUID(string: Gaia.serviceUUID)]
            let currentConnected = centralManager.retrieveConnectedPeripherals(withServices: services)
            _devices.removeAll()
            currentConnected.forEach { cbPeripheral in
                if supportsGaia(peripheral: cbPeripheral) {
                    let connection = GaiaBLEDeviceConnection(peripheral: cbPeripheral, rssiOnDiscovery: 0)
                    let gaiaDevice = GaiaDevice(connection: connection, notificationCenter: notificationCenter)
                    _devices[cbPeripheral.identifier] = DeviceContainer(index: _devices.count, cbPeripheral: cbPeripheral, gaiaDevice: gaiaDevice)
                    delegate?.didDiscoverDevice(gaiaDevice)
                }
            }
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
        }
    }

    func connect(_ device: GaiaDeviceProtocol) {
        if !device.connected {
            let cbDevice = getCBPeripheral(gaiaDevice: device)
            centralManager.connect(cbDevice)
        }
    }

    func disconnect(_ device: GaiaDeviceProtocol) {
        if device.connected {
            let cbDevice = getCBPeripheral(gaiaDevice: device)
            centralManager.cancelPeripheralConnection(cbDevice)
        }
    }
}

private extension BLESource {
    func getCBPeripheral(gaiaDevice: GaiaDeviceProtocol) -> CBPeripheral {
        return _devices[gaiaDevice.uuid]!.cbPeripheral
    }

    func supportsGaia(peripheral: CBPeripheral) -> Bool {
        return peripheral.name != nil
    }

    func registerAndPostAboutDiscovery(peripheral: CBPeripheral, rssi: Int) {
        let connection = GaiaBLEDeviceConnection(peripheral: peripheral, rssiOnDiscovery: rssi)
        let gaiaDevice = GaiaDevice(connection: connection, notificationCenter: notificationCenter)
        connection.delegate = gaiaDevice
        _devices[peripheral.identifier] = DeviceContainer(index: _devices.count, cbPeripheral: peripheral, gaiaDevice: gaiaDevice)
        delegate?.didDiscoverDevice(gaiaDevice)
    }
}


extension BLESource: CBCentralManagerDelegate {
    func hexadecimalString(from data: Data)->String{
        var str = ""
        let bytes = [UInt8](data)
        for item in bytes {
            str += String(format: "%02x", item&0x000000FF)
        }
        return str
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.didChangeState()
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if supportsGaia(peripheral: peripheral) {
            if peripheral.name!.contains("LE-IOS_3040") {
                print("Discovered: \(peripheral)\nServices: \(String(describing: advertisementData["kCBAdvDataServiceUUIDs"]))")
                if _devices[peripheral.identifier] == nil {
                    registerAndPostAboutDiscovery(peripheral: peripheral, rssi: RSSI.intValue)
                }
                //停止
                stopScanning()
                
                if advertisementData["kCBAdvDataManufacturerData"] != nil{
                    let data = hexadecimalString(from: advertisementData["kCBAdvDataManufacturerData"] as! Data)
                print(type(of: data))
                let substr = data.prefix(4)
                print("substr\(substr)")
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if supportsGaia(peripheral: peripheral) {
            if _devices[peripheral.identifier] == nil {
                registerAndPostAboutDiscovery(peripheral: peripheral, rssi: 0)
            }

            if let entry = _devices[peripheral.identifier] {
                print("Central Manager Connected")
                delegate?.didConnectDevice(entry.gaiaDevice)
            }
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        if let entry = _devices[peripheral.identifier] {
            delegate?.didFailToConnectDevice(entry.gaiaDevice)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("Central disconnected: \(peripheral)")
        if let entry = _devices[peripheral.identifier] {
            entry.gaiaDevice.reset()
            delegate?.didDisconnectDevice(entry.gaiaDevice)
        }
    }
}
