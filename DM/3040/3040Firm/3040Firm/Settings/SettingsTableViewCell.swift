//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

class ClosureSwitch: UISwitch {
    typealias DidTapHandler = (ClosureSwitch) -> ()

    var tapHandler: DidTapHandler? {
        didSet {
            if tapHandler != nil {
                addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
            }
        }
    }

    @objc func didTouchUpInside(_ : UIButton) {
        if let tapHandler = tapHandler {
            tapHandler(self)
        }
    }
}

class ClosureStepper: UIStepper {
    typealias DidChangeHandler = (ClosureStepper) -> ()
    var valueChangedHandler: DidChangeHandler? {
        didSet {
            if valueChangedHandler != nil {
                addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
            } else {
                removeTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
            }
        }
    }

    @objc func valueChanged(_ : UIStepper) {
        if let handler = valueChangedHandler {
            handler(self)
        }
    }
}

class SettingsTableViewCell: UITableViewCell {
    enum ViewOption {
        case titleOnly
        case titleAndSwitch
        case titleAndSubtitle
        case titleSubtitleAndStepper
    }

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var onOffSwitch: ClosureSwitch?
    @IBOutlet weak var stepper: ClosureStepper?

    var viewOption = ViewOption.titleOnly {
        didSet {
            switch viewOption {
            case .titleOnly:
                subtitleLabel?.isHidden = true
                onOffSwitch?.isHidden = true
                stepper?.isHidden = true
            case .titleAndSwitch:
                subtitleLabel?.isHidden = true
                onOffSwitch?.isHidden = false
                stepper?.isHidden = true
            case .titleAndSubtitle:
                subtitleLabel?.isHidden = false
                onOffSwitch?.isHidden = true
                stepper?.isHidden = true
            case .titleSubtitleAndStepper:
                subtitleLabel?.isHidden = false
                onOffSwitch?.isHidden = true
                stepper?.isHidden = false
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onOffSwitch?.tapHandler = nil
        stepper?.valueChangedHandler = nil
    }
}
