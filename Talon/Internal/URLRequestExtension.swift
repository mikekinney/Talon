//
//  URLRequestExtension.swift
//  Talon
//
//  Created by Mike on 4/2/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

extension URLRequest {
    
    enum URLRequestError: Error {
        case invalidURL
    }
    
    static func requestFor(command: Command, secure: Bool, host: String, port: Int) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = secure ? "https" : "http"
        components.host = host
        components.port = port
        components.path = "/"+command.httpCommand
        guard let url = components.url else {
            Log.debug(message: "Unable to construct URL for: " + components.debugDescription)
            throw(URLRequestError.invalidURL)
        }
        let request = URLRequest(url: url)
        return request

    }
    
}
