import Cocoa
import FlutterMacOS

public class DarwinFileAttributesPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "darwin_file_attributes",
            binaryMessenger: registrar.messenger
        )
        let instance = DarwinFileAttributesPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getResourceValues":
            handleGetResourceValues(call: call, result: result)
        case "setResourceValues":
            handleSetResourceValues(call: call, result: result)
        case "getXattr":
            handleGetXattr(call: call, result: result)
        case "setXattr":
            handleSetXattr(call: call, result: result)
        case "removeXattr":
            handleRemoveXattr(call: call, result: result)
        case "listXattr":
            handleListXattr(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Resource Values

    private func handleGetResourceValues(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let keys = args["keys"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path' (String) and 'keys' ([String]).",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        let url = URL(fileURLWithPath: path)
        var resourceKeys = Set<URLResourceKey>()
        for key in keys {
            if let rk = Self.resourceKeyFromString(key) {
                resourceKeys.insert(rk)
            }
        }

        do {
            let values = try url.resourceValues(forKeys: resourceKeys)
            var map: [String: Any] = [:]

            for key in keys {
                switch key {
                case "isExcludedFromBackup":
                    if let v = values.isExcludedFromBackup { map[key] = v }
                case "isHidden":
                    if let v = values.isHidden { map[key] = v }
                case "isUserImmutable":
                    if let v = values.isUserImmutable { map[key] = v }
                case "creationDate":
                    if let d = values.creationDate {
                        map[key] = Int64(d.timeIntervalSince1970 * 1000)
                    }
                case "contentModificationDate":
                    if let d = values.contentModificationDate {
                        map[key] = Int64(d.timeIntervalSince1970 * 1000)
                    }
                case "fileProtection":
                    if let v = values.fileProtection {
                        map[key] = Self.fileProtectionToString(v)
                    }
                case "isUbiquitousItem":
                    if let v = values.isUbiquitousItem { map[key] = v }
                case "ubiquitousItemDownloadingStatus":
                    if let v = values.ubiquitousItemDownloadingStatus {
                        map[key] = Self.downloadStatusToString(v)
                    }
                case "ubiquitousItemIsUploaded":
                    if let v = values.ubiquitousItemIsUploaded { map[key] = v }
                case "ubiquitousItemIsUploading":
                    if let v = values.ubiquitousItemIsUploading { map[key] = v }
                default:
                    break
                }
            }

            result(map)
        } catch {
            result(FlutterError(code: "RESOURCE_ERROR",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    private func handleSetResourceValues(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let values = args["values"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path' (String) and 'values' (Map).",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        var url = URL(fileURLWithPath: path)
        var rv = URLResourceValues()

        for (key, value) in values {
            switch key {
            case "isExcludedFromBackup":
                rv.isExcludedFromBackup = value as? Bool
            case "isHidden":
                rv.isHidden = value as? Bool
            case "isUserImmutable":
                rv.isUserImmutable = value as? Bool
            case "creationDate":
                if let ms = value as? Int {
                    rv.creationDate = Date(timeIntervalSince1970: Double(ms) / 1000.0)
                }
            case "contentModificationDate":
                if let ms = value as? Int {
                    rv.contentModificationDate = Date(timeIntervalSince1970: Double(ms) / 1000.0)
                }
            case "fileProtection":
                break // fileProtection is iOS-only; ignored on macOS
            default:
                break // ignore unknown or read-only keys
            }
        }

        do {
            try url.setResourceValues(rv)
            result(nil)
        } catch {
            result(FlutterError(code: "RESOURCE_ERROR",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    // MARK: - Extended Attributes (xattr)

    private func handleGetXattr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let name = args["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path' and 'name'.",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        let length = getxattr(path, name, nil, 0, 0, 0)
        guard length >= 0 else {
            if errno == ENOATTR {
                result(nil) // attribute does not exist
            } else {
                result(FlutterError(code: "XATTR_ERROR",
                                    message: String(cString: strerror(errno)),
                                    details: nil))
            }
            return
        }

        var data = Data(count: length)
        let read = data.withUnsafeMutableBytes { ptr -> Int in
            getxattr(path, name, ptr.baseAddress, length, 0, 0)
        }
        guard read >= 0 else {
            result(FlutterError(code: "XATTR_ERROR",
                                message: String(cString: strerror(errno)),
                                details: nil))
            return
        }

        result(FlutterStandardTypedData(bytes: data))
    }

    private func handleSetXattr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let name = args["name"] as? String,
              let typedData = args["value"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path', 'name', and 'value'.",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        let data = typedData.data
        let ret = data.withUnsafeBytes { ptr -> Int32 in
            setxattr(path, name, ptr.baseAddress, data.count, 0, 0)
        }
        if ret == 0 {
            result(nil)
        } else {
            result(FlutterError(code: "XATTR_ERROR",
                                message: String(cString: strerror(errno)),
                                details: nil))
        }
    }

    private func handleRemoveXattr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String,
              let name = args["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path' and 'name'.",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        let ret = removexattr(path, name, 0)
        if ret == 0 || errno == ENOATTR {
            result(nil) // success or attribute already absent
        } else {
            result(FlutterError(code: "XATTR_ERROR",
                                message: String(cString: strerror(errno)),
                                details: nil))
        }
    }

    private func handleListXattr(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "Expected 'path'.",
                                details: nil))
            return
        }

        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND",
                                message: "No file or directory at path: \(path)",
                                details: nil))
            return
        }

        let length = listxattr(path, nil, 0, 0)
        guard length >= 0 else {
            result(FlutterError(code: "XATTR_ERROR",
                                message: String(cString: strerror(errno)),
                                details: nil))
            return
        }

        if length == 0 {
            result([String]())
            return
        }

        var buffer = [CChar](repeating: 0, count: length)
        let read = listxattr(path, &buffer, length, 0)
        guard read >= 0 else {
            result(FlutterError(code: "XATTR_ERROR",
                                message: String(cString: strerror(errno)),
                                details: nil))
            return
        }

        var names = [String]()
        buffer.withUnsafeBufferPointer { ptr in
            var pos = ptr.baseAddress!
            let end = pos.advanced(by: read)
            while pos < end {
                let name = String(cString: pos)
                if !name.isEmpty { names.append(name) }
                pos = pos.advanced(by: name.utf8.count + 1)
            }
        }
        result(names)
    }

    // MARK: - Helpers

    private static func resourceKeyFromString(_ key: String) -> URLResourceKey? {
        switch key {
        case "isExcludedFromBackup":              return .isExcludedFromBackupKey
        case "isHidden":                          return .isHiddenKey
        case "isUserImmutable":                   return .isUserImmutableKey
        case "creationDate":                      return .creationDateKey
        case "contentModificationDate":           return .contentModificationDateKey
        case "fileProtection":                    return .fileProtectionKey
        case "isUbiquitousItem":                  return .isUbiquitousItemKey
        case "ubiquitousItemDownloadingStatus":   return .ubiquitousItemDownloadingStatusKey
        case "ubiquitousItemIsUploaded":          return .ubiquitousItemIsUploadedKey
        case "ubiquitousItemIsUploading":         return .ubiquitousItemIsUploadingKey
        default:                                  return nil
        }
    }

    private static func fileProtectionToString(_ p: URLFileProtection) -> String {
        switch p {
        case .none:                                return "none"
        case .complete:                            return "complete"
        case .completeUnlessOpen:                  return "completeUnlessOpen"
        case .completeUntilFirstUserAuthentication: return "completeUntilFirstUserAuthentication"
        default:                                   return p.rawValue
        }
    }

    private static func fileProtectionFromString(_ s: String) -> URLFileProtection? {
        switch s {
        case "none":                                return .none
        case "complete":                            return .complete
        case "completeUnlessOpen":                  return .completeUnlessOpen
        case "completeUntilFirstUserAuthentication": return .completeUntilFirstUserAuthentication
        default:                                    return nil
        }
    }

    private static func downloadStatusToString(_ s: URLUbiquitousItemDownloadingStatus) -> String {
        switch s {
        case .notDownloaded: return "notDownloaded"
        case .downloaded:    return "downloaded"
        case .current:       return "current"
        default:             return s.rawValue
        }
    }
}
