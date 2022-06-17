//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class NoiseCancellationSettingsViewController: UIViewController, GaiaViewControllerProtocol {
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

extension NoiseCancellationSettingsViewController {
    func update() {
        let connected = (viewModel as? NoiseCancellationSettingsViewModel)?.device?.connected ?? false
        overlayView?.isHidden = connected

        if !connected {
            overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
            return
        }

        tableView?.reloadData()
    }
}

extension NoiseCancellationSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let ncViewModel = viewModel as? NoiseCancellationSettingsViewModel else {
            return 0
        }
        return ncViewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ncViewModel = viewModel as? NoiseCancellationSettingsViewModel else {
            return 0
        }
        return ncViewModel.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell,
            let ncViewModel = viewModel as? NoiseCancellationSettingsViewModel
            else {
                return UITableViewCell()
        }

        let sections = ncViewModel.sections
        guard indexPath.section < sections.count,
            indexPath.row < sections[indexPath.section].count else {
                return UITableViewCell()
        }

        let section = ncViewModel.sections[indexPath.section]

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
                    let ncViewModel = self.viewModel as? NoiseCancellationSettingsViewModel,
                    let ip = self.tableView?.indexPath(for: cell) else {
                        return
                }
                ncViewModel.toggledSwitch(indexPath: ip)
            }
        case .titleSubtitleAndStepper(let title, let subtitle, let value, let max, let step):
            cell.titleLabel?.text = title
            cell.subtitleLabel?.text = subtitle
            cell.viewOption = .titleSubtitleAndStepper
            cell.stepper?.value = Double(value)
            cell.stepper?.maximumValue = Double(max)
            cell.stepper?.stepValue = Double(step)
            cell.stepper?.valueChangedHandler = { [weak self] stepper in
                guard
                    let self = self,
                    let ncViewModel = self.viewModel as? NoiseCancellationSettingsViewModel,
                    let ip = self.tableView?.indexPath(for: cell) else {
                        return
                }
                ncViewModel.valueChanged(indexPath: ip, newValue: Int(stepper.value))
            }
        }


        cell.accessoryType = (indexPath == ncViewModel.checkmarkIndexPath) ? .checkmark : .none

        return cell
    }
}

extension NoiseCancellationSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil;
    }
}
