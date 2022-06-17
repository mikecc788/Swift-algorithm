//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class UpdatesIntroViewModel: GaiaDeviceViewModelProtocol {
    
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) var title: String

    private(set) var sections = [[SettingRow]] ()
    private(set) var checkmarkIndexPath: IndexPath?

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

        self.title = NSLocalizedString("Software Updates", comment: "Settings Screen Title")

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
        sections.removeAll()

        guard let device = device else {
            return
        }

        var firstSection = [SettingRow] ()
        if device.version == .v3 {
            let appRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("Application Version", comment: "App Version"),
                                                     subtitle: device.applicationVersion)
            firstSection.append(appRow)
        }

        let apiRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("API Version", comment: "API Version"),
                                                 subtitle: device.apiVersion)
        firstSection.append(apiRow)

        sections = [firstSection]
       
    }
}

extension UpdatesIntroViewModel {
    func showUpdates() {
        guard let device = device else {
            return
        }

        coordinator.updateIntroProceedRequested(device)
    }
}

private extension UpdatesIntroViewModel {
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
}


