//
//  ViewController.swift
//  3040Firm
//
//  Created by kiss on 2020/7/2.
//  Copyright © 2020 kiss. All rights reserved.
//

import UIKit


class ViewController: UIViewController, loginViewDelegate {
    
    
    func didDelegateText(viewM: GaiaManagerProtocol) {
        
        print("这里是我获取到的数据信息\(viewM)")
    }
    
    
    var viewModel: GaiaViewModelProtocol?
    // MARK: Views
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        return tableView
    }()
    
    private var coordinator: AppCoordinator?
    private var observers = [ObserverToken] ()
    private var gaiaManager: GaiaManagerProtocol?
    private var notificationCenter: NotificationCenter? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.activate()
    }
    override var title: String? {
        get {
            return viewModel?.title
        }
        set {}
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.addSubview(tableView)
        initializeStack()
        loadData()
    }
    
    func initializeStack(){
        notificationCenter = NotificationCenter.default
        let cFactory = ConnectionFactory(kind: .ble, notificationCenter: notificationCenter!)
        gaiaManager = GaiaManager(connectionFactory: cFactory, notificationCenter: notificationCenter!)
        gaiaManager?.startScanning()
        
        observers.append(NotificationCenter.default.addObserver(forType: GaiaDeviceNotification.self,object: nil,queue: OperationQueue.main,using: deviceNotificationHandler))
        
    }
    func loadData(){
//        let deviceInfoVM = DeviceInfoViewModel(gaiaManager: gaiaManager!, notificationCenter: notificationCenter!)
//        viewModel = deviceInfoVM
        coordinator = AppCoordinator(gaiaManager: gaiaManager!, notificationCenter: notificationCenter!)
        
        coordinator?.onStart()
        
        coordinator?.mb = {(message:GaiaViewModelProtocol)->(Void) in
            print("message\(message)")
        }
        coordinator?.test = {(test:String) -> (Void) in
            print("test:\(test)")
        }
        
        coordinator?.getBlock {(value) in
            print("getBlock:\(value)")
        }
        
        tableView.reloadData()
    }
    
    func deviceNotificationHandler(notification: GaiaDeviceNotification) {
        guard
            let connectedDeviceUUID = gaiaManager?.connectedDeviceUUID,
            let device = notification.payload else {
            return
        }

        if notification.reason == .connectionReady &&
            device.uuid == connectedDeviceUUID {
            // Reconnection of device
            setDeviceOnAllViewModels(device)
        }
    }
    func setDeviceOnAllViewModels(_ device: GaiaDeviceProtocol){
        
    }

}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let devicesViewModel = viewModel as? DevicesViewModel else {
            return 0
        }
        return devicesViewModel.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellID") as? DevicesTableViewCell,
            let devicesViewModel = viewModel as? DevicesViewModel
        else {
            return UITableViewCell()
        }

        let devices = devicesViewModel.devices
        guard indexPath.row < devices.count  else {
            return UITableViewCell()
        }

        let device = devices[indexPath.row]
        print("device:\(device)")
        cell.deviceNameLabel?.text = device.name
        cell.rssiLevelLabel?.text = "\(device.rssi) db"
        cell.rssiLevelImage?.setImage(signalRSSI: device.rssi)
        cell.checkmarkImageView?.image = device.connected ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        cell.subtitleLabel?.text = "Unused"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let devicesViewModel = viewModel as? DevicesViewModel else {
            return
        }

        let devices = devicesViewModel.devices
        guard indexPath.row < devices.count  else {
            return
        }
        let device = devices[indexPath.row]
        if !device.connected {
            devicesViewModel.connect(device)
        }
        devicesViewModel.selected(device)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
