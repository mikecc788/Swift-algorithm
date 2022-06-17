//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class DeviceInfoViewModel: GaiaDeviceViewModelProtocol {
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) var title: String

    var device: GaiaDeviceProtocol? {
        didSet {
            refresh()
        }
    }

    var devicesAreAvailable: Bool {
        return gaiaManager.isAvailable
    }

    var observerTokens = [ObserverToken]()

    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter

        self.title = ""

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceNotificationHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaManagerNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceDiscoveryAndConnectionHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceEarbudPluginNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: earbudHandler))
    }

    deinit {
        observerTokens.forEach { token in
            notificationCenter.removeObserver(token)
        }
        observerTokens.removeAll()
    }

    func activate() {
        refresh()
    }

    func deactivate() {
    }

    func refresh() {
//        viewController?.update()
    }

    func connectDisconnect() {
        if let d = device {
            if d.connected || d.version == .unknown {
                coordinator.userRequestedDisconnect(d)
            } else {
                coordinator.userRequestedConnect(d)
            }
        }
    }
}

extension DeviceInfoViewModel {
    func deviceNotificationHandler(_ notification: GaiaDeviceNotification) {
        switch notification.reason {
        case .rssi,
             .connectionSetupFailed,
             .connectionReady,
             .chargerStatus:
            refresh()
        }
    }

    func deviceDiscoveryAndConnectionHandler(notification: GaiaManagerNotification) {
        switch notification.reason {
        case .discover,
             .connectFailed,
             .connectSuccess,
             .disconnect,
             .poweredOff:
            refresh()
            break
        case .poweredOn:
            print("Starting scanning")
            gaiaManager.startScanning()
            refresh()
        }
    }

    func earbudHandler(notification: GaiaDeviceEarbudPluginNotification) {
        if notification.reason == .secondSerial {
            refresh()
        }
    }
}
