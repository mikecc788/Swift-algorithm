//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class VoiceAssistantSettingsViewController: UIViewController, GaiaViewControllerProtocol {
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

extension VoiceAssistantSettingsViewController {
    func update() {
        let connected = (viewModel as? VoiceAssistantSettingsViewModel)?.device?.connected ?? false
		overlayView?.isHidden = connected

        if !connected {
            overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
            return
        }

        tableView?.reloadData()
    }
}

extension VoiceAssistantSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let vaViewModel = viewModel as? VoiceAssistantSettingsViewModel else {
            return 0
        }
        return vaViewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vaViewModel = viewModel as? VoiceAssistantSettingsViewModel else {
            return 0
        }
        return vaViewModel.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell,
            let vaViewModel = viewModel as? VoiceAssistantSettingsViewModel
        else {
            return UITableViewCell()
        }

        let sections = vaViewModel.sections
        guard indexPath.section < sections.count,
            indexPath.row < sections[indexPath.section].count else {
            return UITableViewCell()
        }

        let section = vaViewModel.sections[indexPath.section]

        switch section[indexPath.row] {
        case .title(let title):
            cell.titleLabel?.text = title
            cell.viewOption = .titleOnly
        case .titleAndSubtitle(let title, let subtitle):
            cell.titleLabel?.text = title
            cell.subtitleLabel?.text = subtitle
            cell.viewOption = .titleAndSubtitle
        case .titleAndSwitch(let title, let switchOn):
            cell.onOffSwitch?.setOn(switchOn, animated: false)
            cell.titleLabel?.text = title
            cell.viewOption = .titleAndSwitch
            cell.onOffSwitch?.tapHandler = { [weak self] _ in
                guard
                    let self = self,
                    let vaViewModel = self.viewModel as? VoiceAssistantSettingsViewModel,
                    let ip = self.tableView?.indexPath(for: cell) else {
                    return
                }
                vaViewModel.toggledSwitch(indexPath: ip)
            }
        case .titleSubtitleAndStepper(_, _, _, _, _):
            break
        }


        cell.accessoryType = (indexPath == vaViewModel.checkmarkIndexPath) ? .checkmark : .none

        return cell
    }
}

extension VoiceAssistantSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let vaViewModel = viewModel as? VoiceAssistantSettingsViewModel else {
            return
        }

        vaViewModel.selectedItem(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let vaViewModel = viewModel as? VoiceAssistantSettingsViewModel else {
            return nil
        }

        let sections = vaViewModel.sections
        guard indexPath.section < sections.count,
            indexPath.row < sections[indexPath.section].count else {
                return nil
        }

        let section = vaViewModel.sections[indexPath.section]
        switch section[indexPath.row] {
        case .title(_),
             .titleAndSubtitle(_, _):
            return indexPath
        case .titleAndSwitch(_, _),
             .titleSubtitleAndStepper(_, _, _, _, _):	
            return nil
        }
    }
}
