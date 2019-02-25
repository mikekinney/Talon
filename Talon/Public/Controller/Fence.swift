//
//  Fence.swift
//  Talon
//
//  Created by Mike on 1/31/19.
//  Copyright © 2019 Mike Kinney. All rights reserved.
//

import Foundation

public protocol FenceDelegate: class {
    /// The Fence is connected to the server.
    ///
    /// - Parameter fence: The Fence that connected.
    func fenceDidConnect(_ fence: Fence)
    
    /// The Fence has disconnected from the server.
    ///
    /// - Parameter fence: The Fence that disconnected.
    func fenceDidDisconnect(_ fence: Fence)
    
    /// The Fence is ready to start receiving updates. This is called shortly
    /// after fenceDidConnect is called.
    ///
    /// - Parameter fence: The Fence that is ready.
    func fenceReady(_ fence: Fence)
    
    /// Objects have been detected that meet the Fence criteria.
    ///
    /// - Parameters:
    ///   - fence: The Fence that has detected changes.
    ///   - update: The update containing the detected changes.
    func fenceDidReceiveUpdate(_ fence: Fence, update: FenceUpdateResponse)
    
    /// Called when an error occurs.
    ///
    /// - Parameters:
    ///   - fence: The Fence that encountered an error.
    ///   - error: The error.
    func fenceError(_ fence: Fence, error: Error)
}

public class Fence {
    
    // MARK: - Properties
    
    let command: Command.Fence
    weak var delegate: FenceDelegate?
    
    // MARK: - Private Properties
    
    fileprivate let socket: WebSocket
    fileprivate var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
        return formatter
    }
    
    // MARK: - Lifecycle
    
    public init(host: String, port: Int = 9851, delegate: FenceDelegate?, command: Command.Fence) {
        self.delegate = delegate
        self.command = command
        var components = URLComponents()
        // TODO: Support secure connection
        components.scheme = "ws"
        components.host = host
        components.port = port
        components.path = "/"+command.httpCommand
        self.socket = WebSocket(url: components.url!)
        self.socket.delegate = self
        self.socket.connect()
    }
    
    public func disconnect() {
        // Calling socket.disconnect() does not trigger its disconnect delegate.
        // We'll call our own manually.
        socket.disconnect()
        delegate?.fenceDidDisconnect(self)
    }
    
}

// MARK: - WebSocketDelegate

extension Fence: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        delegate?.fenceDidConnect(self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        delegate?.fenceDidDisconnect(self)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else {
            return
        }
        // Expect an ok / live message before receiving update responses.
        if text == "{\"ok\":true,\"live\":true}" {
            delegate?.fenceReady(self)
            return
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let obj = try decoder.decode(FenceUpdateResponse.self, from: data)
            delegate?.fenceDidReceiveUpdate(self, update: obj)
        } catch {
            delegate?.fenceError(self, error: error)
            Log.debug(message: "Fence decoding error: \(error)")
            Log.debug(message: text)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // Not expecting data messages
    }
}
