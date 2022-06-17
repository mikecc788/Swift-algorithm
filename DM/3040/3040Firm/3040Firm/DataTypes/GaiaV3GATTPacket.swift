//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

private enum V3MessageReason: UInt8 {
    case command = 0b00
    case notification = 0b01
    case response = 0b10
    case error = 0b11
}

struct GaiaV3GATTPacket: IncomingMessageProtocol {
    let vendorID: UInt16
    let featureID: GaiaDevicePluginFeatureID

    private let commandID: UInt16
    private let payload: Data
    private let reason: V3MessageReason

    var messageDescription: IncomingMessageDescription {
        switch reason {
        case .command:
            return .unknown
        case .notification:
            return .notification(notificationID: UInt8(commandID),
                                 data: payload)
        case .response:
            return .response(command: commandID,
                             data: payload)
        case .error:
            let trimmedPayload = payload.count > 1 ? payload.advanced(by: 1) : Data()
            // We tried use dropFirst here but accessing by subscript subsequently failed.
            return .error(command: commandID,
                          errorCode: payload.first ?? 0,
                          data: trimmedPayload)
        }
    }

    init(featureID: GaiaDevicePluginFeatureID,
         commandID: UInt16,
         payload: Data) {
        self.vendorID = Gaia.v3VendorID
        self.featureID = featureID
        self.commandID = commandID
        self.reason = .command
        self.payload = payload
    }

    init?(data: Data) {
        guard data.count >= 4 else {
            return nil
        }
        vendorID = UInt16(data: data, offset: 0, bigEndian: true)!

        let featureIDByte = data[2]
        var workingReason = (featureIDByte & 0b00000001) << 1
        if let id = GaiaDevicePluginFeatureID(rawValue: (featureIDByte & 0b11111110) >> 1) {
            featureID = id
        } else {
            featureID = .unknown
        }

        let commandIDByte = data[3]
		workingReason = workingReason + ((commandIDByte & 0b10000000) >> 7)
        if let workingReason = V3MessageReason(rawValue: workingReason) {
            reason = workingReason
        } else {
            reason = .error
        }

        commandID = UInt16(commandIDByte & 0b01111111)
        payload = data.count > 4 ? data.advanced(by: 4) : Data()
    }

    var data: Data {
        var byteArray = vendorID.data(bigEndian: true)
        var workingFeatureByte = (featureID.rawValue << 1) & 0b11111110
        let typeRaw = reason.rawValue
        workingFeatureByte |= ((typeRaw >> 1) & 0b00000001)
        byteArray.append(workingFeatureByte)

        var workingCommandByte = UInt8(commandID & 0b0000000001111111)
        workingCommandByte |= ((typeRaw & 0b00000001) << 7)
        byteArray.append(workingCommandByte)
		return Data(byteArray) + payload
    }
}
