//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

protocol loginViewDelegate {
    func didDelegateText(viewM:GaiaManagerProtocol)
}

class DevicesViewModel: GaiaViewModelProtocol {
    
    var delegate : loginViewDelegate?
    
    private let coordinator: AppCoordinator
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter

    private var observerToken: ObserverToken?

    private(set) var title: String
    private(set) var devices = [GaiaDeviceProtocol] ()


    required init(coordinator: AppCoordinator,
                  gaiaManager: GaiaManagerProtocol,
                  notificationCenter: NotificationCenter) {
        
        self.coordinator = coordinator
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter
        
        self.title = NSLocalizedString("Select a Device", comment: "Devices Screen Title")

        observerToken = notificationCenter.addObserver(forType: GaiaManagerNotification.self, object: nil,queue: OperationQueue.main,using: deviceDiscoveryAndConnectionHandler)
    }

    deinit {
        notificationCenter.removeObserver(observerToken!)
    }

    func activate() {
        if gaiaManager.isAvailable {
        	gaiaManager.startScanning()
        } else {
            print("Cannot start scanning")
        }
        refresh()
    }

    func deactivate() {
        gaiaManager.stopScanning()
    }

    func refresh() {
        devices = gaiaManager.devices
        
//        delegate?.didDelegateText(viewM: devices as! GaiaManagerProtocol)
    }
}

extension DevicesViewModel {
    func connect(_ device: GaiaDeviceProtocol) {
        gaiaManager.connect(device: device)
    }

    func selected(_ device: GaiaDeviceProtocol) {
        coordinator.onSelectDevice(device)
    }
}

private extension DevicesViewModel {
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
