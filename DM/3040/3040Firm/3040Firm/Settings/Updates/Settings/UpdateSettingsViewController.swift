//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit
let fileName = "AVIOT_KB522_3040_ADK66.1_20200615_v1.4"

class UpdateSettingsViewController: UIViewController, GaiaViewControllerProtocol {
    var viewModel: GaiaViewModelProtocol?

    @IBOutlet weak var overlayView: UIView?
    @IBOutlet weak var overlayViewLabel: UILabel?

    @IBOutlet weak var rwcpLabel: UILabel!
    @IBOutlet weak var dleLabel: UILabel!
    @IBOutlet weak var initialWindowSizeLabel: UILabel!
    @IBOutlet weak var maxWindowSizeLabel: UILabel!
    @IBOutlet weak var messageSizeLabel: UILabel!

    @IBOutlet weak var rwcpSwitch: UISwitch!
    @IBOutlet weak var dleSwitch: UISwitch!
    @IBOutlet weak var initialWindowSizeTextField: UITextField!
    @IBOutlet weak var maxWindowSizeTextField: UITextField!
    @IBOutlet weak var messageSizeTextField: UITextField!

    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override var title: String? {
        get {
            return viewModel?.title
        }
        set {}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let flexButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                             target: nil,
                                             action: nil)

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                            target: self,
                                            action: #selector(closeKeyboard(_:)))

        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        keyboardToolbar.items = [flexButtonItem, barButtonItem]
        keyboardToolbar.sizeToFit()
        initialWindowSizeTextField.inputAccessoryView = keyboardToolbar
        maxWindowSizeTextField.inputAccessoryView = keyboardToolbar
        messageSizeTextField.inputAccessoryView = keyboardToolbar
    }

    @objc func closeKeyboard(_ :Any) {
        view.endEditing(true)
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

extension UpdateSettingsViewController {
    func update() {
        let connected = (viewModel as? UpdateSettingsViewModel)?.device?.connected ?? false

        if !connected {
            overlayView?.isHidden = false
            overlayViewLabel?.text = NSLocalizedString("Device disconnected", comment: "Updates Overlay")
        } else {
            overlayView?.isHidden = true
        }
        if let vm = viewModel as? UpdateSettingsViewModel {
            updateUI(settings: vm.settings,
                     canUpdate: vm.canStartUpdate)
        }
    }

    @IBAction func startTapped(_ button: UIButton) {
        guard let vm = viewModel as? UpdateSettingsViewModel else {
            return
        }
        vm.startRequested()
    }

    @IBAction func rwcpToggled(_ switch: UISwitch) {
        guard let vm = viewModel as? UpdateSettingsViewModel else {
            return
        }
        var newSettings = vm.settings
        newSettings.rwcpRequested = !vm.settings.rwcpRequested
        vm.updateSettings(newSettings)
    }

    @IBAction func dleToggled(_ switch: UISwitch) {
        guard let vm = viewModel as? UpdateSettingsViewModel else {
            return
        }
        var newSettings = vm.settings
        newSettings.dleRequested = !vm.settings.dleRequested
        vm.updateSettings(newSettings)
    }

    @IBAction func rwcpInitWindowSizeChanged(_ tf: UITextField) {
        guard
            let vm = viewModel as? UpdateSettingsViewModel,
            let strValue = tf.text,
            let intValue = Int(strValue)
        else {
            return
        }

        var newSettings = vm.settings
        newSettings.rwcpInitialCongestionWindowSize = intValue
        vm.updateSettings(newSettings)
    }

    @IBAction func rwcpMaxWindowSizeChanged(_ tf: UITextField) {
        guard
            let vm = viewModel as? UpdateSettingsViewModel,
            let strValue = tf.text,
            let intValue = Int(strValue)
        else {
            return
        }

        var newSettings = vm.settings
        newSettings.rwcpMaximumInitialCongestionWindowSize = intValue
        vm.updateSettings(newSettings)
    }

    @IBAction func messageSizeChanged(_ tf: UITextField) {
        guard
            let vm = viewModel as? UpdateSettingsViewModel,
            let strValue = tf.text,
            let intValue = Int(strValue)
        else {
            return
        }

        var newSettings = vm.settings
        newSettings.maxMessageSize = intValue
        vm.updateSettings(newSettings)
    }
}

private extension UpdateSettingsViewController {
    func updateUI(settings: RequestedUpdateSettings,
                  canUpdate: Bool) {
        guard let _ = rwcpLabel else {
            return // not loaded yet
        }
        let rwcpSwitchAlpha = CGFloat(settings.rwcpAvailable ? 1.0 : 0.5)

        rwcpLabel.alpha = rwcpSwitchAlpha
        rwcpSwitch.alpha = rwcpSwitchAlpha
        rwcpSwitch.isEnabled = settings.rwcpAvailable

        let rwcpOtherAlpha = CGFloat(settings.rwcpAvailable && settings.rwcpRequested ? 1.0 : 0.5)
        initialWindowSizeLabel.alpha = rwcpOtherAlpha
        initialWindowSizeTextField.alpha = rwcpOtherAlpha
        initialWindowSizeTextField.isEnabled = settings.rwcpAvailable && settings.rwcpRequested

        maxWindowSizeLabel.alpha = rwcpOtherAlpha
        maxWindowSizeTextField.alpha = rwcpOtherAlpha
        maxWindowSizeTextField.isEnabled = settings.rwcpAvailable && settings.rwcpRequested

        let dleSwitchAlpha = CGFloat(settings.dleAvailable ? 1.0 : 0.5)

        dleLabel.alpha = dleSwitchAlpha
        dleSwitch.alpha = dleSwitchAlpha
        dleSwitch.isEnabled = settings.dleAvailable

        let dleOtherAlpha = CGFloat(settings.dleAvailable && settings.dleRequested ? 1.0 : 0.5)
        messageSizeLabel.alpha = dleOtherAlpha
        messageSizeTextField.alpha = dleOtherAlpha
        messageSizeTextField.isEnabled = settings.dleAvailable && settings.dleRequested

        startButton.isEnabled = canUpdate

        // Now set values

        rwcpSwitch.setOn(settings.rwcpRequested, animated: false)
        dleSwitch.setOn(settings.dleRequested, animated: false)

        initialWindowSizeTextField.text = "\(settings.rwcpInitialCongestionWindowSize)"
        maxWindowSizeTextField.text = "\(settings.rwcpMaximumInitialCongestionWindowSize)"

        messageSizeTextField.text = "\(settings.maxMessageSize)"
    }
}
