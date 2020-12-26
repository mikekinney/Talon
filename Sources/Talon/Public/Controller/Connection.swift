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

    public func send(command: CommandProtocol, completion: @escaping(_ response: RESPValue) -> Void) {
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
                completion(response)
            }
        }
    }
}

// TODO: Rewrite and find a better place for this triangle of doom.

//extension RESPValue {
//    var geoJSON: [GeoJSON] {
//        var json: [GeoJSON] = []
//        switch self {
//        case .array(let array):
//            guard let last = array.last else {
//                return json
//            }
//            switch last {
//            case .array(let array):
//                array.forEach { value in
//                    switch value {
//                    case .array(let array):
//                        guard let last = array.last else {
//                            break
//                        }
//                        switch last {
//                        case .bulkString:
//                            guard let data = last.data else {
//                                break
//                            }
//                            guard let geoJSON = try? JSONDecoder().decode(GeoJSON.self, from: data) else {
//                                break
//                            }
//                            json.append(geoJSON)
//                        default:
//                            break
//                        }
//                    default:
//                        break
//                    }
//                }
//            default:
//                break
//            }
//        default:
//            break
//        }
//        return json
//    }
//}
