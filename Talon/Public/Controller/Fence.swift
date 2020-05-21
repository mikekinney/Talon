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
    /// - Parameters
    /// - fence: The Fence that is ready.
    /// - response: The ready response.
    func fence(_ fence: Fence, ready response: FenceReadyResponse)
    
    /// Objects have been detected that meet the Fence criteria.
    ///
    /// - Parameters:
    ///   - fence: The Fence that has detected changes.
    ///   - response: The update containing the detected changes.
    func fence(_ fence: Fence, didUpdate response: FenceUpdateResponse)
    
    /// Called when an object has been deleted from within the Fence/
    ///
    /// - Parameters:
    ///   - fence: The fence that detected changes.
    ///   - response: The deleted response.
    func fence(_ fence: Fence, didDelete response: FenceDeleteResponse)
    
    /// Called when an error occurs.
    ///
    /// - Parameters:
    ///   - fence: The Fence that encountered an error.
    ///   - error: The error.
    func fence(_ fence: Fence, error: Error)
}

public class Fence {
    
    // MARK: - Properties
    
    let command: FenceCommand
    weak var delegate: FenceDelegate?
    
    // MARK: - Private Properties
    
    fileprivate let socket: WebSocket
    fileprivate var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"
        return formatter
    }
    
    // MARK: - Lifecycle
    
    public init(host: String, port: Int = 9851, delegate: FenceDelegate?, command: FenceCommand) {
        self.delegate = delegate
        self.command = command
        var components = URLComponents()
        // TODO: Support secure connection
        components.scheme = "ws"
        components.host = host
        components.port = port
        components.path = "/"+command.command.httpCommand
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
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        var decodingError: Error?
        do {
            let obj = try decoder.decode(FenceUpdateResponse.self, from: data)
            delegate?.fence(self, didUpdate: obj)
            return
        } catch {
            decodingError = error
        }
        
        do {
            let obj = try decoder.decode(FenceDeleteResponse.self, from: data)
            delegate?.fence(self, didDelete: obj)
            return
        } catch {
            decodingError = error
        }
        
        do {
            let obj = try decoder.decode(FenceReadyResponse.self, from: data)
            delegate?.fence(self, ready: obj)
            return
        } catch {
            decodingError = error
        }
        
        if let error = decodingError {
            delegate?.fence(self, error: error)
            Log.debug(message: "Fence decoding error: \(error)")
            Log.debug(message: text)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // Not expecting data messages
    }
}
