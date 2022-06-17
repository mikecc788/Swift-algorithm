//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

class GaiaBLEDeviceConnection: NSObject, GaiaDeviceConnectionProtocol {
    var uuid: UUID { return peripheral.identifier }
    var name: String { return peripheral.name ?? "" }
    private(set) var rssi: Int =  0

    private let peripheral: CBPeripheral

    weak var delegate: GaiaDeviceConnectionDelegate?

    private static let standardLength = 23
    private static let interestedServices = [CBUUID(string: Gaia.serviceUUID)]
    private(set) var isDataLengthExtensionSupported = false
    private(set) var maximumWriteLength: Int = GaiaBLEDeviceConnection.standardLength
    private(set) var maximumWriteWithoutResponseLength: Int = GaiaBLEDeviceConnection.standardLength
    
    private var commandCharacteristic: CBCharacteristic?
    private var responseCharacteristic: CBCharacteristic?
    private var dataCharacteristic: CBCharacteristic?

    private var gaiaManagerObserverToken: ObserverToken?

    private var awaitedServices = Set<CBUUID> ()

    var connected: Bool {
        return peripheral.state == .connected
    }

    private(set) var available = false

    required init(peripheral: CBPeripheral, rssiOnDiscovery: Int) {
        self.peripheral = peripheral
        self.rssi = rssiOnDiscovery

        super.init()

        peripheral.delegate = self
        if connected {
            peripheral.readRSSI()
        }

        gaiaManagerObserverToken = NotificationCenter.default.addObserver(forType: GaiaManagerNotification.self,
                                                                          object: nil,
                                                                          queue: OperationQueue.main,
                                                                          using: gaiaManagerNotificationHandler)
    }

    deinit {
        NotificationCenter.default.removeObserver(gaiaManagerObserverToken!)
    }

    func sendData(channel: GaiaDeviceConnectionChannel, payload: Data, responseExpected: Bool) {
        if connected && available {
            let writeType = responseExpected ?
                CBCharacteristicWriteType.withResponse :
                CBCharacteristicWriteType.withoutResponse
            switch channel {
            case .command:
                peripheral.writeValue(payload, for: commandCharacteristic!, type: writeType)
            case .response:
                peripheral.writeValue(payload, for: responseCharacteristic!, type: writeType)
            case .data:
                peripheral.writeValue(payload, for: dataCharacteristic!, type: writeType)
            }
        }
    }

    func fetchValue(channel: GaiaDeviceConnectionChannel) {
        if connected && available {
            switch channel {
            case .command:
                peripheral.readValue(for: commandCharacteristic!)
            case .response:
                peripheral.readValue(for: responseCharacteristic!)
            case .data:
                peripheral.readValue(for: dataCharacteristic!)
            }
        }
    }
}

extension GaiaBLEDeviceConnection: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                    didReadRSSI RSSI: NSNumber,
                    error: Error?) {
        if let e = error {
            // Failed
            print("Failed to get RSSI: \(e)")
            rssi = 0
        } else {
            rssi = RSSI.intValue
            delegate?.rssiDidChange()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let characteristics = [CBUUID(string: Gaia.commandCharacteristicUUID),
                               CBUUID(string: Gaia.responseCharacteristicUUID),
                               CBUUID(string: Gaia.dataCharacteristicUUID)]
        print("Discovered Services: \(String(describing: peripheral.services))")
        peripheral.services?.forEach {
            if GaiaBLEDeviceConnection.interestedServices.contains($0.uuid) &&
                !awaitedServices.contains($0.uuid) {
                awaitedServices.insert($0.uuid)
                peripheral.discoverCharacteristics(characteristics, for: $0)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if awaitedServices.contains(service.uuid) {
            awaitedServices.remove(service.uuid)
            service.characteristics?.forEach {
                peripheral.discoverDescriptors(for: $0)
            }

            if awaitedServices.count == 0 {
                // All done - find characteristics
                if peripheral.state == .connected {
                    if !findGaiaCharacteristics() {
                        print("Connected but cannot find Gaia Characteristics")
                        delegate?.connectionUnavailable()
                    } else {
                        print("Found all characteristics")
                    }
                } else {
                    print("Not Connected")
                    delegate?.connectionUnavailable()
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("Found Descriptors")
    }

    private func notifyUpdate(characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
			print ("Error: \(e.localizedDescription)")
            return
        }

        guard available,
            let data = characteristic.value else {
            return
        }

        switch characteristic.uuid {
        case commandCharacteristic?.uuid:
            delegate?.dataReceived(data, channel: .command)
        case responseCharacteristic?.uuid:
            delegate?.dataReceived(data, channel: .response)
        case dataCharacteristic?.uuid:
            delegate?.dataReceived(data, channel: .data)

        default:
            break
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        notifyUpdate(characteristic: characteristic, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        notifyUpdate(characteristic: descriptor.characteristic, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == responseCharacteristic?.uuid {
            available = true
            print("Connection Available on response characteristic")
            delegate?.connectionAvailable()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case commandCharacteristic?.uuid:
            delegate?.didSendData(channel: .command, error: error)
        case responseCharacteristic?.uuid:
            delegate?.didSendData(channel: .response, error: error)
        case dataCharacteristic?.uuid:
            delegate?.didSendData(channel: .data, error: error)

        default:
            break
        }
    }
}

private extension GaiaBLEDeviceConnection {
    func gaiaManagerNotificationHandler(_ notification: GaiaManagerNotification) {
        if notification.payload?.uuid == uuid {
            switch notification.reason {
            case .connectSuccess:
                // We do this after connection
                maximumWriteLength = peripheral.maximumWriteValueLength(for: .withResponse)
                maximumWriteLength = maximumWriteLength > 0 ?
                    maximumWriteLength :
                    GaiaBLEDeviceConnection.standardLength

                maximumWriteWithoutResponseLength = peripheral.maximumWriteValueLength(for: .withoutResponse)
                maximumWriteWithoutResponseLength = maximumWriteWithoutResponseLength > 0 ?
                    maximumWriteWithoutResponseLength :
                    GaiaBLEDeviceConnection.standardLength

                isDataLengthExtensionSupported = maximumWriteLength > GaiaBLEDeviceConnection.standardLength
                peripheral.readRSSI()
                peripheral.discoverServices(GaiaBLEDeviceConnection.interestedServices)
            case .connectFailed,
                 .disconnect:
                available = false
                awaitedServices.removeAll()
                commandCharacteristic = nil
                responseCharacteristic = nil
                dataCharacteristic = nil
                print("GaiaBLEDeviceConnection - disconnect or connectFailed")
                delegate?.connectionUnavailable()
                break
            default:
                break
            }
        }
    }
}

private extension GaiaBLEDeviceConnection {
    func findGaiaCharacteristics() -> Bool {
        guard let gaiaService = findGaiaService() else {
            return false
        }
        commandCharacteristic = findCharacteristic(uuid: CBUUID(string: Gaia.commandCharacteristicUUID),
                                                   service: gaiaService)
        responseCharacteristic = findCharacteristic(uuid: CBUUID(string: Gaia.responseCharacteristicUUID),
                                                   service: gaiaService)
        dataCharacteristic = findCharacteristic(uuid: CBUUID(string: Gaia.dataCharacteristicUUID),
                                                   service: gaiaService)

        if responseCharacteristic != nil {
            peripheral.setNotifyValue(true, for: responseCharacteristic!)
        }

        if dataCharacteristic != nil {
            peripheral.setNotifyValue(true, for: dataCharacteristic!)
        }
        return commandCharacteristic != nil &&
            responseCharacteristic != nil &&
            dataCharacteristic != nil
    }

    func findGaiaService() -> CBService? {
        let uuid = CBUUID(string: Gaia.serviceUUID)
        return peripheral.services?.first {
            $0.uuid == uuid
        }
    }

    func findCharacteristic(uuid: CBUUID, service: CBService) -> CBCharacteristic? {
        return service.characteristics?.first {
            $0.uuid == uuid
        }
    }
}
