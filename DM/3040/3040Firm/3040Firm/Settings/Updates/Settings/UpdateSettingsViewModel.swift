//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class UpdateSettingsViewModel: GaiaDeviceViewModelProtocol {
   
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) weak var updatesPlugin: GaiaDeviceUpdaterPluginProtocol?

    private(set) var title: String

    var device: GaiaDeviceProtocol? {
        didSet {
            updatesPlugin = device?.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPluginProtocol
            if let plugin = updatesPlugin {
                settings.rwcpAvailable = plugin.rwcpAvailable
                settings.dleAvailable = plugin.dataLengthExtensionAvailable
                settings.rwcpRequested = plugin.rwcpAvailable
                settings.dleRequested = plugin.dataLengthExtensionAvailable
                if plugin.rwcpAvailable {
                    /*
                     settings.rwcpInitialCongestionWindowSize = RequestedUpdateSettings.rwcpMaxWindow //RequestedUpdateSettings.rwcpMaxSequence
                     settings.rwcpMaximumInitialCongestionWindowSize = RequestedUpdateSettings.rwcpMaxWindow//RequestedUpdateSettings.rwcpMaxSequence
                     */
                    // Settings replicated from previous version of the app
                    settings.rwcpInitialCongestionWindowSize = 16 //3
                    settings.rwcpMaximumInitialCongestionWindowSize = 32 //4
                    settings.maxMessageSize = min(23,maxPermissableMessageLength(useDLE: plugin.dataLengthExtensionAvailable,
                                                                                 useRWCP: plugin.rwcpAvailable))
                } else {
                    settings.maxMessageSize = maxPermissableMessageLength(useDLE: plugin.dataLengthExtensionAvailable,
                                                                          useRWCP: plugin.rwcpAvailable)
                }
            }
            refresh()
        }
    }

    var canStartUpdate: Bool {
        return !(updatesPlugin?.isUpdating ?? true)
    }
    var fileURL: URL?
    private(set) var settings = RequestedUpdateSettings()

    private var observerTokens = [ObserverToken]()

    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter

        self.title = NSLocalizedString("Update Settings", comment: "Settings Screen Title")

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceNotificationHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaManagerNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceDiscoveryAndConnectionHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceUpdaterPluginNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceUpdaterNotificationHandler))

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
        
    }
}

extension UpdateSettingsViewModel {
    func startRequested() {
        coordinator.startUpdateRequested(url: fileURL!,
                                         device: device!,
                                         settings: settings)
    }

    func updateSettings(_ newSettings: RequestedUpdateSettings) {
        // Verify

        guard let plugin = updatesPlugin else {
            return
        }

        var verified = settings
        verified.rwcpRequested = newSettings.rwcpRequested && plugin.rwcpAvailable
        verified.dleRequested = newSettings.dleRequested && plugin.dataLengthExtensionAvailable
        verified.maxMessageSize = min(newSettings.maxMessageSize, maxPermissableMessageLength(useDLE: verified.dleRequested, useRWCP: verified.rwcpRequested))
        verified.rwcpInitialCongestionWindowSize = min(newSettings.rwcpInitialCongestionWindowSize, RequestedUpdateSettings.rwcpMaxSequence)
        verified.rwcpMaximumInitialCongestionWindowSize = min(newSettings.rwcpMaximumInitialCongestionWindowSize, RequestedUpdateSettings.rwcpMaxSequence)

        settings = verified

        refresh()
    }
}

private extension UpdateSettingsViewModel {
    func maxPermissableMessageLength(useDLE: Bool, useRWCP: Bool) -> Int {
        guard let _ = updatesPlugin else {
            return 0
        }
        if useDLE {
            if useRWCP {
                return 64 //plugin.maximumWriteLengthNoResponse
            } else {
                //TODO: Fix DLE setting
                return RequestedUpdateSettings.maxSizeWithoutDLE // plugin.maximumWriteLength
            }
        } else {
            return RequestedUpdateSettings.maxSizeWithoutDLE
        }
    }
}

private extension UpdateSettingsViewModel {
    func deviceNotificationHandler(_ notification: GaiaDeviceNotification) {
        guard notification.payload?.uuid == device?.uuid else {
            return
        }

        switch notification.reason {
        case .connectionReady:
            refresh()
        case .connectionSetupFailed:
            refresh()
        default:
            break
        }
    }

    func deviceDiscoveryAndConnectionHandler(notification: GaiaManagerNotification) {
        switch notification.reason {
        case .discover,
             .connectFailed,
             .connectSuccess,
             .disconnect:
            refresh()
        case .poweredOff:
            break
        case .poweredOn:
			break
        }
    }

    func deviceUpdaterNotificationHandler(notification: GaiaDeviceUpdaterPluginNotification) {
        switch notification.reason {
        case .statusChanged:
            refresh()
        }
    }
}

