//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

protocol GaiaDeviceUpdaterPluginProtocol: GaiaDevicePluginProtocol {
    var updateState: UpdateState { get }
    var availableUpdates: [URL] { get }
    var isUpdating: Bool { get }
    var percentProgress: Double { get }
    var startTime: TimeInterval { get }
    var updateUrl: URL? { get }
    var userRequestedSettings: RequestedUpdateSettings? { get }

    var rwcpAvailable: Bool { get }
    var dataLengthExtensionAvailable: Bool { get }
    var maximumWriteLength: Int { get }
    var maximumWriteLengthNoResponse: Int { get }

	func dataReceived(_ data: Data)
    func startUpdate(url: URL,
                     requestedSettings: RequestedUpdateSettings)

    func abort()
    func commitConfirm(value: Bool)
    func confirmForceUpgradeResponse(value: Bool)
    func commitTransferRequired(value: Bool) 
    func confirmError()
}
