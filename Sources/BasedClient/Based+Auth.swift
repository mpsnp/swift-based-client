//
//  Based+Auth.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation

struct AuthFunction {
    let resolve: (Any?) -> Void
}

extension Based {
    
    public func auth(token: String?, options: SendTokenOptions? = nil) async -> Any? {
        await withCheckedContinuation { [weak self] continuation in
            auth.append(AuthFunction(resolve: { continuation.resume(returning: $0) }))
            if let token = token {
                self?.sendToken(token, options)
            } else {
                self?.sendToken()
            }
            self?.emitter.emit(type: "auth", token)
        }
    }
    
    /**
     
     */
    public func auth(token: String?, options: SendTokenOptions? = nil) {
        
    }
}
