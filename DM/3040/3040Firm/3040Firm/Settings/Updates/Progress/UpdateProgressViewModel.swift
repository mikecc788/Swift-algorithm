//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class UpdateProgressViewModel: GaiaDeviceViewModelProtocol {
    
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) weak var updatesPlugin: GaiaDeviceUpdaterPluginProtocol?

    var title: String

    var device: GaiaDeviceProtocol? {
        didSet {
            print("Did set device")
            updatesPlugin = device?.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPluginProtocol
            print("Did plugin: \(String(describing: updatesPlugin))")
            refresh()
        }
    }

    private var observerTokens = [ObserverToken]()

    private(set) var canExit: Bool = false
    private(set) var progress: Double = 0.0
    private(set) var progressText: String = ""
    private(set) var statusText: String = ""

    private weak var updateTimer: Timer?

    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter

        self.title = NSLocalizedString("Update Progress", comment: "Progress Screen Title")

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
        updateTimer?.invalidate()
    }

    func refresh() {
        guard let plugin = updatesPlugin else {
            print("Plugin is null - dropping")
            return
        }

        switch plugin.updateState  {
        case .ready:
            updateTimer?.invalidate()
            allowExit(reason: NSLocalizedString("Ready", comment: "Update State"))
        case .busy(let progress):
            handleUpdateStatus(progress)
        case .stopped(let reason):
            updateTimer?.invalidate()
            switch reason {
            case .aborted(let error):
                if let reason = error?.localizedDescription {
                    allowExit(reason: NSLocalizedString("Aborted: ", comment: "Update State") + reason)
                } else {
                    allowExit(reason: NSLocalizedString("Aborted", comment: "Update State"))
                }
            default:
                allowExit(reason: NSLocalizedString("Successfully Completed", comment: "Update State"))
            }
        }

      
    }

    private func allowExit(reason: String) {
        canExit = true
        statusText = reason
        progressText = ""
    }

    private func handleUpdateStatus(_ status: UpdateStateProgress) {
        canExit = false

       

        if status != .transferring {
            updateTimer?.invalidate()
        }

    }

    @objc func timerFired(_: Any) {
        guard let updatesPlugin = updatesPlugin else {
            return
        }

        let eta = determineEtaString(progress: updatesPlugin.percentProgress, startTime: updatesPlugin.startTime)
        statusText = NSLocalizedString("Transferring...", comment: "Update State")
        progressText = eta
        progress = updatesPlugin.percentProgress / 100.0

       
    }
}

extension UpdateProgressViewModel {
    func abortRequested() {
        updatesPlugin?.abort()
    }

    func determineEtaString(progress: Double, startTime: TimeInterval) -> String {
        guard progress > 0.01 else {
            return ""
        }

        let timeTaken = Date.timeIntervalSinceReferenceDate - startTime
        let fullTime = timeTaken * (100.0 / progress)
        let remainingSeconds = max(fullTime - timeTaken, 0.0)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.minute,.second]

        // Use the configured formatter to generate the string.
        return formatter.string(from: remainingSeconds) ?? ""
    }
}

private extension UpdateProgressViewModel {
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



