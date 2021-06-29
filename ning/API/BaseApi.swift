//
//  BaseAPI.swift
//  ning
//
//  Created by JianjiaYu on 2020/9/4.
//  Copyright © 2020 tuicool. All rights reserved.
//

import Moya
import HandyJSON
import MBProgressHUD
import Alamofire
import enum Result.Result

let LoadingPlugin = NetworkActivityPlugin { (type, target) in
    guard let vc = topVC else { return }
    switch type {
    case .began:
        MBProgressHUD.hide(for: vc.view, animated: false)
        MBProgressHUD.showAdded(to: vc.view, animated: true)
    case .ended:
        MBProgressHUD.hide(for: vc.view, animated: true)
    }
}

extension TargetType {

    var baseURL: URL { return URL(string: API_HOST)! }
    
    var headers: [String : String]? {
        return ["User-Agent":"iOS/1/2"]
    }
    
    var sampleData: Data { return "".data(using: String.Encoding.utf8)! }
}

func buildURLCredential() -> URLCredential {
    let user = DAOFactory.getLoginUser()
    if (user == nil || !user!.isLogin()) {
        return URLCredential(user: "0.0.0.0", password: "tuicool", persistence: .none)
    }
    return URLCredential(user: String(user!.id), password: user!.token ?? "", persistence: .none)
}

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 10 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireManager(configuration: configuration)
    }()
}

let BasicCredentialsPlugin = CredentialsPlugin { _ -> URLCredential? in
    return buildURLCredential()
}

extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) throws -> T {
        let jsonString = String(data: data, encoding: .utf8)
//        logInfo(jsonString)
        guard let model = JSONDeserializer<T>.deserializeFrom(json: jsonString) else {
            throw MoyaError.jsonMapping(self)
        }
        return model
    }
}

extension MoyaProvider {
    @discardableResult
    open func request<T: HandyJSON>(_ target: Target,
                                    model: T.Type,
                                    completion: ((_ returnData: T?) -> Void)?) -> Cancellable? {
        
        return request(target, completion: { (result) in
            guard let completion = completion else { return }
            logInfo(result.value)
            guard let returnData = try? result.value?.mapModel(T.self) else {
                completion(self.buildErrorResult(result))
                return
            }
            completion(returnData)
        })
    }
    
    private func buildErrorResult<T: HandyJSON>(_ result: Result<Response, MoyaError>?) -> T {

        if let data = result?.value?.data,
           let jsonString = String(data: data, encoding: .utf8),
           jsonString.contains("Access denied") {
            
            let resultModel = T()
            if let baseObj = resultModel as? BaseObject {
            
                baseObj.success = false
                baseObj.error = "授权失败，请重新登录"
                return resultModel
            }
        }
        
        
        let resultModel = T()
        if let baseObj = resultModel as? BaseObject {
        
            baseObj.success = false
            baseObj.error = result?.error?.localizedDescription
            return resultModel
        }
        return resultModel
    }
}


