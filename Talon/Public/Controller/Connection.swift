//
//  Connection.swift
//  Talon
//
//  Created by Mike on 1/29/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

/// The Connection class sends Commands to a Tile38 server.
public class Connection {
    
    public enum Failure: Error {
        case badResponse
        case unexpectedError
    }
    
    // MARK: - Properties
    
    fileprivate let host: String
    fileprivate let port: Int
    fileprivate let secure: Bool
    fileprivate let urlSession: URLSession
    
    // MARK: - Lifecycle
    
    /// Create a new Connection instance using the provided host and port.
    ///
    /// - Parameters:
    ///   - host: The server hostname or IP address.
    ///   - port: The port to connect to.
    ///   - secure: Flag to indicate whether or not to use HTTPS. Default is
    ///   false.
    ///   - configuration: The URLSessionConfiguration to use when sending
    ///  commands. Default is URLSessionConfiguration.default.
    public init(host: String, port: Int = 9851, secure: Bool? = false, configuration: URLSessionConfiguration? = nil) {
        self.host = host
        self.port = port
        self.secure = secure ?? false
        let config = configuration ?? URLSessionConfiguration.default
        urlSession = URLSession(configuration: config)
    }

    // MARK - Private
    
    fileprivate func parseResponse<R:Codable>(data: Data, for command: Command, response: R.Type) throws -> R {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonDict = json as? Dictionary<String,Any> else {
            throw Failure.badResponse
        }
        guard let ok = jsonDict["ok"] as? Bool, ok == true else {
            throw Failure.badResponse
        }
        let response = try JSONDecoder().decode(R.self, from: data)
        return response
    }
    
    // MARK: - Public
    
    @discardableResult
    public func perform<R:Codable>(command: Command, success: @escaping(_ response: R)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        let request: URLRequest
        do {
            request = try URLRequest.requestFor(command: command, secure: secure, host: host, port: port)
        } catch {
            failure(error)
            return nil
        }
        let task = urlSession.dataTask(with: request) { [weak self] (data, urlResponse, error) in
            if let error = error {
                failure(error)
                return
            }
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                failure(Failure.badResponse)
                return
            }
            switch httpResponse.statusCode {
            case 200:
                guard let strongSelf = self, let data = data else {
                    failure(Failure.unexpectedError)
                    return
                }
                do {
                    let response = try strongSelf.parseResponse(data: data, for: command, response: R.self)
                    success(response)
                } catch {
                    failure(error)
                }
            default:
                failure(Failure.badResponse)
            }
        }
        task.resume()
        return task
    }
}

// MARK: - Convenience

extension Connection {
    
    // MARK: - OK Commands
    
    @discardableResult
    public func send(command: Command.OK, success: @escaping(OkResponse)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: OkResponse) in
            success(response)
        }, failure: failure)
    }
    
    // MARK: - Ungrouped Commands
    
    @discardableResult
    public func bounds(command: Command.Bounds, success: @escaping(BoundsResponse)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: BoundsResponse) in
            success(response)
        }, failure: failure)
    }
    
    @discardableResult
    public func keys(command: Command.Keys, success: @escaping(KeysResponse)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: KeysResponse) in
            success(response)
        }, failure: failure)
    }
    
    @discardableResult
    public func stats(command: Command.Stats, success: @escaping(StatsResponse)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: StatsResponse) in
            success(response)
        }, failure: failure)
    }
    
    @discardableResult
    public func ttl(command: Command.TTL, success: @escaping(TTLResponse)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: TTLResponse) in
            success(response)
        }, failure: failure)
    }
    
}
