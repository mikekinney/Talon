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
        case invalidURL
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
    ///  commands. Default is ephemeral.
    public init(host: String, port: Int = 9851, secure: Bool? = false, configuration: URLSessionConfiguration? = nil) {
        self.host = host
        self.port = port
        self.secure = secure ?? false
        let config = configuration ?? URLSessionConfiguration.ephemeral
        urlSession = URLSession(configuration: config)
    }

    // MARK - Private
    
    fileprivate func urlRequestFor(command: Command) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = secure ? "https" : "http"
        components.host = host
        components.port = port
        components.path = "/"+command.httpCommand
        guard let url = components.url else {
            Log.debug(message: "Unable to construct URL for: " + components.debugDescription)
            throw(Failure.invalidURL)
        }
        let request = URLRequest(url: url)
        return request
    }
    
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
    
    fileprivate func geoJSONObject(from dictionary: Dictionary<String,Any>) throws -> GeoJSON {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)
        return geoJSON
    }
    
    // MARK: - Public
    
    @discardableResult
    public func perform<R:Codable>(command: Command, success: @escaping(_ response: R)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        let request: URLRequest
        do {
            request = try urlRequestFor(command: command)
        } catch {
            failure(error)
            return nil
        }
        Log.debug(message: "Perform Command: " + (request.url?.absoluteString ?? "null"))
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
                #if DEBUG
                if let string = String(data: data, encoding: .utf8) {
                    Log.debug(message: string)
                }
                #endif
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
    
    // MARK: - GET Commands
    
    @discardableResult
    public func get(command: Command.Get.Bound, success:@escaping(GetBoundsResponse)->Void, failure:@escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: GetBoundsResponse) in
            success(response)
        }, failure: failure)
    }

    @discardableResult
    public func get(command: Command.Get.Hash, success: @escaping(GetHashResponse)->Void, failure:@escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: GetHashResponse) in
            success(response)
        }, failure: failure)
    }

    @discardableResult
    public func get(command: Command.Get.Object, success: @escaping(GeoJSON, [String:Any]?)->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { [weak self] (response: GetObjectResponse) in
            guard let strongSelf = self else {
                failure(Failure.unexpectedError)
                return
            }
            let jsonDict = response.object.dictionary as [String:Any]
            let geoJSON: GeoJSON
            do {
                geoJSON = try strongSelf.geoJSONObject(from: jsonDict)
            } catch {
                failure(error)
                return
            }
            if let fields = response.fields?.dictionary {
                success(geoJSON, fields as [String:Any])
            } else {
                success(geoJSON, nil)
            }
        }, failure: failure)
    }
    
    @discardableResult
    public func get(command: Command.Get.Point, success:@escaping(GetPointResponse)->Void, failure:@escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { (response: GetPointResponse) in
            success(response)
        }, failure: failure)
    }
    
    // MARK: - List Commands
    
    @discardableResult
    public func list(command: Command.ObjectList, success: @escaping(ObjectListResponse, [GeoJSON])->Void, failure: @escaping(Error)->Void) -> URLSessionDataTask? {
        return perform(command: command, success: { [weak self] (response: ObjectListResponse) in
            guard let strongSelf = self else {
                failure(Failure.unexpectedError)
                return
            }
            var jsonObjects: [GeoJSON] = []
            response.objects.forEach({ (codableDictionary) in
                let dict = codableDictionary.dictionary as [String:Any]
                guard let obj = dict["object"] as? [String:Any] else { return }
                do {
                    let feature = try strongSelf.geoJSONObject(from: obj)
                    jsonObjects.append(feature)
                } catch {
                    Log.debug(message: "Unable to parse GeoJSON object \(obj)")
                }
            })
            success(response, jsonObjects)
        }, failure: failure)
    }

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
