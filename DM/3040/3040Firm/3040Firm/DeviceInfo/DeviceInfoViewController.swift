//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class DeviceInfoViewController: UIViewController, GaiaViewControllerProtocol {
    var viewModel: GaiaViewModelProtocol?

    @IBOutlet weak var chargeStatusImageView: UIImageView!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var variantNameLabel: UILabel!
	@IBOutlet weak var applicationVersionLabel: UILabel!
    @IBOutlet weak var apiVersionLabel: UILabel!
    @IBOutlet weak var serialNumberTitleLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!

    @IBOutlet weak var connectionButton: UIButton!

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

    private enum ConnectionButtonType {
        case show
        case connect
        case disconnect
    }

    private func setConnectionButtonTitleAndColor(_ type: ConnectionButtonType) {
        
    }

    func update() {
        guard let deviceInfoViewModel = viewModel as? DeviceInfoViewModel else {
            return
        }

        if let device = deviceInfoViewModel.device {
            if deviceInfoViewModel.devicesAreAvailable {
                connectionButton.isEnabled = true
                if device.version == .unknown {
                    setConnectionButtonTitleAndColor(.show)
                } else {
                    setConnectionButtonTitleAndColor(device.connected ? .disconnect : .connect)
                }
            } else {
                connectionButton.isEnabled = false
                setConnectionButtonTitleAndColor(.connect)
            }

            deviceNameLabel.text = device.name
            applicationVersionLabel.isHidden = device.version != .v3
            apiVersionLabel.isHidden = device.version == .unknown
            serialNumberLabel.isHidden = device.version != .v3
            serialNumberTitleLabel.isHidden = device.version != .v3
            variantNameLabel.isHidden = false
            chargeStatusImageView.isHighlighted = device.version != .v3

            if device.version == .v3 {
                switch device.deviceType {
                case.unknown:
                    deviceImageView.image = UIImage(systemName: "questionmark")
                case .earbud:
					deviceImageView.image = UIImage(named: "icon-device-earbuds")
                case .headphones:
					deviceImageView.image = UIImage(named: "icon-device-headphones")
                }
                deviceImageView.image = UIImage(systemName: "headphones")
                chargeStatusImageView.image = device.isCharging ?
                    UIImage(systemName: "bolt.fill") :
                    UIImage(systemName: "bolt.slash.fill")
                variantNameLabel.text = device.deviceVariant
                applicationVersionLabel.text = NSLocalizedString("Application Version: ", comment: "App Version") + "\(device.applicationVersion)"
                apiVersionLabel.text = NSLocalizedString("API Version: ", comment: "API Version") + "\(device.apiVersion)"
                serialNumberLabel.text = "\(device.serialNumber)"
            } else if device.version == .v2 {
                deviceImageView.image = UIImage(named: "icon-device-earbuds")
                apiVersionLabel.text = NSLocalizedString("API Version: ", comment: "API Version") + "\(device.apiVersion)"
                variantNameLabel.text = NSLocalizedString("This device may be updated in Settings", comment: "This device may be updated in Settings")
            } else {
                deviceImageView.image = UIImage(systemName: "questionmark")
                variantNameLabel.text = NSLocalizedString("This is not a supported device", comment: "This is not a supported device")
            }
        } else {
            setConnectionButtonTitleAndColor(.connect)
            connectionButton.isEnabled = deviceInfoViewModel.devicesAreAvailable

            deviceNameLabel.text = "No Device"
            variantNameLabel.isHidden = true
            applicationVersionLabel.isHidden = true
            serialNumberLabel.isHidden = true
            serialNumberTitleLabel.isHidden = true
        }
    }
}

extension DeviceInfoViewController {
    @IBAction func connectionButtonTapped(_ button: UIButton) {
        guard let deviceInfoViewModel = viewModel as? DeviceInfoViewModel else {
            return
        }

        deviceInfoViewModel.connectDisconnect()
    }
}
