//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

protocol GaiaDeviceUpdaterProtocol {
    init(connection: GaiaDeviceConnectionProtocol,
         notificationCenter: NotificationCenter)

    func isSetDataEndpointModeCommand(_ code: UInt16) -> Bool
    func isUpgradeCommand(_ code: UInt16) -> Bool
    func isUpgradeConnectCommand(_ code: UInt16) -> Bool
    func isUpgradeDisconnectCommand(_ code: UInt16) -> Bool
    func isUpgradeControlCommand(_ code: UInt16) -> Bool
    func isRegisterNotificationCommand(_ code: UInt16) -> Bool
    func isGetNotificationCommand(_ code: UInt16) -> Bool
    func isCancelNotificationCommand(_ code: UInt16) -> Bool
    func isEventNotificationCommand(_ code: UInt16) -> Bool

    func isVMUpgradeProtocolPacket(_ notificationID: UInt8) -> Bool

    func getDataEndpointMode()
    func setDataEndpointMode(_ newValue: Bool)
    func registerForUpgradeNotifications()
    func cancelUpgradeNotificationRegistration()
    func vmUpgradeConnect()
    func vmUpgradeDisconnect()
    func vmUpgradeAbort()
    func vmUpgradeStartDataRequest()
    func vmUpgradeStartRequest()
    func vmUpgradeSyncRequest(md5: Data)
    func vmUpgradeIsValidationDoneRequest(md5: Data)
    func vmUpgradeTransferComplete()
    func vmUpgradeTransferAborted()
    func vmUpgradeUpdateComplete()
    func vmUpgradeCommitConfirmRequest(reply: Bool)
    func vmUpgradeConfirmError(errorCode: UInt16)
    func vmUpgradeDataPacket(bytes: Data, moreComing: Bool) -> Data
    func vmUpgradeSendPreformedDataPacketViaGaia(_ packet: Data)
}

extension GaiaDeviceUpdaterProtocol {
    func isUpgradeCommand(_ code: UInt16) -> Bool {
        return isUpgradeConnectCommand(code) ||
            isUpgradeDisconnectCommand(code) ||
            isUpgradeControlCommand(code) ||
            isRegisterNotificationCommand(code) ||
            isGetNotificationCommand(code) ||
            isCancelNotificationCommand(code) ||
            isEventNotificationCommand(code)
    }
}
