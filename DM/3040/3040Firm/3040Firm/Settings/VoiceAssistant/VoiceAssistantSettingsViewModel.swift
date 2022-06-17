//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class VoiceAssistantSettingsViewModel: GaiaDeviceViewModelProtocol {
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) weak var vaPlugin: GaiaDeviceVoiceAssistantPluginProtocol?

    private(set) var title: String

    private(set) var sections = [[SettingRow]] ()
    private(set) var checkmarkIndexPath: IndexPath?

    var device: GaiaDeviceProtocol? {
        didSet {
            vaPlugin = device?.plugin(featureID: .voiceAssistant) as? GaiaDeviceVoiceAssistantPluginProtocol
            refresh()
        }
    }

    private(set) var observerTokens = [ObserverToken]()

    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter

        self.title = NSLocalizedString("Voice Control", comment: "Settings Screen Title")

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceNotificationHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaManagerNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceDiscoveryAndConnectionHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceVoiceAssistantPluginNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: voiceAssistantNotificationHandler))

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
        guard let vaPlugin = vaPlugin else {
            return
        }

        let optionsSection = vaPlugin.availableAssistantOptions.map({ SettingRow.title($0.userVisibleString) })

        sections = [optionsSection]
        let selectedOption = vaPlugin.selectedOption
        let row = vaPlugin.availableAssistantOptions.firstIndex(where: { option in
            option.identifier == selectedOption.identifier
        }) ?? 0

        checkmarkIndexPath = IndexPath(row: row, section: sections.count - 1)
       
    }
}

extension VoiceAssistantSettingsViewModel {
    func toggledSwitch(indexPath: IndexPath) {
    }

    func selectedItem(indexPath: IndexPath) {
        guard let vaPlugin = vaPlugin,
            indexPath.section == sections.count - 1,
            indexPath.row < sections[indexPath.section].count else {
            return
        }

        vaPlugin.selectOption(vaPlugin.availableAssistantOptions[indexPath.row])
    }
}

private extension VoiceAssistantSettingsViewModel {
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

    func voiceAssistantNotificationHandler(notification: GaiaDeviceVoiceAssistantPluginNotification) {
		refresh()
    }
}
