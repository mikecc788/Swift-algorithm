//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class SettingsIntroViewModel: GaiaDeviceViewModelProtocol {
    private struct FeatureItem {
        let id: GaiaDevicePluginFeatureID
        let title: String
        let subtitle: String?
    }
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    var title: String {
        device?.name ?? ""
    }

    private var featureMap = [FeatureItem] ()
    var rows: [SettingRow] {
        return featureMap.map{
            if let subtitle = $0.subtitle {
                return .titleAndSubtitle(title: $0.title, subtitle: subtitle)
            } else {
                return .title( $0.title)
            }
        }
    }

    var device: GaiaDeviceProtocol? {
        didSet {
            refresh()
        }
    }

    private var observerTokens = [ObserverToken]()

    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceNotificationHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaManagerNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceDiscoveryAndConnectionHandler))

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
        if let supportedFeatureIDs = device?.supportedFeatures {
            featureMap = supportedFeatureIDs.compactMap {
                if let plugin = device?.plugin(featureID: $0),
                    $0 != .earbud {
                    return FeatureItem(id: $0, title: plugin.title, subtitle: plugin.subtitle)
                } else {
                    return nil
                }
            }
        } else {
            featureMap = []
        }
        
    }
}

extension SettingsIntroViewModel {
    func selectedItem(at itemIndex: Int) {
        guard itemIndex < featureMap.count else {
            return
        }

        let feature = featureMap[itemIndex].id
        coordinator.selectedFeature(feature, device: device!)
    }
}

private extension SettingsIntroViewModel {
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
            print("Starting scanning")
            gaiaManager.startScanning()
        }
    }
}
