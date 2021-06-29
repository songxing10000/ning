//
//  NetworkDataCachingPlugin.swift
//  ning
//
//  Created by dfpo on 29/06/2021.
//  Copyright © 2021 tuicool. All rights reserved.
//

import Foundation
import Moya

protocol CachePolicyGettable {
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class NetworkDataCachingPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cacheableTarget = target as? CachePolicyGettable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cacheableTarget.cachePolicy
            return mutableRequest
        }
        return request
    }
}
