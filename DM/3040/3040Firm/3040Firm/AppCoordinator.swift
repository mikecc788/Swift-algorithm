//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit


struct RequestedUpdateSettings {
    static let rwcpMaxSequence: Int = 63
    static let rwcpMaxWindow: Int = 32
    static let maxSizeWithoutDLE: Int = 23
    
    var rwcpAvailable = false
    var dleAvailable = false
    var rwcpRequested = false
    var dleRequested = false

    var rwcpInitialCongestionWindowSize: Int = 0
    var rwcpMaximumInitialCongestionWindowSize: Int = 0
    var maxMessageSize: Int = 0
}
typealias MyBlock = (_ message:GaiaViewModelProtocol)->(Void)

typealias MyBlock1 = (_ message2:String)->(Void)



struct AppCoordinator: loginViewDelegate {
    func didDelegateText(viewM: GaiaManagerProtocol) {
        print("didDelegateText:\(viewM)")
    }
    
    var mb:MyBlock?
    var test:MyBlock1?
    
    public var viewModel: GaiaViewModelProtocol?
    private let gaiaManager: GaiaManagerProtocol
    private let notificationCenter: NotificationCenter
   
	private var observers = [ObserverToken] ()
    
    init(gaiaManager: GaiaManagerProtocol,
         notificationCenter: NotificationCenter) {
        self.gaiaManager = gaiaManager
        self.notificationCenter = notificationCenter
        
       
        observers.append(notificationCenter.addObserver(forType: GaiaDeviceNotification.self,object: nil,queue: OperationQueue.main,using: deviceNotificationHandler))
    }
    
    mutating func getBlock(block:@escaping MyBlock1) {
        self.test = block
    }
}

private extension AppCoordinator {
    func instantiateVCFromStoryboard<T>(viewControllerClass: T.Type,
                                                name: String = "Main") -> T where T: GaiaViewControllerProtocol {
        let className = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: className) as? T else {
            fatalError("Cannot instantiate \(className) from \(name)")
        }
        return viewController
    }

    @discardableResult func showNextViewController<VM>(viewModelClass: VM.Type, presentModally: Bool = false) {
       
//        let viewModel = VM(coordinator: self,
//                           gaiaManager: gaiaManager,
//                           notificationCenter: notificationCenter)
//        vc.viewModel = viewModel
//
//        return vc
        
    }
}

extension AppCoordinator {
    func deviceNotificationHandler(notification: GaiaDeviceNotification) {
        guard
            let connectedDeviceUUID = gaiaManager.connectedDeviceUUID,
            let device = notification.payload else {
            return
        }

        if notification.reason == .connectionReady &&
            device.uuid == connectedDeviceUUID {
            // Reconnection of device
            setDeviceOnAllViewModels(device)
        }
    }
}

//MARK:- App Launch
extension AppCoordinator {
    mutating func onStart() {
        
        let deviceInfoVM = DevicesViewModel(coordinator: self,gaiaManager: gaiaManager,notificationCenter: notificationCenter)
        viewModel = deviceInfoVM 
//        guard let devicesViewModel = viewModel as? DevicesViewModel
//        else {
//            return
//        }
        
        deviceInfoVM.delegate = self
        
        print("devices:\(deviceInfoVM.devices)")
        
        
        
//        if let block = self.test {
//            block("122333")
//        }
        
        print("deviceInfoVM:\(viewModel)")
       
        if gaiaManager.connectedDevice == nil {
            showDeviceSelection()
        }
        if mb != nil {
            mb!(deviceInfoVM)
        }
        
        if test != nil {
            test!("11111111")
        }
    }
    
    func showDeviceSelection() {
       showNextViewController(viewModelClass: DevicesViewModel.self)
    }
    
    func showNextViewController<VM>(viewModelClass: VM.Type) ->Void where VM:GaiaViewModelProtocol{
        let viewModel = VM(coordinator: self,
        gaiaManager: gaiaManager,
        notificationCenter: notificationCenter)
        
    }
    
    func setDeviceOnAllViewModels(_ device: GaiaDeviceProtocol) {
        
    }

    func onSelectDevice(_ device: GaiaDeviceProtocol) {
       
        setDeviceOnAllViewModels(device)
    }

    func userRequestedDisconnect(_ device: GaiaDeviceProtocol) {
        if device.connected {
            gaiaManager.disconnect(device: device, reconnect: false)
        }
        showDeviceSelection()
    }

    func userRequestedConnect(_ device: GaiaDeviceProtocol?) {
        if let d = device {
        	gaiaManager.connect(device: d)
        } else {
            showDeviceSelection()
        }
    }

    func selectedFeature(_ featureID: GaiaDevicePluginFeatureID, device: GaiaDeviceProtocol) {
        
    }

    func updateIntroProceedRequested(_ device: GaiaDeviceProtocol) {
       
    }

    func selectedUpdateFile(_ url: URL, device: GaiaDeviceProtocol) {
        
    }

    func startUpdateRequested(url: URL,
                              device: GaiaDeviceProtocol,
                              settings: RequestedUpdateSettings) {
        guard let plugin = device.plugin(featureID: .upgrade) as? GaiaDeviceUpdaterPluginProtocol else {
            return
        }

        
    }
}
