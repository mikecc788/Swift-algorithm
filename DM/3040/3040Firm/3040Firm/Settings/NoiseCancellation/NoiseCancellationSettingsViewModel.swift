//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class NoiseCancellationSettingsViewModel: GaiaDeviceViewModelProtocol {
    
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) weak var ncPlugin: GaiaDeviceNoiseCancellationPluginProtocol?

    private(set) var title: String

    private(set) var sections = [[SettingRow]] ()
    private(set) var checkmarkIndexPath: IndexPath?

    private let modeOptions = [
        NSLocalizedString("Mode 1", comment: "ANC Mode"),
        NSLocalizedString("Mode 2", comment: "ANC Mode"),
        NSLocalizedString("Mode 3", comment: "ANC Mode"),
        NSLocalizedString("Mode 4", comment: "ANC Mode"),
        NSLocalizedString("Mode 5", comment: "ANC Mode"),
        NSLocalizedString("Mode 6", comment: "ANC Mode"),
        NSLocalizedString("Mode 7", comment: "ANC Mode"),
        NSLocalizedString("Mode 8", comment: "ANC Mode"),
        NSLocalizedString("Mode 9", comment: "ANC Mode"),
        NSLocalizedString("Mode 10", comment: "ANC Mode")
    ]


    var device: GaiaDeviceProtocol? {
        didSet {
            ncPlugin = device?.plugin(featureID: .noiseCancellation) as? GaiaDeviceNoiseCancellationPluginProtocol
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

        self.title = NSLocalizedString("Noise Cancellation", comment: "Settings Screen Title")

        observerTokens.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceNotificationHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaManagerNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: deviceDiscoveryAndConnectionHandler))

        observerTokens.append(notificationCenter.addObserver(forType: GaiaNoiseCancellationPluginNotification.self,
                                                             object: nil,
                                                             queue: OperationQueue.main,
                                                             using: noiseCancellationNotificationHandler))

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
        guard let ncPlugin = ncPlugin else {
            return
        }

        var firstSection = [SettingRow] ()

        let enabledRow = SettingRow.titleAndSwitch(title: NSLocalizedString("Noise Cancellation", comment: "Enabled Option"),
                                                   switchOn: ncPlugin.enabled)
        firstSection.append(enabledRow)

        let leftTypeValue = ncPlugin.isLeftAdaptive ?
            NSLocalizedString("Left: Adaptive", comment: "ANC Type") :
            NSLocalizedString("Left: Static", comment: "ANC Type")

        let rightTypeValue = ncPlugin.isRightAdaptive ?
            NSLocalizedString("Right: Adaptive", comment: "ANC Type") :
            NSLocalizedString("Right: Static", comment: "ANC Type")
        let ancTypeRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("ANC Type", comment: "ANC Type"),
                                                     subtitle: leftTypeValue + " - " + rightTypeValue)
        firstSection.append(ancTypeRow)

        let maxMode = min(9, max(0, ncPlugin.maxMode)) // constrain 0..9
        let modeCurrent = min(maxMode, max(0, ncPlugin.currentMode))
        let modeStr = modeOptions[modeCurrent]

        if maxMode == 0 {
            let modeRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("Mode", comment: "ANC Mode"),
                                                      subtitle: modeStr)
            firstSection.append(modeRow)
        } else {
            let modeRow = SettingRow.titleSubtitleAndStepper(title: NSLocalizedString("Mode", comment: "ANC Mode"),
                                                             subtitle: modeStr,
                                                             value: modeCurrent,
                                                             max: maxMode,
                                                             step: 1)
            firstSection.append(modeRow)
        }
        
        if ncPlugin.isLeftAdaptive || ncPlugin.isRightAdaptive {
            // Gain is not user modifiable
            let leftGainRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("Left Gain", comment: "ANC Gain"),
                                                          subtitle: "\(ncPlugin.leftAdaptiveGain)")
            firstSection.append(leftGainRow)
            
            let rightGainRow = SettingRow.titleAndSubtitle(title: NSLocalizedString("Right Gain", comment: "ANC Gain"),
                                                           subtitle: "\(ncPlugin.rightAdaptiveGain)")
            firstSection.append(rightGainRow)
        } else {
            if modeCurrent != 0 {
                let gainRow = SettingRow.titleSubtitleAndStepper(title: NSLocalizedString("Static Gain", comment: "ANC Gain"),
                                                                 subtitle: "\(ncPlugin.staticGain)",
                    value: ncPlugin.staticGain,
                    max: 255,
                    step: 25)
                firstSection.append(gainRow)
            }
        }

        sections = [firstSection]
        
    }
}

extension NoiseCancellationSettingsViewModel {
    func toggledSwitch(indexPath: IndexPath) {
        guard let ncPlugin = ncPlugin else {
            return
        }

        ncPlugin.setEnabledState(!ncPlugin.enabled)
    }


    func valueChanged(indexPath: IndexPath, newValue: Int) {
        guard let ncPlugin = ncPlugin else {
            return
        }
        if indexPath.row == 2 {
            ncPlugin.setCurrentMode(newValue)
        } else {
            if ncPlugin.isLeftAdaptive || ncPlugin.isRightAdaptive {
                return
            }
            ncPlugin.setStaticGain(newValue)
        }
    }
}

private extension NoiseCancellationSettingsViewModel {
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

    func noiseCancellationNotificationHandler(notification: GaiaNoiseCancellationPluginNotification) {
        refresh()
    }
}

