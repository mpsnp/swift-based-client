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
    
    /**
     
     */
    public func auth(token: String?, options: SendTokenOptions? = nil) async -> Any? {
        if let token = token {
            await sendToken(token, options)
        } else {
            await sendToken()
        }
        emitter.emit(type: "auth", token)
        return await withCheckedContinuation { continuation in
            auth.append(AuthFunction(resolve: { continuation.resume(returning: $0) }))
        }
    }
    
    /**
     
     */
    public func auth(token: String?, options: SendTokenOptions? = nil) {
        if let token = token {
            Task { await sendToken(token, options) }
        } else {
            Task { await sendToken() }
        }
        emitter.emit(type: "auth", token)
    }
}

