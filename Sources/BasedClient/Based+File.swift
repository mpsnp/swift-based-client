//
//  Based+File.swift
//  
//
//  Created by Alexander van der Werff on 20/01/2022.
//

#if os(iOS)

import Foundation
import Combine

struct FileUploadOptions {
    let fileUrl: URL
    let targetUrl: URL?
    let name: String?
    let id: String?
    let mimeType: String?
}

final class FileUploader: NSObject {
    typealias Percentage = Double
    typealias Publisher = AnyPublisher<Percentage, Error>
    
    private typealias Subject = CurrentValueSubject<Percentage, Error>
    
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .main
    )
    
    private var subjectsByTaskID = [Int: Subject]()
    
    func uploadFile(at fileURL: URL,
                    to targetURL: URL,
                    id: String? = nil) -> Publisher {
        var request = URLRequest(
            url: targetURL,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        
        request.httpMethod = "POST"
        
        let subject = Subject(0)
        var removeSubject: (() -> Void)?
        
        let task = urlSession.uploadTask(
            with: request,
            fromFile: fileURL,
            completionHandler: { data, response, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                subject.send(completion: .finished)
                removeSubject?()
            }
        )
        
        subjectsByTaskID[task.taskIdentifier] = subject
        removeSubject = { [weak self] in
            self?.subjectsByTaskID.removeValue(forKey: task.taskIdentifier)
        }
        
        task.resume()
        
        return subject.eraseToAnyPublisher()
    }
}

extension FileUploader: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let subject = subjectsByTaskID[task.taskIdentifier]
        subject?.send(progress)
    }
}

extension Based {
    
    public func file(
        fileUrl: URL,
        targetUrl: URL? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        id: String? = nil
    ) -> AnyPublisher<Double, Error> {
        let options = FileUploadOptions(fileUrl: fileUrl, targetUrl: targetUrl, name: name, id: id, mimeType: mimeType)
        return Just(options)
            .setFailureType(to: Error.self)
            .asyncMap { [weak self] options -> (URL, URL, String?) in
                guard let targetUrl = try await self?.getUrl(options: options) else {
                    throw BasedError.other("Could not construct target url for file upload")
                }
            
                var id = options.id
                if id == nil {
                    id = try await self?.set(query: .query(.field("type", "file")))
                }
                return (targetUrl, options.fileUrl, id)
            }
            .flatMap { args -> AnyPublisher<Double, Error> in
                let (targetUrl, fileUrl, id) = args
                let fileUploader = FileUploader()
                return fileUploader.uploadFile(at: fileUrl, to: targetUrl, id: id)
            }.eraseToAnyPublisher()
    }
    
    private func getUrl(options: FileUploadOptions) async throws -> URL {
        if let targetUrl = options.targetUrl {
            return targetUrl
        } else {
            let targetUrl = try await config.url
            let urlString = targetUrl.absoluteString.replacingOccurrences(of: "ws", with: "http")
            if config.env == nil, let url = URL(string: "\(urlString)") {
                return url
            } else if let url = URL(string: "\(urlString).file-upload$") {
                return url
            }
        }
        throw BasedError.other("Could not construct target url for file upload")
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

#endif
