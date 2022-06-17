//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class DevicesViewController: UIViewController, GaiaViewControllerProtocol {
    var viewModel: GaiaViewModelProtocol?

    @IBOutlet weak var tableView: UITableView?

    override var title: String? {
        get {
            return viewModel?.title
        }
        set {}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        let spinner = UIActivityIndicatorView(style: .medium)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        spinner.startAnimating()

        viewModel?.activate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.deactivate()
    }
}

extension DevicesViewController {
    func update() {
        tableView?.reloadData()
    }
}

extension DevicesViewController: UITableViewDataSource {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "DevicesTableViewCell") as? DevicesTableViewCell,
            let devicesViewModel = viewModel as? DevicesViewModel
        else {
			return UITableViewCell()
        }

        let devices = devicesViewModel.devices
        guard indexPath.row < devices.count  else {
            return UITableViewCell()
        }

        let device = devices[indexPath.row]
        cell.deviceNameLabel?.text = device.name
    	cell.rssiLevelLabel?.text = "\(device.rssi) db"
        cell.rssiLevelImage?.setImage(signalRSSI: device.rssi)
        cell.checkmarkImageView?.image = device.connected ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        cell.subtitleLabel?.text = "Unused"
        return cell
    }
}

extension DevicesViewController: UITableViewDelegate {
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
}
