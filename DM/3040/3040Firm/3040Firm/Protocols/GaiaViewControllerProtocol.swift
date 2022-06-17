//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

protocol GaiaViewControllerProtocol where Self : UIViewController {
    var viewModel: GaiaViewModelProtocol? { get set }
    func update()
}

