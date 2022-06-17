//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Notification.Name {
    static var GaiaDeviceUpdaterPluginNotification = Notification.Name("GaiaDeviceUpdaterPluginNotification")
}

struct GaiaDeviceUpdaterPluginNotification: GaiaNotification {
    enum Reason {
        case statusChanged
    }

    var sender: GaiaNotificationSender
    var payload: GaiaDeviceProtocol?
    var reason: Reason

    static var name: Notification.Name = .GaiaDeviceUpdaterPluginNotification
}

enum UpdateStateProgress {
    case awaitingConfirmation
    case awaitingConfirmForceUpgrade
    case awaitingConfirmTransferRequired
    case awaitingConfirmBatteryLow
    case transferring
    case restarting
    case handover
}

enum UpdateStateDone {
    case completed
    case aborted(error: Error?)
}

enum UpdateState {
    case ready
    case busy(progress: UpdateStateProgress)
    case stopped(reason: UpdateStateDone)
}

class UpdateProgressInfo {
    enum GaiaUpdateResumePoint: UInt8 {
        case start
        case validate
        case reboot
        case postReboot
        case commit
    }

    var fileData: Data?
    var fileMD5: Data?
    var dataBuffer = [Data]()
    var startTime: TimeInterval = 0
    var resumePoint: GaiaUpdateResumePoint = .start
    var userState = UpdateState.ready
    var lastError: Gaia.UpdateResponseCodes = .success
	var updateInProgress = false
    var needToValidate = false
    var useRWCP = false
    var useDLE = false
    var didAbort = false
    var syncAfterAbort = false

    var rwcpMaxLength: UInt = 0
    var gaiaMaxLength: UInt = 0

    var progress: UInt32 = 0
    var transferSize: UInt32 = 0
    var startOffset: UInt32 = 0
    var bytesToSend: UInt32 = 0
}

class GaiaDeviceUpdaterPlugin: NSObject, // NSObject because RWCP delegate (vide infra)
                               GaiaDeviceUpdaterPluginProtocol,
GaiaNotificationSender {
    static let featureID: GaiaDevicePluginFeatureID = .upgrade
    private let GAIANonDLEMaxLength: UInt = 12
    private let RWCPNonDLEMaxLength: UInt = 10

    let title = NSLocalizedString("Software Updates", comment: "Plugin title")
    var subtitle: String? {
        let number = availableUpdates.count
        return String(format: NSLocalizedString("%d available", comment: "Tableview subtitle"), number)
    }

    private let devicePluginVersion: UInt8
    private weak var device: GaiaDeviceProtocol!
    private let connection: GaiaDeviceConnectionProtocol
    private let notificationCenter : NotificationCenter

    private let updater: GaiaDeviceUpdaterProtocol?
    private let rwcpHandler: QTIRWCP?

    private(set) var rwcpAvailable = false
    private var registeredForNotifications = false

    private(set) var updateUrl: URL?

    var updateState: UpdateState {
        return updateProgress.userState
    }

    var percentProgress: Double {
        if updateProgress.transferSize == 0 {
            return 0
        }
        return (Double(updateProgress.progress) / Double(updateProgress.transferSize)) * 100.0
    }

    var startTime: TimeInterval {
        return updateProgress.startTime
    }

    private var updateProgress: UpdateProgressInfo
    private(set) var userRequestedSettings: RequestedUpdateSettings?


    var isUpdating: Bool {
        return updateProgress.updateInProgress
    }

    var dataLengthExtensionAvailable: Bool {
        return connection.isDataLengthExtensionSupported
    }

    var maximumWriteLength: Int {
        return connection.maximumWriteLength
    }

    var maximumWriteLengthNoResponse: Int {
        return connection.maximumWriteWithoutResponseLength
    }

    required init(version: UInt8,
                  device: GaiaDeviceProtocol,
                  connection: GaiaDeviceConnectionProtocol,
                  notificationCenter: NotificationCenter) {
        
        self.devicePluginVersion = version
        self.device = device
        self.connection = connection
        self.notificationCenter = notificationCenter
        self.updateProgress = UpdateProgressInfo()

        switch device.version {
        case .v2:
            updater = GaiaV2Updater(connection: connection, notificationCenter: notificationCenter)
        case .v3:
            updater = GaiaV3Updater(connection: connection, notificationCenter: notificationCenter)
        default:
            updater = nil
        }

        rwcpHandler = QTIRWCP(connection: connection)

        super.init()
        rwcpHandler?.delegate = self
    }

    deinit {
        print("DEINIT")
        if updateProgress.useRWCP {
            print("Killing RWCP")
            rwcpHandler?.teardown()
        }
    }

    func startPlugin() {
        updater?.registerForUpgradeNotifications()
		updater?.setDataEndpointMode(true)
    }

    func stopPlugin() {
		updater?.cancelUpgradeNotificationRegistration()
    }

	func responseReceived(messageDescription: IncomingMessageDescription) {
        guard
            let _ = updater
        else {
            return
        }

        handleResponseReceived(messageDescription: messageDescription)
    }

    func dataReceived(_ data: Data) {
        rwcpHandler?.didReceive(data)
    }

    func didSendData(channel: GaiaDeviceConnectionChannel, error: Error?) {
        if channel == .command && updateProgress.updateInProgress {
            handleDataSent(error: error)
        }
    }
}

extension GaiaDeviceUpdaterPlugin {
    var availableUpdates: [URL] {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask,
                                                        true)
        guard let documentsDirectory = paths.first else {
            return []
        }

        do {
            let filePaths = try FileManager.default.subpathsOfDirectory(atPath: documentsDirectory)
            return filePaths
                .filter({ $0.hasSuffix(".bin") })
                .map({ URL(fileURLWithPath: documentsDirectory + "//\($0)") })
        } catch {
            return []
        }
    }
}

extension GaiaDeviceUpdaterPlugin {
    func startUpdate(url: URL,
                     requestedSettings: RequestedUpdateSettings) {
        guard !updateProgress.updateInProgress else {
            return
        }

        updateUrl = url
        userRequestedSettings = requestedSettings

        updateProgress = UpdateProgressInfo()
        updateProgress.useRWCP = requestedSettings.rwcpRequested
        updateProgress.useDLE = requestedSettings.dleRequested

        if requestedSettings.rwcpRequested {
            rwcpHandler?.initialCongestionWindowSize = requestedSettings.rwcpInitialCongestionWindowSize
            rwcpHandler?.maximumCongestionWindowSize = requestedSettings.rwcpMaximumInitialCongestionWindowSize
        }

        do {
            updateProgress.fileData = try Data(contentsOf: url)
        } catch let e {
            setUserStateAndNotify(.stopped(reason: .aborted(error: e)))
            return
        }

        updateProgress.fileMD5 = updateProgress.fileData?.md5()
        updateProgress.transferSize = UInt32(updateProgress.fileData?.count ?? 0)

        if requestedSettings.rwcpRequested && rwcpAvailable {
            // Max size - 13
            if requestedSettings.dleRequested && dataLengthExtensionAvailable {
                updateProgress.rwcpMaxLength = UInt((requestedSettings.maxMessageSize - 13) / 2) * 2 // Round down to even number
            } else {
                updateProgress.rwcpMaxLength = RWCPNonDLEMaxLength;
            }

            rwcpHandler?.fileSize = UInt(updateProgress.fileData?.count ?? 0)
        } else {
            // Max size - 11
            if requestedSettings.dleRequested && dataLengthExtensionAvailable {
                updateProgress.gaiaMaxLength = UInt((requestedSettings.maxMessageSize - 11) / 2) * 2 // Round down to even number
            } else {
                updateProgress.gaiaMaxLength = GAIANonDLEMaxLength;
            }
        }

        updateProgress.updateInProgress = true
        setUserStateAndNotify(.busy(progress: .transferring))

        updateProgress.startTime = Date.timeIntervalSinceReferenceDate
        print("GaiaCommand_RegisterNotification > vmUpgradeConnect")
        updater?.vmUpgradeConnect()
    }

    func abort() {
        if updateProgress.useRWCP {
            rwcpHandler?.abort()
        }
        
        abortUpdateInProgress()
    }

    func commitConfirm(value: Bool) {
        updater?.vmUpgradeCommitConfirmRequest(reply: value)
    }

    func confirmForceUpgradeResponse(value: Bool) {
        if value {
            updateProgress.syncAfterAbort = true
            abort()
        } else {
            setUserStateAndNotify(.stopped(reason: .aborted(error: nil)))
        }
    }

    func commitTransferRequired(value: Bool) {
        if value {
        	updater?.vmUpgradeTransferComplete()
        } else {
            updater?.vmUpgradeTransferAborted()
        }
        willDisconnectDevice(aborted: !value)
    }

    func confirmError() {
        updater?.vmUpgradeConfirmError(errorCode: UInt16(updateProgress.lastError.rawValue))
    }
}

private extension GaiaDeviceUpdaterPlugin {
    func abortUpdateInProgress() {
        if updateProgress.updateInProgress {
            updateProgress.didAbort = true
            print("GaiaUpdate_AbortRequest > vmUpgradeControl")
            updateProgress.dataBuffer.removeAll()
            updater?.vmUpgradeAbort()
        }
    }

    func handleDataSent(error: Error?) {
        guard !updateProgress.useRWCP && !updateProgress.didAbort else {
            return
        }

        guard updateProgress.dataBuffer.count > 0 else {
            if updateProgress.needToValidate &&
                (updateProgress.bytesToSend + updateProgress.startOffset) >= updateProgress.transferSize {
                updateProgress.needToValidate = false
                updater?.vmUpgradeIsValidationDoneRequest(md5: updateProgress.fileMD5!)
            }
            return
        }

        if let _ = error {
            // Disconnect and restart
			willDisconnectDevice(aborted: false)
        } else {
            let dataToSend = updateProgress.dataBuffer.removeFirst()
            updateProgress.progress = updateProgress.progress + UInt32(dataToSend.count - 8)
            print("Sending packet. \(updateProgress.dataBuffer.count) remaining.")
            updater?.vmUpgradeSendPreformedDataPacketViaGaia(dataToSend)
        }
    }

    func willDisconnectDevice(aborted: Bool) {
        if updateProgress.updateInProgress {
            setUserStateAndNotify(.busy(progress: .restarting))
            updateProgress.progress = 0
            updateProgress.startOffset = 0
            updateProgress.bytesToSend = 0

            if (updateProgress.useRWCP) {
                rwcpHandler?.powerOff()
            }
        } else {
            updateProgress = UpdateProgressInfo()
            if aborted {
                setUserStateAndNotify(.stopped(reason: .aborted(error: nil)))
            } else {
                setUserStateAndNotify(.stopped(reason: .completed))
            }
        }
    }

    func setUserStateAndNotify(_ newState: UpdateState) {
        updateProgress.userState = newState
        let notification = GaiaDeviceUpdaterPluginNotification(sender: self,
                                                               payload: device,
                                                               reason: .statusChanged)
        notificationCenter.post(notification)
    }
}

private extension GaiaDeviceUpdaterPlugin {
    func handleResponseReceived(messageDescription: IncomingMessageDescription) {
        guard let updater = updater else {
            return
        }

        switch messageDescription {
        case .response(let command, _):
            if updater.isRegisterNotificationCommand(command) {
                print("Updater is registered for notifications")
                registeredForNotifications = true
            } else if updater.isUpgradeDisconnectCommand(command) {
                print("VMUpgradeDisconnect acknowledged.")
                if updateProgress.didAbort {
                    // Persist abort error across clean up
                    var abortError: Error? = nil
                    switch updateProgress.userState {
                    case .stopped(let reason):
                        switch reason {
                        case .aborted(let error):
                            abortError = error
                        default:
                            break
                        }
                    default:
                        break
                    }
                    updateProgress = UpdateProgressInfo()
                    setUserStateAndNotify(.stopped(reason: .aborted(error: abortError)))
                } else {
                    updateProgress = UpdateProgressInfo()
                    setUserStateAndNotify(.stopped(reason: .completed))
                }
            } else if updater.isSetDataEndpointModeCommand(command) {
                print("RWCP Available")
                rwcpAvailable = true
            } else if updater.isUpgradeConnectCommand(command) && isUpdating {
                updater.vmUpgradeSyncRequest(md5: updateProgress.fileMD5!)
            }
        case .error(let command, _, _):
            if (updater.isUpgradeConnectCommand(command) ||
                updater.isUpgradeControlCommand(command)) &&
                isUpdating {
                print("Error Received - Connect or Control")
                abortUpdateInProgress()
            } else if updater.isSetDataEndpointModeCommand(command) {
				print("RWCP is not Available")
                rwcpAvailable = false
            }
        case .notification(let notificationID, let data):
            guard updater.isVMUpgradeProtocolPacket(notificationID),
            	data.count >= 3 else {
                return
            }
            if let updateEventCode = data.first,
                let controlOperation = Gaia.UpdateControlOperations(rawValue: updateEventCode),
                let _ = UInt16(data: data, offset: 1, bigEndian: true) {
                let upgradePayload = data.count > 3 ? data.advanced(by: 3) : Data()
                // UpgradePayload now points to the bytes after the length.
                print("Notification Received: \(controlOperation)")
                switch controlOperation {
                case .UPGRADE_SYNC_REQ,
                     .UPGRADE_START_REQ,
                     .UPGRADE_ABORT_REQ,
                     .UPGRADE_START_DATA_REQ,
                     .UPGRADE_DATA,
                     .UPGRADE_IS_VALIDATION_DONE_REQ,
                     .UPGRADE_COMMIT_CFM,
                     .UPGRADE_TRANSFER_COMPLETE_RES,
                     .UPGRADE_PROCEED_TO_COMMIT,
                     .UPGRADE_ERROR_RES:
                    // These are all outgoing messages
                    break
                case .UPGRADE_START_CFM:
                    if upgradePayload.first ?? 1 != 0 {
                        // abort
                        updateProgress = UpdateProgressInfo()
                        let reasonStr = NSLocalizedString("Update Error", comment: "General error reason")
                        let error = NSError(domain: Gaia.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : reasonStr])
                        setUserStateAndNotify(.stopped(reason: .aborted(error: error)))
                        return
                    }
                    switch updateProgress.resumePoint {
                    case .start:
                        print("UPGRADE_START_CFM - Resume Point Start")
                        updateProgress.startTime = Date.timeIntervalSinceReferenceDate
                        updater.vmUpgradeStartDataRequest()
                    case .validate:
                        print("UPGRADE_START_CFM - Resume Point Validate")
                        updater.vmUpgradeIsValidationDoneRequest(md5: upgradePayload.md5())
                    case .reboot:
                        print("UPGRADE_START_CFM - Resume Point Reboot")
                        setUserStateAndNotify(.busy(progress: .awaitingConfirmTransferRequired))
                    case .postReboot:
                        print("UPGRADE_START_CFM - Resume Point Post Reboot")
                        updater.vmUpgradeUpdateComplete()
                    case .commit:
                        print("UPGRADE_START_CFM - Resume Point Commit")
                        updater.vmUpgradeCommitConfirmRequest(reply: true)
                    }
                case .UPGRADE_DATA_BYTES_REQ:
                    dataRequest(upgradePayload: upgradePayload)
                case .UPGRADE_ABORT_CFM:
                    if updateProgress.syncAfterAbort {
                        updateProgress.syncAfterAbort = false
                        updateProgress.progress = 0
                        updateProgress.transferSize = UInt32(updateProgress.fileData?.count ?? 0)
                        updateProgress.startOffset = 0
                        updateProgress.bytesToSend = 0
                        updateProgress.updateInProgress = true
                        updateProgress.resumePoint = .start
                        updater.vmUpgradeSyncRequest(md5: updateProgress.fileMD5!)
                    } else {
                        print("Abort successful")
                        updateProgress.didAbort = true
                    	updater.vmUpgradeDisconnect()
                    }
                case .UPGRADE_TRANSFER_COMPLETE_IND:
                    setUserStateAndNotify(.busy(progress: .awaitingConfirmTransferRequired))
                case .UPGRADE_COMMIT_REQ:
                    setUserStateAndNotify(.busy(progress: .awaitingConfirmation))
                case .UPGRADE_ERROR_IND:
                    if upgradePayload.count > 1 {
                        let updateErrorByte = upgradePayload[1]
                        if let updateError = Gaia.UpdateResponseCodes(rawValue: updateErrorByte),
                            updateError != .success {
                            updateProgress.lastError = updateError
                            if updateError == .warnSyncIdIsDifferent {
                                setUserStateAndNotify(.busy(progress: .awaitingConfirmForceUpgrade))
                            } else if updateError == .errorBatteryLow {
								setUserStateAndNotify(.busy(progress: .awaitingConfirmBatteryLow))
                            } else if updateError == .errorHandoverDFUAbort {
                                // Handover will happen. Just ack, stop and wait for disconnect to happen.
								updater.vmUpgradeConfirmError(errorCode: UInt16(updateProgress.lastError.rawValue))
                                if updateProgress.useRWCP {
                                      rwcpHandler?.abort()
                                }
                                updateProgress.dataBuffer.removeAll()
                                setUserStateAndNotify(.busy(progress: .handover))
                            } else {
								// Abort
        						updater.vmUpgradeConfirmError(errorCode: UInt16(updateProgress.lastError.rawValue))
                                if updateProgress.useRWCP {
                                      rwcpHandler?.abort()
                                }
                                abortUpdateInProgress()
                                let error = NSError(domain: Gaia.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : updateError.userDescription()])
                                setUserStateAndNotify(.stopped(reason: .aborted(error: error)))
                            }
                        }
                    }
                case .UPGRADE_COMPLETE_IND:
                    updater.vmUpgradeDisconnect()
                case .UPGRADE_SYNC_CFM:
                    let state = upgradePayload.first ?? 0
                    updateProgress.resumePoint = UpdateProgressInfo.GaiaUpdateResumePoint(rawValue: state) ?? .start
                    updater.vmUpgradeStartRequest()
                case .UPGRADE_IS_VALIDATION_DONE_CFM:
                    // We get a reply to wait a bit
                    if let delay = UInt16(data: upgradePayload, offset: 0, bigEndian: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)/1000.0) { [weak self] in
                            guard
                                let self = self,
                                self.updateProgress.updateInProgress
                            else {
								return
                            }
                            self.updater?.vmUpgradeIsValidationDoneRequest(md5: self.updateProgress.fileMD5!)
                        }
                    } else {
                        updater.vmUpgradeIsValidationDoneRequest(md5: updateProgress.fileMD5!)
                    }
                }

            }
        default:
            break
        }
    }

    func dataRequest(upgradePayload: Data) {
        guard
            let numberOfBytesReq = UInt32(data:upgradePayload, offset: 0, bigEndian: true),
            let fileOffsetReq = UInt32(data:upgradePayload, offset: 4, bigEndian: true),
            numberOfBytesReq + fileOffsetReq <= UInt32(updateProgress.fileData?.count ?? 0),
            let updater = updater
        else {
            abortUpdateInProgress()
            return
        }

        setUserStateAndNotify(.busy(progress: .transferring))
        print("Requested: \(numberOfBytesReq) from offset \(fileOffsetReq)")

        let fileLength = UInt32(updateProgress.fileData?.count ?? 0)
        updateProgress.bytesToSend = numberOfBytesReq // Start with what we were asked for
        if fileOffsetReq > 0 {
            updateProgress.progress = fileOffsetReq
            if fileOffsetReq + updateProgress.startOffset < fileLength {
                updateProgress.startOffset += fileOffsetReq
            }
        }

        let remainingLength = fileLength - updateProgress.startOffset
        updateProgress.bytesToSend = min(updateProgress.bytesToSend, remainingLength)
        let maxLength = UInt32(updateProgress.useRWCP ? updateProgress.rwcpMaxLength : updateProgress.gaiaMaxLength)

        var newPackets = [Data]()

        print("Starting bytes at \(updateProgress.startOffset)")

        while updateProgress.bytesToSend > 0 && !updateProgress.didAbort {

            let bytesInPacket = min(updateProgress.bytesToSend, maxLength - 1)

            let lastPacket = fileLength - updateProgress.startOffset <= bytesInPacket
            let fileDataToSend = updateProgress.fileData!.subdata(in: Int(updateProgress.startOffset)..<Int(updateProgress.startOffset + bytesInPacket))

            let bytes = updater.vmUpgradeDataPacket(bytes: fileDataToSend, moreComing: !lastPacket)
            if updateProgress.useRWCP {
                rwcpHandler?.setPayload(bytes)
                if lastPacket {
                    rwcpHandler?.lastByteSent = true
                }
            } else {
				newPackets.append(bytes)
            }

            if lastPacket {
                updateProgress.needToValidate = true
            }

            updateProgress.bytesToSend -= bytesInPacket
            updateProgress.startOffset += bytesInPacket
        }

        if updateProgress.useRWCP {
            rwcpHandler?.startTransfer()
        } else {
            updateProgress.dataBuffer += newPackets
            handleDataSent(error: nil) // Sends the first item or requests validation
        }
        print("Done adding bytes")
    }
}

extension GaiaDeviceUpdaterPlugin: QTIRWCPDelegate {
    func didAbortWithError(_ error: Error) {
        abortUpdateInProgress()
        setUserStateAndNotify(.stopped(reason: .aborted(error: error)))
    }

    func didCompleteDataSend() {
        print("did complete data send")
        if updateProgress.updateInProgress && !updateProgress.didAbort && updateProgress.needToValidate {
            updateProgress.needToValidate = false
            updater?.vmUpgradeIsValidationDoneRequest(md5: updateProgress.fileMD5!)
        }
    }

    func didMakeProgress(_ value: Double) {
        updateProgress.progress += UInt32(value)
    }
}
