//
//  BasedConfig.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation
import AnyCodable


public class BasedConfig {
    let env: String?
    let project: String?
    let org: String?
    var cluster: String
    let name: String?
    private var urlString: String?
    let params: [String: AnyCodable]?
    
    public init(
        env: String? = nil,
        project: String? = nil,
        org: String? = nil,
        cluster: String = "https://d3gdtpkyvlxeve.cloudfront.net",
        name: String? = "@based/hub",
        url: String? = nil,
        params: [String: AnyCodable]? = nil
    ) {
            self.env = env
            self.project = project
            self.org = org
            self.cluster = cluster
            self.name = name
            self.urlString = url
            self.params = params
        }
    
    var url: URL {
        get async throws {
            if urlString == nil {
                urlString = try await getUrl()
            }
            
            guard let urlString = urlString, var components = URLComponents(string: urlString) else { throw BasedError.configuration("Could not establish an url") }
            if let params = params {
                let queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                components.queryItems = queryItems
            }
            
            guard let url = components.url else { throw BasedError.configuration("Could not establish an url") }

            return url
        }
    }
    
    private func getUrl() async throws -> String {
        if cluster.starts(with: "http") == false {
            self.cluster = "https://\(cluster)"
        }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 4
        let session = URLSession(configuration: config)

        
        let (listData, _) = try await session.data(from: URL(string: cluster)!)
        let list = try JSONDecoder().decode([String].self, from: listData)
        
        guard
            let selectUrl = list.randomElement(),
            let org = org,
            let project = project,
            let env = env,
            let name = name
            else { throw BasedError.configuration("No url to connect") }
        
        let url = "\(selectUrl)/\(org).\(project).\(env).\(name)"
        
        do {
            let (urlData, _) = try await session.data(from: URL(string: url)!)
            let realUrl = String(decoding: urlData, as: UTF8.self)
            if realUrl.isEmpty {
                try await Task.sleep(seconds: 0.5)
                return try await getUrl()
            }
            return String(decoding: urlData, as: UTF8.self)
        } catch {
            try await Task.sleep(seconds: 0.5)
            return try await getUrl()
        }
    }
    
}
