//
//  Based+Request.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation
import AnyCodable


struct RequestCallback {
    let resolve: (Data) -> Void
    let reject: (Error) -> Void
}

extension Based {
    
    func addRequest(
        type: RequestType,
        payload: JSON?,
        continuation: CheckedContinuation<Data, Error>,
        name: String
    ) {
        requestIdCnt += 1
        let id = requestIdCnt
        
        let cb = RequestCallback(
            resolve: continuation.resume(returning:),
            reject: continuation.resume(throwing:)
        )
        requestCallbacks[id] = cb

        if (type == .call) {
            addToMessages(FunctionCallMessage(id: id, name: name, payload: payload))
        } else {
            addToMessages(RequestMessage(requestType: type, id: id, payload: payload))
        }
    }
    
    
    func incomingRequest(_ data: [AnyCodable]) {
        dataInfo("\(data)")
        
        guard
            let id = data[1].value as? Int,
            let cb = requestCallbacks[id],
            let jsonData = try? encoder.encode(data[2])
        else { dataInfo("No id for data message"); return }
        
        requestCallbacks.removeValue(forKey: id)
        
        guard data.count <= 3 else {
            if
                let errorObject = ErrorObject(from: data[3]) {
                
                cb.reject(BasedError.from(errorObject))

            } else {
                cb.reject(BasedError.other(message: "Something unexpected happened"))
            }
            return
        }
        
        cb.resolve(jsonData)

    }

}
