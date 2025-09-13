
import Foundation
import Alamofire

/// 通用 Any 类型解码器
struct AnyDecodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyDecodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
}

// 通用响应结构
struct BasicResponse: Decodable {
    let code: Int
    let msg: String
    let data: Any?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try container.decode(Int.self, forKey: .code)
        msg = try container.decode(String.self, forKey: .msg)
        
        // 尝试解析为不同类型
        if let intValue = try? container.decode(Int.self, forKey: .data) {
            data = intValue
        } else if let stringValue = try? container.decode(String.self, forKey: .data) {
            data = stringValue
        } else if let doubleValue = try? container.decode(Double.self, forKey: .data) {
            data = doubleValue
        } else if let boolValue = try? container.decode(Bool.self, forKey: .data) {
            data = boolValue
        } else if let dictValue = try? container.decode([String: AnyDecodable].self, forKey: .data) {
            data = dictValue.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyDecodable].self, forKey: .data) {
            data = arrayValue.map { $0.value }
        } else {
            data = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case code, msg, data
    }
}


class YcxHttpManager {
    
    static let httpManager = YcxHttpManager()
    
//    var header: HTTPHeaders = [
//        "client": "ios",
//        "version": currentVersion()
//    ]
    
    static func requestPost(url: String, page: Int? = nil, params: Dictionary<String, Any>? = nil, successCall: @escaping (_ msg: String ,_ data: [String : Any] , _ code:Int) -> Void,  failCall: @escaping (_ err: String, _ data: Any) -> Void) {
        request(method: HTTPMethod.post, url: url, page: page, params: params, successCall: successCall, failCall: failCall)
    }
    
    static func requestGet(url: String, page: Int? = nil, params: Dictionary<String, Any>? = nil, successCall: @escaping (_ msg: String ,_ data: [String : Any] , _ code:Int) -> Void,  failCall: @escaping (_ err: String, _ data: Any) -> Void) {
        request(method: HTTPMethod.get, url: url, page: page, params: params, successCall: successCall, failCall: failCall)
    }
    
    static func request(method: HTTPMethod, url: String, page: Int? = nil, params: Dictionary<String, Any>? = nil, successCall: @escaping (_ msg: String ,_ data: [String : Any] , _ code:Int) -> Void,  failCall: @escaping (_ err: String, _ data: Any) -> Void) {
        
        let urlString = String(format: "%@%@", httpUrl,url)
        
        //        let timestamp = Int(Date().timeIntervalSince1970)
        //
        //        let para:NSMutableDictionary = NSMutableDictionary(dictionary: params ?? [:])
        //        para.setValue(timestamp, forKey: "timestamp")
        
        AF.request(urlString, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
            .responseDecodable(of: BasicResponse.self) { response in
                switch response.result {
                case .success(let basicResponse):
                    DispatchQueue.main.async {
                        if basicResponse.code == 1 {
                            // 处理 data 字段
                            if let dataDict = basicResponse.data as? [String : Any]{
                                successCall(basicResponse.msg, dataDict, basicResponse.code)
                            } else {
                                // 如果 data 不是字典类型，可以传递空字典或其他处理
                                successCall(basicResponse.msg, [:], basicResponse.code)
                            }
                        } else {
                            failCall(basicResponse.msg, basicResponse.code)
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        failCall("请求失败: \(error.localizedDescription)", 0)
                        if let statusCode = response.response?.statusCode {
                            print("状态码: \(statusCode)")
                        }
                    }
                }
            }
    }

    //获取时间戳
    static func getTimestamp(successCall: @escaping (_ msg: String ,_ data: Int , _ code:Int) -> Void){

        let urlString = String(format: "%@%@", httpUrl,API_getTime)
       
        AF.request(urlString, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseDecodable(of: BasicResponse.self) { response in
                
                switch response.result {
                case .success(let basicResponse):
                    DispatchQueue.main.async {
                        if basicResponse.code == 1 {
                            // 处理 data 字段
                            if let time = basicResponse.data as? Int {
                                successCall(basicResponse.msg, time, basicResponse.code)
                            } else {
                                // 如果 data 不是字典类型，可以传递空字典或其他处理
                                print("获取时间戳失败: \(basicResponse.msg))")
                            }
                        } else {
                            print("获取时间戳失败: \(basicResponse.msg))")
                        }
                    }
                    
                case .failure(let error):
                    print("状态码: \(error.localizedDescription)")
                }
                
            }
    }
    
    
  
    //请求body加密
//    private func encryptBody(_ para:[String: Any]) -> Data {
//        print("para------\(para)")
//        // 1. 按 key 顺序生成 JSON 字符串
//        // JSON字符串转为 UTF-8 数据
//        guard let data = try? JSONSerialization.data(withJSONObject: para, options: [.sortedKeys])
//        else {
//            return Data()
//        }
//        // 2. 加密
//        guard let encryptedData = AES256.encrypt(data) else {
//            return Data()
//        }
//        //原始数据(二进制数据)编码为 Base64 字符串
//        let base64String = encryptedData.base64EncodedString()
//        print("Base64(IV+密文): \(base64String)")
//
//        return base64String.data(using: .utf8) ?? Data()
//    }
//    
//    //获取data解密
//    private func decryptBody(_ base64Str:String) -> Data {
//        //Base64 解码为原始数据(二进制数据)
//        guard let data = Data(base64Encoded: base64Str)
//        else {
//            return Data()
//        }
//        if let result = AES256.decrypt(data) {
//            return result
//        } else {
//            print("❌ 解密失败")
//            return Data()
//        }
//    }
    
//    private func handleUrl(_ requestUrl: String , _ page: Int? = nil) -> String {
//        var result: String
//        let lang = LanguageManager.HttpLanguage()
//        result = "\(httpUrl)\(requestUrl)?lang=\(lang)"
//        if page != nil {
//            result += "&page=\(page!)"
//        }
//        return result
//    }
    
//    private func handleResData(_ code: Int) -> Bool {
//        switch code {
//        case 0:
//            //失败
//            return false
//        case 1:
//            //成功
//            return true
//        case 202:
//            //图形验证码限制
//            return true
//        case 203:
//            //图形验证码输入错误
//            return false
//        case 301:
//            print("重定向")
//            
//            return true
//        case 401:
//            print("重新登录")
//            User.deleteUser()
//            myUser = nil
//            YcxHttpManager.login()
//            return false
//        case 403:
//            print("非法请求")
//            return false
//        default:
//            print("服务器繁忙")
//            return false
//        }
//    }
}


//extension YcxHttpManager {
//    
//    /// 批量上传图片（逐张上传，统一回调）
//    /// - Parameters:
//    ///   - images: UIImage数组
//    ///   - params: 每张图上传附带参数（可选）
//    ///   - successCall: 成功回调，返回所有上传成功后的图片地址数组
//    ///   - failCall: 某张上传失败的回调
//    static func uploadImages(
//        images: [UIImage],
//        params: [String],
//        successCall: @escaping (_ msg: String ,_ data: String , _ code:Int) -> Void,
//        failCall: @escaping (_ err: String, _ data: Any) -> Void
//    ) {
//        guard images.count > 0 else {
//            failCall(LocalizedString("Common_no_content"), "")
//            return
//        }
//        
//        let uploadedURLs: NSMutableString = NSMutableString()
//        var index = 0
//        
//        func uploadNext() {
//            if index >= images.count {
//                uploadedURLs.deleteCharacters(in: NSRange(location: uploadedURLs.length - 1, length: 1))
//                successCall("上传成功", uploadedURLs as String, 1)
//                return
//            }
//            
//            let image = images[index]
//            let imageData = image.jpegData(compressionQuality: 0.8)!
//            
//            let fileName = params[index]
//            
//            let urlString = httpManager.handleUrl("/user/fileUpload")
//            
//            AF.upload(multipartFormData: { multipart in
//                
//                multipart.append(imageData, withName: "img_file", fileName: fileName, mimeType: "image/jpg")
//                
//            },to: urlString,headers: nil
//            ).responseDecodable(of: BasicResponse.self)  { resJSON in
//                switch resJSON.result {
//                case .success(let basic):
//                    if basic.code == 1 {
//                        uploadedURLs.appendFormat("\(basic.msg)," as NSString)
//                        index += 1
//                    
//                        uploadNext() // 上传下一张
//                    } else {
//                        failCall(basic.msg, basic.data ?? "")
//                    }
//                    
//                case .failure(let error):
//                    failCall("网络错误:\(error.localizedDescription)", "")
//                }
//            }
//        }
//        
//        uploadNext()
//    }
//}
