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

public class Connection {

    // MARK: - Properties

    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let configuration: RedisConnection.Configuration


    // MARK: - Lifecycle

    public init(hostname: String, port: Int? = nil) {
        self.configuration = try! RedisConnection.Configuration(
            hostname: hostname,
            port: port ?? 9851
        )
    }

    public func send(command: CommandProtocol, completion: @escaping(_ response: [GeoJSON]) -> Void) {
        RedisConnection.make(
            configuration: configuration,
            boundEventLoop: eventLoopGroup.next()
        ).whenSuccess { connection in
            let commandName = command.command.name
            let args = command.command.raw.dropFirst().map {
                RESPValue.init(from: $0)
            }
            connection.send(
                command: commandName,
                with: args
            ).whenSuccess { response in
                completion(response.geoJSON)
            }
        }
    }
}
