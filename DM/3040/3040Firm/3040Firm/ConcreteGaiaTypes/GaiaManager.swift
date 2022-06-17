//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaManagerNotification = Notification.Name("GaiaManagerNotification")
}

struct GaiaManagerNotification: GaiaNotification {
    enum Reason {
        case poweredOn
        case poweredOff
        case discover
		case connectSuccess
        case connectFailed
        case disconnect
    }

    var sender: GaiaNotificationSender
    var payload: GaiaDeviceProtocol?
    var reason: GaiaManagerNotification.Reason

    static var name: Notification.Name = .GaiaManagerNotification
}


class GaiaManager: NSObject, GaiaManagerProtocol, GaiaNotificationSender {
    static private let standardTimeDelay: TimeInterval = 5.0
    private let connectionFactory: ConnectionFactory
    private let notificationCenter: NotificationCenter
    private var observers = [ObserverToken]()

    private(set) var connectedDeviceUUID: UUID?
    private var updatingDeviceRequestedSettings: RequestedUpdateSettings?
    private var updatingDeviceRequestedURL: URL?

    private var reconnectDelaySecs: TimeInterval = standardTimeDelay

    var devices: [GaiaDeviceProtocol] {
        return connectionFactory.devices
    }

    var connectedDevice: GaiaDeviceProtocol? {
        return devices.first {
            $0.connected
        }
    }

    var isAvailable: Bool {
        return connectionFactory.isAvailable
    }

    var isScanning: Bool {
        return connectionFactory.isScanning
    }

    required init(connectionFactory: ConnectionFactory, notificationCenter: NotificationCenter) {
        self.connectionFactory = connectionFactory
        self.notificationCenter = notificationCenter

        super.init()
        connectionFactory.delegate = self
        observers.append(notificationCenter.addObserver(forType: GaiaDeviceUpdaterPluginNotification.self,
                                                        object: nil,
                                                        queue: OperationQueue.main,
                                                        using: updaterNotificationHandler))

        observers.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                        object: nil,
                                                        queue: OperationQueue.main,
                                                        using: deviceNotificationHandler))

        observers.append(notificationCenter.addObserver(forType: GaiaDeviceEarbudPluginNotification.self,
                                                        object: nil,
                                                        queue: OperationQueue.main,
                                                        using: earbudNotificationHandler))
    }

    deinit {
        observers.forEach { token in
            notificationCenter.removeObserver(token)
        }
        observers.removeAll()
    }

    func stopScanning() {
        connectionFactory.stopScanning()
    }

    func startScanning() {
        connectionFactory.startScanning()
    }

    func connect(device: GaiaDeviceProtocol) {
        if !device.connected {
            connectionFactory.connect(device)
        }
    }

    func disconnect(device: GaiaDeviceProtocol, reconnect: Bool) {
        if device.connected {
            if !reconnect {
                connectedDeviceUUID = nil
            }
            connectionFactory.disconnect(device)
        }
    }
}

//MARK:- Updating Device Reconnection

private extension GaiaManager {
    func updaterNotificationHandler(notification: GaiaDeviceUpdaterPluginNotification) {
        guard
            let device = notification.payload,
            let plugin = device.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPlugin
        else {
            return
        }

        switch notification.reason {
        case .statusChanged:
            if plugin.isUpdating {
                if updatingDeviceRequestedSettings == nil {
                    print("Noting device: \(device.uuid) is now updating")
                    connectedDeviceUUID = device.uuid
                    updatingDeviceRequestedSettings = plugin.userRequestedSettings
                    updatingDeviceRequestedURL = plugin.updateUrl
                }
            } else {
                print("Noting device: \(device.uuid) is not now updating")
                updatingDeviceRequestedSettings = nil
                updatingDeviceRequestedURL = nil
            }
        }
    }

    func deviceNotificationHandler(notification: GaiaDeviceNotification) {
        guard let device = notification.payload else {
            return
        }

        if notification.reason == .connectionReady {
            if device.uuid == connectedDeviceUUID {
                // Reconnection of device.... was it updating?
                if let plugin = device.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPlugin,
                    let url = self.updatingDeviceRequestedURL,
                    let userSettings = self.updatingDeviceRequestedSettings{
                    print("Queue restart of update after reconnection...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak plugin] in
                        guard let plugin = plugin else {
                            return
                        }
                        if !plugin.isUpdating {
                            print("Sending restart of update after reconnection...")
                            print("URL: \(url) Settings: \(userSettings)")
                            plugin.startUpdate(url: url, requestedSettings: userSettings)
                        }
                    }
                }
            } else {
                // connection ready from different device
                connectedDeviceUUID = device.uuid
            }
        }
    }

    func earbudNotificationHandler(notification: GaiaDeviceEarbudPluginNotification) {
        guard
            notification.reason == .handoverAboutToHappen,
            let payload = notification.payload
        else {
            return
        }

        reconnectDelaySecs = TimeInterval(payload.handoverDelay)
    }
}

//MARK:- Device Discovery etc.

extension GaiaManager: ConnectionFactoryDelegate {
    func didChangeState() {
        if connectionFactory.isAvailable {
            let notification = GaiaManagerNotification(sender: self,
                                                       payload: nil,
                                                       reason: .poweredOn)
            notificationCenter.post(notification)
        } else {
            let notification = GaiaManagerNotification(sender: self,
                                                       payload: nil,
                                                       reason: .poweredOff)
            notificationCenter.post(notification)
        }
    }

    func didDiscoverDevice(_ device: GaiaDeviceProtocol) {
        let notification = GaiaManagerNotification(sender: self,
                                                   payload: device,
                                                   reason: .discover)
        notificationCenter.post(notification)
    }

    func didConnectDevice(_ device: GaiaDeviceProtocol) {
        reconnectDelaySecs = Self.standardTimeDelay
        print("DID CONNECT DEVICE - GAIAMANAGER")
        let notification = GaiaManagerNotification(sender: self,
                                                   payload: device,
                                                   reason: .connectSuccess)
        notificationCenter.post(notification)
    }

    func didFailToConnectDevice(_ device: GaiaDeviceProtocol) {
        let notification = GaiaManagerNotification(sender: self,
                                                   payload: device,
                                                   reason: .connectFailed)
        notificationCenter.post(notification)
    }

    func didDisconnectDevice(_ device: GaiaDeviceProtocol) {
        let notification = GaiaManagerNotification(sender: self,
                                                   payload: device,
                                                   reason: .disconnect)
        notificationCenter.post(notification)

        if let connectedDeviceUUID = connectedDeviceUUID,
            connectedDeviceUUID == device.uuid {
            DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelaySecs) { [weak self] in
                print("Will try to reconnect \(device.name).")
                self?.connect(device: device)
            }
        }
    }
}
