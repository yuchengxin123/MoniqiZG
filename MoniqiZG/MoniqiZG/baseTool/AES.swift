//
//  AES.swift
//  MoniqiZG
//
//  Created by ycx on 2025/7/18.
//

import Foundation
import CommonCrypto


class AES256 {
    static let keyString = "demoAT7HnRAugZ5EXnOOBRZpP2SH3DiF"
    static let ivString = "1234567890123456"

    /// 加密
    static func encrypt(_ data: Data) -> Data? {
        guard let keyData = keyString.data(using: .utf8),
              let ivData = ivString.data(using: .utf8) else {
            print("❌ key 或 iv 转换失败")
            return nil
        }
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        var numBytesProcessed = 0

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES256,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            cryptBytes.baseAddress, cryptLength,
                            &numBytesProcessed
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            print("❌ AES operation failed, status: \(status)")
            return nil
        }
        cryptData.removeSubrange(numBytesProcessed..<cryptData.count)
        
        // 拼接 IV + 加密后的密文
        let finalData = ivData + cryptData
        return finalData
    }

    /// 解密
    static func decrypt(_ data: Data) -> Data? {
        
        // 拆出 IV 和密文
        let ivData = data.prefix(16)
        let encryptedData = data.dropFirst(16)

        guard let keyData = AES256.keyString.data(using: .utf8) else {
            print("❌ key 转换失败")
            return nil
        }
        
        let cryptLength = encryptedData.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        var numBytesDecrypted = 0

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            encryptedData.withUnsafeBytes { encBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, kCCKeySizeAES256,
                            ivBytes.baseAddress,
                            encBytes.baseAddress, encryptedData.count,
                            cryptBytes.baseAddress, cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else {
//            print("❌ 解密失败，状态: \(status)")
            return Data()
        }

        cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
//        print("✅ 解密成功，长度: \(cryptData.count)")
//        print("🔓 明文: \(String(data: cryptData, encoding: .utf8) ?? "<乱码>")")

        return cryptData
    }
}
