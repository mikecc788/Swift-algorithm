//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class SettingsIntroViewController : UIViewController, GaiaViewControllerProtocol {
    var viewModel: GaiaViewModelProtocol?

    @IBOutlet weak var overlayView: UIView?
    @IBOutlet weak var overlayViewLabel: UILabel?

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var versionLabel: UILabel!

    override var title: String? {
        get {
            return viewModel?.title
        }
        set {}
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.activate()

        guard let infoDictionary = Bundle.main.infoDictionary,
            let version = infoDictionary["CFBundleShortVersionString"] as? String,
        	let build = infoDictionary["CFBundleVersion"] as? String
        else {
            versionLabel.text = ""
            return
        }
        versionLabel.text = NSString.localizedStringWithFormat("Version %@ (build %@)", version, build) as String
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.deactivate()
    }
}

extension SettingsIntroViewController {
    func update() {
        let connected = (viewModel as? SettingsIntroViewModel)?.device?.connected ?? false
        if !connected {
            overlayView?.isHidden = false
            overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
        } else {
            overlayView?.isHidden = true
        }

        tableView?.reloadData()
    }
}

extension SettingsIntroViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settingsViewModel = viewModel as? SettingsIntroViewModel else {
            return 0
        }
        return settingsViewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell,
            let settingsViewModel = viewModel as? SettingsIntroViewModel
        else {
            return UITableViewCell()
        }

        let rows = settingsViewModel.rows
        guard indexPath.row < rows.count  else {
            return UITableViewCell()
        }

        switch rows[indexPath.row] {
        case .title(let title):
            cell.titleLabel?.text = title
            cell.viewOption = .titleOnly
        case .titleAndSubtitle(let title, let subtitle):
            cell.titleLabel?.text = title
            cell.subtitleLabel?.text = subtitle
            cell.viewOption = .titleAndSubtitle
        default:
            break
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension SettingsIntroViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let settingsViewModel = viewModel as? SettingsIntroViewModel else {
            return
        }

        settingsViewModel.selectedItem(at: indexPath.row)
    }
}
