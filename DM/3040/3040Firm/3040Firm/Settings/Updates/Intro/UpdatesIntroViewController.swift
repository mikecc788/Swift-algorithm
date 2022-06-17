//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class UpdatesIntroViewController: UIViewController, GaiaViewControllerProtocol {
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

extension UpdatesIntroViewController {
    func update() {
        let connected = (viewModel as? UpdatesIntroViewModel)?.device?.connected ?? false
        overlayView?.isHidden = connected

        if !connected {
            overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
            return
        }

        tableView?.reloadData()
    }

    @IBAction func proceed(_: Any) {
        guard let uiViewModel = viewModel as? UpdatesIntroViewModel else {
            return
        }

        uiViewModel.showUpdates()
    }
}

extension UpdatesIntroViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let uiViewModel = viewModel as? UpdatesIntroViewModel else {
            return 0
        }
        return uiViewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let uiViewModel = viewModel as? UpdatesIntroViewModel else {
            return 0
        }
        return uiViewModel.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell,
            let uiViewModel = viewModel as? UpdatesIntroViewModel
            else {
                return UITableViewCell()
        }

        let sections = uiViewModel.sections
        guard indexPath.section < sections.count,
            indexPath.row < sections[indexPath.section].count else {
                return UITableViewCell()
        }

        let section = uiViewModel.sections[indexPath.section]

        switch section[indexPath.row] {
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

        return cell
    }
}

extension UpdatesIntroViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil;
    }
}
