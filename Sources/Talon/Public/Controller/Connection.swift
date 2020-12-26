//
//  Connection.swift
//  Talon
//
//  Created by Mike Kinney on 12/25/20.
//  Copyright © 2020 Mike Kinney. All rights reserved.
//

import Foundation
import NIO
import RediStack
import GEOSwift

public enum Response {
    case ok
    case pong
    case geoJSON(objects: [GeoJSON])

    init(value: RESPValue) {
        if value.okResponse {
            self = .ok
        } else if value.pongResponse {
            self = .pong
        } else {
            self = .geoJSON(objects: value.geoJSON)
        }
    }
}

public class Connection {

    // MARK: - Properties

    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let configuration: RedisConnection.Configuration
    private var connection: RedisConnection?

    // MARK: - Lifecycle

    public init(hostname: String, port: Int? = nil) {
        self.configuration = try! RedisConnection.Configuration(
            hostname: hostname,
            port: port ?? 9851
        )
    }

    deinit {
        connection?.close()
    }

    public func send(command: CommandProtocol, completion: @escaping(Result<Response, Error>) -> Void) {
        connect { connection in
            let commandName = command.command.name
            let args = command.command.raw.dropFirst().map {
                RESPValue.init(from: $0)
            }
            connection.send(
                command: commandName,
                with: args
            )
            .whenComplete { result in
                switch result {
                case .success(let value):
                    completion(.success(Response(value: value)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    private func connect(_ completion: @escaping(_ connection: RedisConnection) -> Void) {
        if let connection = connection, connection.isConnected {
            completion(connection)
            return
        }
        RedisConnection.make(
            configuration: configuration,
            boundEventLoop: eventLoopGroup.next()
        ).whenComplete { [weak self] result in
            switch result {
            case .success(let connection):
                self?.connection = connection
                completion(connection)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

}
