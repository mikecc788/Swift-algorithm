//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

class GaiaV3Updater: NSObject, GaiaDeviceUpdaterProtocol {
    let connection: GaiaDeviceConnectionProtocol
    let notificationCenter: NotificationCenter

    required init(connection: GaiaDeviceConnectionProtocol, notificationCenter: NotificationCenter) {
        self.connection = connection
        self.notificationCenter = notificationCenter
    }

    func isSetDataEndpointModeCommand(_ code: UInt16) -> Bool {
        return code == Gaia.V3UpdateCommands.setDataEndPointMode.rawValue
    }

    func isUpgradeConnectCommand(_ code: UInt16) -> Bool {
        return code == Gaia.V3UpdateCommands.vmUpgradeConnect.rawValue
    }

    func isUpgradeDisconnectCommand(_ code: UInt16) -> Bool {
        return code == Gaia.V3UpdateCommands.vmUpgradeDisconnect.rawValue
    }

    func isUpgradeControlCommand(_ code: UInt16) -> Bool {
        return code == Gaia.V3UpdateCommands.vmUpgradeControl.rawValue
    }

    func isRegisterNotificationCommand(_ code: UInt16) -> Bool {
        return false
        //return code == Gaia.V3BasicCommands.registerNotification.rawValue
    }

    func isGetNotificationCommand(_ code: UInt16) -> Bool {
        return false
        //return code == Gaia.V3BasicCommands.getNotification.rawValue
    }

    func isCancelNotificationCommand(_ code: UInt16) -> Bool {
        return false
        //return code == Gaia.V3BasicCommands.cancelNotification.rawValue
    }

    func isEventNotificationCommand(_ code: UInt16) -> Bool {
        return false
        //return code == Gaia.V3BasicCommands.eventNotification.rawValue
    }

    func isVMUpgradeProtocolPacket(_ notificationID: UInt8) -> Bool {
        return notificationID == Gaia.V3UpdateEvents.vmUpgradeProtocolPacket.rawValue
    }

    func getDataEndpointMode() {
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.getDataEndPointMode.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func setDataEndpointMode(_ newValue: Bool) {
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.setDataEndPointMode.rawValue,
                                       payload: Data([newValue ? 0x01 : 0x00]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func registerForUpgradeNotifications() {
        print("Registering for Notifications")
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.registerForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.upgrade.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func cancelUpgradeNotificationRegistration() {
        let message = GaiaV3GATTPacket(featureID: .basic,
                                       commandID: Gaia.V3BasicCommands.unregisterForNotification.rawValue,
                                       payload: Data([GaiaDevicePluginFeatureID.upgrade.rawValue]))
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func vmUpgradeConnect() {
        print("Sending connect")
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeConnect.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func vmUpgradeDisconnect() {
        print("Sending Disconnect")
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeDisconnect.rawValue,
                                       payload: Data())
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func vmUpgradeAbort() {
        sendVMUpgradeControlCommand(.UPGRADE_ABORT_REQ)
    }

    func vmUpgradeStartDataRequest() {
        sendVMUpgradeControlCommand(.UPGRADE_START_DATA_REQ)
    }

    func vmUpgradeStartRequest() {
        sendVMUpgradeControlCommand(.UPGRADE_START_REQ)
    }

    func vmUpgradeSyncRequest(md5: Data) {
        sendVMUpgradeControlCommand(.UPGRADE_SYNC_REQ, md5: md5)
    }

    func vmUpgradeIsValidationDoneRequest(md5: Data) {
        sendVMUpgradeControlCommand(.UPGRADE_IS_VALIDATION_DONE_REQ, md5: md5)
    }

    func vmUpgradeTransferComplete() {
        sendVMUpgradeControlCommand(command: .UPGRADE_TRANSFER_COMPLETE_RES, shouldContinue: true)
    }

    func vmUpgradeTransferAborted() {
        sendVMUpgradeControlCommand(command: .UPGRADE_TRANSFER_COMPLETE_RES, shouldContinue: false)
    }

    func vmUpgradeUpdateComplete() {
        sendVMUpgradeControlCommand(command: .UPGRADE_PROCEED_TO_COMMIT, shouldContinue: true)
    }

    func vmUpgradeCommitConfirmRequest(reply: Bool) {
        sendVMUpgradeControlCommand(command: .UPGRADE_COMMIT_CFM, shouldContinue: reply)
    }

    func vmUpgradeConfirmError(errorCode: UInt16) {
        var payload = Data([Gaia.UpdateControlOperations.UPGRADE_ERROR_RES.rawValue,
                            0x00,
                            0x02
        ])
        payload.append(errorCode.data(bigEndian: true))
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeControl.rawValue,
                                       payload: payload)
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func vmUpgradeDataPacket(bytes: Data, moreComing: Bool) -> Data {
        var payload = Data([Gaia.UpdateControlOperations.UPGRADE_DATA.rawValue])
        let lengthToSend = UInt16(bytes.count + 1)
        payload.append(lengthToSend.data(bigEndian: true))
        payload.append(Data([moreComing ? 0x00 : 0x01]))
        payload.append(bytes)

        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeControl.rawValue,
                                       payload: payload)
        return message.data
    }

    func vmUpgradeSendPreformedDataPacketViaGaia(_ packet: Data) {
        connection.sendData(channel: .command, payload: packet, responseExpected: true)
    }
}

private extension GaiaV3Updater {
    func sendVMUpgradeControlCommand(_ command: Gaia.UpdateControlOperations) {
                print("Sending: \(command)")
        let payload = Data([command.rawValue, 0x00, 0x00])
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeControl.rawValue,
                                       payload: payload)
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func sendVMUpgradeControlCommand(_ command: Gaia.UpdateControlOperations, md5: Data) {
                print("Sending: \(command)")
        precondition(md5.count > 15)

        var payload = Data([command.rawValue, 0x00, 0x04])
        payload.append(md5[12...15])
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeControl.rawValue,
                                       payload: payload)
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }

    func sendVMUpgradeControlCommand(command: Gaia.UpdateControlOperations, shouldContinue: Bool) {
                print("Sending: \(command)")
        let payload = Data([command.rawValue,
                            0x00,
                            0x01,
                            shouldContinue ? Gaia.UpdateDataAction.noAbort.rawValue : Gaia.UpdateDataAction.abort.rawValue
        ])
        let message = GaiaV3GATTPacket(featureID: .upgrade,
                                       commandID: Gaia.V3UpdateCommands.vmUpgradeControl.rawValue,
                                       payload: payload)
        connection.sendData(channel: .command, payload: message.data, responseExpected: true)
    }
}
