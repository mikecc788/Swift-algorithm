//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

protocol UpdateProgressViewControllerProtocol {
    func showConfirmationDialog(ok: @escaping ()->(), cancel: @escaping ()->())
    func showConfirmBatteryLowDialog(ok: @escaping ()->())
    func showConfirmForceUpgradeDialog(ok: @escaping ()->(), cancel: @escaping ()->())
    func showConfirmTransferRequiredDialog(ok: @escaping ()->(), cancel: @escaping ()->())
}

class UpdateProgressViewController: UIViewController, GaiaViewControllerProtocol, UpdateProgressViewControllerProtocol {
	var viewModel: GaiaViewModelProtocol?
    
    @IBOutlet weak var exitButton: UIButton?
    @IBOutlet weak var progressBar: UIProgressView?
    @IBOutlet weak var statusText: UILabel?
    @IBOutlet weak var etaText: UILabel?

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

extension UpdateProgressViewController {
    func update() {
        guard let vm = viewModel as? UpdateProgressViewModel else {
            return
        }

        let btnText = vm.canExit ?
            NSLocalizedString("Exit", comment: "Button Text") :
            NSLocalizedString("Abort", comment: "Button Text")

        exitButton?.setTitle(btnText, for: .normal)
        exitButton?.setTitle(btnText, for: .highlighted)
        exitButton?.setTitle(btnText, for: .selected)

        statusText?.text = vm.statusText
        etaText?.text = vm.progressText
        progressBar?.progress = Float(vm.progress)
    }

    @IBAction func buttonTapped(_ : Any) {
        guard let vm = viewModel as? UpdateProgressViewModel else {
			return
        }

        if vm.canExit {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            vm.abortRequested()
        }
    }
}

extension UpdateProgressViewController {
    func showConfirmationDialog(ok: @escaping ()->(),
                                cancel: @escaping ()->()) {
        let alert = UIAlertController(title: NSLocalizedString("Finalize Update", comment: "Updater Dialog"),
                                      message: NSLocalizedString("Would you like to complete the upgrade?", comment: "Updater Dialog"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                      style: .default) { _ in ok() })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                      style: .cancel) { _ in cancel() })

        present(alert, animated: true, completion: nil)
    }

	func showConfirmBatteryLowDialog(ok: @escaping ()->()) {
        let alert = UIAlertController(title: NSLocalizedString("Battery Low", comment: "Updater Dialog"),
                                      message: NSLocalizedString("The battery is low on your audio device. Please connect it to a charger", comment: "Updater Dialog"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                      style: .default) { _ in ok() })

        present(alert, animated: true, completion: nil)
    }

    func showConfirmForceUpgradeDialog(ok: @escaping ()->(), cancel: @escaping ()->()){
        let alert = UIAlertController(title: NSLocalizedString("Synchronisation Failed", comment: "Updater Dialog"),
                                      message: NSLocalizedString("Another update has already been started. Would you like to force the upgrade?", comment: "Updater Dialog"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                      style: .default) { _ in ok() })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                      style: .cancel) { _ in cancel() })

        present(alert, animated: true, completion: nil)
    }

    func showConfirmTransferRequiredDialog(ok: @escaping ()->(), cancel: @escaping ()->()) {
        let alert = UIAlertController(title: NSLocalizedString("File transfer complete", comment: "Updater Dialog"),
                                      message: NSLocalizedString("Would you like to proceed?", comment: "Updater Dialog"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                      style: .default) { _ in ok() })

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                      style: .cancel) { _ in cancel() })

        present(alert, animated: true, completion: nil)
    }
}
