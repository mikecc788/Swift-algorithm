//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class UpdatesAvailableFilesViewModel: GaiaDeviceViewModelProtocol {
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private(set) weak var updatesPlugin: GaiaDeviceUpdaterPluginProtocol?

    private(set) var title: String

    private var files = [URL] ()
    var rowTitles: [String] {
        return files.map{ $0.lastPathComponent }
    }

    var device: GaiaDeviceProtocol? {
        didSet {
            updatesPlugin = device?.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPluginProtocol
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

        self.title = NSLocalizedString("Available Updates", comment: "Settings Screen Title")

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
        files = updatesPlugin?.availableUpdates ?? [URL]()
        
    }
}

extension UpdatesAvailableFilesViewModel {
    func selectedItem(at itemIndex: Int) {
//        guard itemIndex < files.count else {
//            return
//        }
        
        /*
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
        let documentsDirectory = paths.first
        
        let file1 =
            (documentsDirectory?.appending("/AVIOT_KB522_3040_ADK66.1_20200615_v1.4.bin")) ?? ""
        
        let isExit = FileManager.init().fileExists(atPath: file1)
        if isExit {
            
        }else{
            do {
                FileManager.init().createFile(atPath: file1, contents: nil, attributes: nil)
            } catch  {
                
            }
        }
        */
        let path2 = Bundle.main.path(forResource: "AVIOT_KB522_3040_ADK66.1_20200615_v1.4", ofType: "bin") ?? ""
//         let fileName3  = URL.init(string: path2)
        let fileName2 = URL.init(fileURLWithPath: path2)
//        let file =  files[itemIndex]
        coordinator.selectedUpdateFile(fileName2, device: device!)
    }
}

private extension UpdatesAvailableFilesViewModel {
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
