//
//  BasedConfig.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation


final class BasedConfig {
    var opts: Based.Opts
    private let urlSession: URLSession
    private var urlString: String?
    private var servers: [String]?
    
    init(
        opts: Based.Opts,
        urlSession: URLSession
    ) {
        self.opts = opts
        self.urlSession = urlSession
    }
    
    var url: URL {
        get async throws {
            if let urlString = opts.urlString {
                self.urlString = urlString
            } else {
                urlString = try await getUrl()
            }
            
            guard
                let urlString = urlString,
                    var components = URLComponents(string: urlString)
            else {
                throw BasedError.configuration("Could not establish an url")
            }
            
            if let params = opts.params {
                let queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                components.queryItems = queryItems
            }
            
            guard
                let url = components.url
                else {
                    throw BasedError.configuration("Could not establish an url")
                }

            return url
        }
    }
    
    private func getUrl() async throws -> String {
        if opts.cluster.starts(with: "http") == false {
            self.opts.cluster = "https://\(opts.cluster)"
        }

        let (listData, _) = try await urlSession.data(from: URL(string: opts.cluster)!)
        let list = try JSONDecoder().decode([String].self, from: listData)
        
        guard
            let selectUrl = list.randomElement(),
            let org = opts.org,
            let project = opts.project,
            let env = opts.env
            else {
                throw BasedError.configuration("No url to connect")
            }
        
        let url = "\(selectUrl)/\(org).\(project).\(env).\(opts.name)"
        
        do {
            let (urlData, _) = try await urlSession.data(from: URL(string: url)!)
            let realUrl = String(decoding: urlData, as: UTF8.self)
            if realUrl.isEmpty {
                try await Task.sleep(seconds: 0.3)
                return try await getUrl()
            }
            return String(decoding: urlData, as: UTF8.self)
        } catch {
            try await Task.sleep(seconds: 0.3)
            return try await getUrl()
        }
    }
    
}
