//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import UIKit

protocol GaiaViewModelProtocol: class {
    var title: String { get }

    init(coordinator: AppCoordinator,
         gaiaManager: GaiaManagerProtocol,
         notificationCenter: NotificationCenter)

    func activate()
    func deactivate()
    func refresh()
}

protocol GaiaDeviceViewModelProtocol: GaiaViewModelProtocol {
    var device: GaiaDeviceProtocol? { get set }
}
