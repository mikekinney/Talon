Talon
=====

Talon is a proof of concept [Tile38](https://tile38.com) client framework for iOS and macOS. Not all commands are supported.

Use
---

* Clone the project `git clone https://github.com/mikekinney/Talon.git`.
* Checkout the submodules `git submodule update --init --recursive`.
* Add `Talon.xcodeproj` to your project as a target dependency.
* Add `Talon.framework` to the `Copy Frameworks` build phase.
* Import `@import Talon` where needed

Connection
----------
Use the `Connection` class to send `Commands` asynchronously. Connection instances can be reused to send multiple commands. See the [Tile38 commands](https://tile38.com/commands/) for additional documentation.

```swift
// Setup a Connection instance.
let connection = Connection(host: "192.168.0.2", port: 9851)

// Get geojson object 'truck1' from 'fleet'
let getTruckObject = Command.Get.Object(key: "fleet", id: "truck1", withFields: true)
connection.get(command: getTruckObject, success: { (geoJSON, fields) in
  // Do something with the geoJSON object
}, failure: { (error) in
  // Do something with the error
})

// Get just the point (lat, long) of 'truck1' from 'fleet'
let getTruckPoint = Command.Get.Point(key: "fleet", id: "truck1", withFields: true)
connection.get(command: getTruckPoint, success: { (response) in
  // Do something with the point
}, failure: { (error) in
  // Do something with the error
})

// Set the point of 'truck1' in 'fleet'
let point = Command.Set(key: "fleet", id: "truck1", format: .point(lat: 33.123, long: -112.2693))
connection.send(command: point, success: { (response) in
  // Point has been set
}, failure: { (error) in
  // Do something with the error
})
```

Fence
-----
Use the `Fence` class to receive continuous geofence updates. Unlike the `Connection` class, a `Fence` can only send a single `Command`.

```swift
// Setup a nearby command to find objects within 6000 meters of a point
let nearby = Command.Nearby(key: "fleet", point: Command.Coordinate(lat: 33.462, lon: 112.268), distance: 6000)

// Create a nearby fence command to detect items that are inside the nearby range, when an object enters, and when an object leaves. 
let nearbyFence = Command.Fence.NearbyFence(command: nearby, detect: [.enter, .inside, .outside])

// Finally, create the fence. The delegate will be notified when objects are detected by the fence.
let fence = Fence(host: "192.168.0.2", port: 9851, delegate: self, command: nearbyFence)

...

// Implement the FenceDelegate

func fenceDidConnect(_ fence: Fence) {
  // Fence connected
}

func fenceReady(_ fence: Fence) {
  // Fence is ready
}

func fenceDidDisconnect(_ fence: Fence) {
  // Fence disconnected
}

func fenceDidReceiveUpdate(_ fence: Fence, update: FenceUpdateResponse) {
  // The server has provided details about objects that meet the fence criteria
}

func fenceError(_ fence: Fence, error: Error) {
  // Something went wrong
}

```

Supported Commands
------------------
- [x] BOUNDS
- [x] DEL
- [x] DROP
- [x] EXPIRE
- [x] FSET
- [x] GET
- [x] INTERSECTS
- [x] KEYS
- [x] NEARBY
- [x] PDELETE
- [x] PING
- [x] PERSIST
- [x] RENAME
- [x] SCAN
- [x] SEARCH
- [x] SET
- [x] TTL
- [x] WITHIN

Third Party
-----------
* [CodableGeoJSON](https://github.com/guykogus/CodableGeoJSON)
* [CodableDictionary](https://github.com/mleiv/CodableDictionary)
* [Starscream](https://github.com/daltoniam/Starscream)