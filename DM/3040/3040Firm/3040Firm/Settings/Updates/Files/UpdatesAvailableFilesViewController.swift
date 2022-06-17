//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class UpdatesAvailableFilesViewController: UIViewController, GaiaViewControllerProtocol {
    var viewModel: GaiaViewModelProtocol?

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var overlayView: UIView?
    @IBOutlet weak var overlayViewLabel: UILabel?

    override var title: String? {
        get {
            return viewModel?.title
        }
        set {}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.activate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.deactivate()
    }
}

extension UpdatesAvailableFilesViewController {
    func update() {
        let rows = (viewModel as? UpdatesAvailableFilesViewModel)?.rowTitles.count ?? 0
        let connected = (viewModel as? UpdatesAvailableFilesViewModel)?.device?.connected ?? false

        let showOverlay = rows == 0 || !connected
//        if showOverlay {
//            overlayView?.isHidden = false
//            if !connected {
//                overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
//            } else {
//                // No rows
//                overlayViewLabel?.text = NSLocalizedString("No updates available", comment: "Updates Overlay")
//            }
//            return
//        }

        overlayView?.isHidden = true
        tableView?.reloadData()
    }
}

extension UpdatesAvailableFilesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let updatesViewModel = viewModel as? UpdatesAvailableFilesViewModel else {
//            return 0
//        }
//        return updatesViewModel.rowTitles.count
        
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell,
            let updatesViewModel = viewModel as? UpdatesAvailableFilesViewModel
        else {
            return UITableViewCell()
        }

        let rows = updatesViewModel.rowTitles
//        guard indexPath.row < rows.count  else {
//            return UITableViewCell()
//        }

        cell.titleLabel?.text = "11111" //rows[indexPath.row]
        cell.titleLabel?.textColor = UIColor.red
        cell.viewOption = .titleOnly
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension UpdatesAvailableFilesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let fileViewModel = viewModel as? UpdatesAvailableFilesViewModel else {
            return
        }

        fileViewModel.selectedItem(at: indexPath.row)
    }
}
