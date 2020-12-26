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
    case subscribe(object: SubscribeResponse)
    case unknown

    init(value: RESPValue) {
        if value.ok {
            self = .ok
        } else if value.pong {
            self = .pong
        } else if value.subscribe != nil {
            self = .subscribe(object: value.subscribe!)
        } else if value.geoJSON.isEmpty == false {
            self = .geoJSON(objects: value.geoJSON)
        } else {
            self = .unknown
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

    // MARK: - Private

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

    // MARK: - Public

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

    public func subscribe(to channel: String, receivedHandler: @escaping(Response) -> Void) {
        connect { connection in
            connection.subscribe(to: RedisChannelName(channel)) { (channel, value) in
                receivedHandler(Response(value: value))
            }.whenComplete { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }

    public func unsubscribe(from channel: String) {
        connect { connection in
            connection.unsubscribe(from: RedisChannelName(channel)).whenComplete { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }

}
