//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol GaiaManagerProtocol {
    init(connectionFactory: ConnectionFactory,
         notificationCenter: NotificationCenter)

    var devices: [GaiaDeviceProtocol] { get }
    var connectedDevice: GaiaDeviceProtocol? { get }
    
    func connect(device: GaiaDeviceProtocol)
    func disconnect(device: GaiaDeviceProtocol, reconnect: Bool) 

    var isAvailable: Bool { get }
    var isScanning: Bool { get }
    func stopScanning()
    func startScanning()

    var connectedDeviceUUID: UUID? { get }
}


