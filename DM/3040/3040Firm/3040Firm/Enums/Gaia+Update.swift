//
//  © 2020 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
//

import Foundation

extension Gaia {
    enum UpdateControlOperations: UInt8 {
        case UPGRADE_START_REQ                     = 0x01
        case UPGRADE_START_CFM                     = 0x02
        case UPGRADE_DATA_BYTES_REQ                = 0x03
        case UPGRADE_DATA                          = 0x04
        case UPGRADE_ABORT_REQ                     = 0x07
        case UPGRADE_ABORT_CFM                     = 0x08
        case UPGRADE_TRANSFER_COMPLETE_IND         = 0x0B
        case UPGRADE_TRANSFER_COMPLETE_RES         = 0x0C
        case UPGRADE_PROCEED_TO_COMMIT             = 0x0E
        case UPGRADE_COMMIT_REQ                    = 0x0F
        case UPGRADE_COMMIT_CFM                    = 0x10
        case UPGRADE_ERROR_IND                     = 0x11
        case UPGRADE_COMPLETE_IND                  = 0x12
        case UPGRADE_SYNC_REQ                      = 0x13
        case UPGRADE_SYNC_CFM                      = 0x14
        case UPGRADE_START_DATA_REQ                = 0x15
        case UPGRADE_IS_VALIDATION_DONE_REQ        = 0x16
        case UPGRADE_IS_VALIDATION_DONE_CFM        = 0x17
        case UPGRADE_ERROR_RES                     = 0x1F
    }

    enum UpdateDataAction: UInt8 {
        case noAbort                      = 0x00
        case abort                         = 0x01
    }

    enum UpdateResponseCodes: UInt8 {
        case success                          = 0x00
        case errorUnknownId                   = 0x11
        case errorBadLength                   = 0x12
        case errorWrongVariant                = 0x13
        case errorWrongPartitionNumber        = 0x14
        case errorPartitionSizeMismatch       = 0x15
        case errorPartitionTypeNotFound       = 0x16
        case errorPartitionOpenFailed         = 0x17
        case errorPartitionWriteFailed        = 0x18
        case errorPartitionCloseFailed        = 0x19
        case errorSFSValidationFailed         = 0x1A
        case errorOEMValidationFailed         = 0x1B
        case errorUpdateFailed                = 0x1C
        case errorAppNotReady                 = 0x1D
        case errorLoaderError                 = 0x1E
        case errorUnexpectedLoaderMessage     = 0x1F
        case errorMissingLoaderMessage        = 0x20
        case errorBatteryLow                  = 0x21
        case errorInvalidSyncId               = 0x22
        case errorInErrorState                = 0x23
        case errorNoMemory                    = 0x24
        case errorHandoverDFUAbort			  = 0x28
        case errorBadLengthPartitionParse     = 0x30
        case errorBadLengthTooShort           = 0x31
        case errorBadLengthUpgradeHeader      = 0x32
        case errorBadLengthPartitionHeader    = 0x33
        case errorBadLengthSignature          = 0x34
        case errorBadLengthDataHeaderResume   = 0x35
        case errorOEMValidationFailedHeader   = 0x38
        case errorOEMValidationFailedUpgradeHeader = 0x39
        case errorOEMValidationFailedPartitionHeader = 0x3A
        case errorOEMValidationFailedPartitionHeader2 = 0x3B
        case errorOEMValidationFailedPartitionData = 0x3C
        case errorOEMValidationFailedFooter   = 0x3D
        case errorOEMValidationFailedMemory   = 0x3E
        case errorPartitionCloseFailed2       = 0x40
        case errorPartitionCloseFailedHeader  = 0x41
        case errorPartitionCloseFailedPSSpace = 0x42
        case errorPartitionTypeNotMatching    = 0x48
        case errorPartitionTypeTwoDFU         = 0x49
        case errorPartitionWriteFailedHeader  = 0x50
        case errorPartitionWriteFailedData    = 0x51
        case errorFileTooSmall                = 0x58
        case errorFileTooBig                  = 0x59
        case errorInternalError1              = 0x65
        case errorInternalError2              = 0x66
        case errorInternalError3              = 0x67
        case errorInternalError4              = 0x68
        case errorInternalError5              = 0x69
        case errorInternalError6              = 0x6A
        case errorInternalError7              = 0x6B
        case warnAppConfigVersionIncompatible = 0x80
        case warnSyncIdIsDifferent            = 0x81

        func userDescription() -> String {
            switch self {
            case .success:
                return NSLocalizedString("Everything is fine", comment: "Update Error Response")
            case .errorUnknownId:
                return NSLocalizedString("Unknown command", comment: "Update Error Response")
            case .errorBadLength:
                return NSLocalizedString("Bad length", comment: "Update Error Response")
            case .errorWrongVariant:
                return NSLocalizedString("Wrong variant", comment: "Update Error Response")
            case .errorWrongPartitionNumber:
                return NSLocalizedString("Wrong partition number", comment: "Update Error Response")
            case .errorPartitionSizeMismatch:
                return NSLocalizedString("Partition size mismatch", comment: "Update Error Response")
            case .errorPartitionTypeNotFound:
                return NSLocalizedString("Partition type not found", comment: "Update Error Response")
            case .errorPartitionOpenFailed:
                return NSLocalizedString("Partition open failed", comment: "Update Error Response")
            case .errorPartitionWriteFailed:
                return NSLocalizedString("Partition write failed", comment: "Update Error Response")
            case .errorPartitionCloseFailed:
                return NSLocalizedString("Partition close failed", comment: "Update Error Response")
            case .errorSFSValidationFailed:
                return NSLocalizedString("SFS validation failed:", comment: "Update Error Response")
            case .errorOEMValidationFailed:
                return NSLocalizedString("OEM validation failed", comment: "Update Error Response")
            case .errorUpdateFailed:
                return NSLocalizedString("Update failed", comment: "Update Error Response")
            case .errorAppNotReady:
                return NSLocalizedString("App not ready", comment: "Update Error Response")
            case .errorLoaderError:
                return NSLocalizedString("Loader error", comment: "Update Error Response")
            case .errorUnexpectedLoaderMessage:
                return NSLocalizedString("Unexpected loader", comment: "Update Error Response")
            case .errorMissingLoaderMessage:
                return NSLocalizedString("Missing loader", comment: "Update Error Response")
            case .errorBatteryLow:
                return NSLocalizedString("Battery low", comment: "Update Error Response")
            case .errorInvalidSyncId:
                return NSLocalizedString("Invalid sync ID", comment: "Update Error Response")
            case .errorInErrorState:
                return NSLocalizedString("In error state", comment: "Update Error Response")
            case .errorNoMemory:
                return NSLocalizedString("No memory", comment: "Update Error Response")
            case .errorHandoverDFUAbort:
				return NSLocalizedString("Handover DFU Abort", comment: "Update Error Response")
            case .errorBadLengthPartitionParse:
                return NSLocalizedString("Bad length - partition parse", comment: "Update Error Response")
            case .errorBadLengthTooShort:
                return NSLocalizedString("Bad length - too short", comment: "Update Error Response")
            case .errorBadLengthUpgradeHeader:
                return NSLocalizedString("Bad length - Upgrade header", comment: "Update Error Response")
            case .errorBadLengthPartitionHeader:
                return NSLocalizedString("Bad length - Partition header", comment: "Update Error Response")
            case .errorBadLengthSignature:
                return NSLocalizedString("Bad length - Signature", comment: "Update Error Response")
            case .errorBadLengthDataHeaderResume:
                return NSLocalizedString("Bad length - Data header resume", comment: "Update Error Response")
            case .errorOEMValidationFailedHeader:
                return NSLocalizedString("OEM validation failed - Header", comment: "Update Error Response")
            case .errorOEMValidationFailedUpgradeHeader:
                return NSLocalizedString("OEM validation failed - Upgrade header", comment: "Update Error Response")
            case .errorOEMValidationFailedPartitionHeader:
                return NSLocalizedString("OEM validation failed - Partition header", comment: "Update Error Response")
            case .errorOEMValidationFailedPartitionHeader2:
                return NSLocalizedString("OEM validation failed - Partition header 2", comment: "Update Error Response")
            case .errorOEMValidationFailedPartitionData:
                return NSLocalizedString("OEM validation failed - Partition data", comment: "Update Error Response")
            case .errorOEMValidationFailedFooter:
                return NSLocalizedString("OEM validation failed - Footer", comment: "Update Error Response")
            case .errorOEMValidationFailedMemory:
                return NSLocalizedString("OEM validation failed - Memory", comment: "Update Error Response")
            case .errorPartitionCloseFailed2:
                return NSLocalizedString("Partition close failed 2", comment: "Update Error Response")
            case .errorPartitionCloseFailedHeader:
                return NSLocalizedString("Partition close failed - Header", comment: "Update Error Response")
            case .errorPartitionCloseFailedPSSpace:
                return NSLocalizedString("Partition close failed - PS space", comment: "Update Error Response")
            case .errorPartitionTypeNotMatching:
                return NSLocalizedString("Partition type - Not matching", comment: "Update Error Response")
            case .errorPartitionTypeTwoDFU:
                return NSLocalizedString("Partition type - Two DFU", comment: "Update Error Response")
            case .errorPartitionWriteFailedHeader:
                return NSLocalizedString("Partition write - Failed header", comment: "Update Error Response")
            case .errorPartitionWriteFailedData:
                return NSLocalizedString("Partition write - Failed data", comment: "Update Error Response")
            case .errorFileTooSmall:
                return NSLocalizedString("File too small", comment: "Update Error Response")
            case .errorFileTooBig:
                return NSLocalizedString("File too big", comment: "Update Error Response")
            case .errorInternalError1:
                return NSLocalizedString("Internal error 1", comment: "Update Error Response")
            case .errorInternalError2:
                return NSLocalizedString("Internal error 2", comment: "Update Error Response")
            case .errorInternalError3:
                return NSLocalizedString("Internal error 3", comment: "Update Error Response")
            case .errorInternalError4:
                return NSLocalizedString("Internal error 4", comment: "Update Error Response")
            case .errorInternalError5:
                return NSLocalizedString("Internal error 5", comment: "Update Error Response")
            case .errorInternalError6:
                return NSLocalizedString("Internal error 6", comment: "Update Error Response")
            case .errorInternalError7:
                return NSLocalizedString("Internal error 7", comment: "Update Error Response")
            case .warnAppConfigVersionIncompatible:
                return NSLocalizedString("App config version incompatible", comment: "Update Error Response")
            case .warnSyncIdIsDifferent:
                return NSLocalizedString("Sync ID is different", comment: "Update Error Response")
            }
        }
    }
}
