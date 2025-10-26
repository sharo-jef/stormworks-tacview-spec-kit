# Data Model: Tacview Integration Addon

**Feature**: 001-tacview-integration  
**Created**: 2025-10-26  
**Purpose**: Define data structures and state management for vehicle tracking system

## Core Entities

### TrackedVehicle

Represents a spawned vehicle being monitored for Tacview integration.

**Fields**:

- `id` (number): Stormworks vehicle ID, used as unique identifier
- `lastUpdate` (number): Game tick when position was last retrieved
- `isActive` (boolean): Whether vehicle is currently being tracked
- `transformMatrix` (table): Last known transform matrix from Stormworks API

**Relationships**:

- Managed by TrackedVehicleCollection
- Referenced in ACMI data packages
- Created/destroyed via spawn/despawn events

**Validation Rules**:

- Vehicle ID must be positive integer
- isActive flag must reflect current spawn state
- transformMatrix must be valid 16-element array or nil

**State Transitions**:

```
[Spawned] -> onCreate -> [Tracked] -> onUpdate -> [Tracked]
[Tracked] -> onDespawn -> [Removed]
[Tracked] -> onInvalidPosition -> [Tracked] (graceful degradation)
```

### TrackedVehicleCollection

Container for managing all active vehicle instances.

**Fields**:

- `vehicles` (number[]): Array of vehicle IDs currently being tracked
- `ticks` (number): Current tick (+1 on onTick calls)

**Relationships**:

- Contains vehicle IDs that reference spawned vehicles
- Interfaces with ACMI data generation
- Managed by main addon state

**Validation Rules**:

- Vehicle IDs must be unique within array
- All vehicle IDs must be positive integers
- Array length represents current vehicle count

**Operations**:

- `addVehicle(vehicleId)`: Add vehicle ID to tracking array if not already present
- `removeVehicle(vehicleId)`: Remove vehicle ID from tracking array

### ACMIPackage

Contains formatted ACMI data ready for transmission to bridge server.

**Fields**:

- `timestamp` (number): Game timestamp in seconds
- `vehicleData` (table): Array of vehicle data strings
- `deletionData` (table): Array of vehicle deletion strings
- `encodedData` (string): Base64-encoded complete ACMI package

**Relationships**:

- Generated from TrackedVehicleCollection
- Consumed by HTTP transmission system
- Temporary object created per update cycle

**Validation Rules**:

- Timestamp must be positive number
- Vehicle data must follow ACMI format specification
- Encoded data must be valid Base64 string

**Format Specification**:

```
Timestamp Line: "#{timestamp}\n"
Vehicle Line: "{vehicleId},T={lon}|{lat}|{alt}||||||,Type={tag},Name={name},Color={color}\n"
Deletion Line: "-{vehicleId}\n"
```

### Base64Encoder

Utility for encoding ACMI data packages for HTTP transmission.

**Fields**:

- `chars` (string): Base64 character lookup table
- `padding` (string): Padding character for incomplete groups

**Relationships**:

- Used by ACMIPackage for data encoding
- Stateless utility, no persistent data

**Operations**:

- `encode(input)`: Convert string to Base64 representation

**Implementation Constraints**:

- Pure Lua implementation (no external libraries)
- Single-pass encoding for tick budget compliance
- Handle arbitrary string lengths within memory limits

## State Management

### Addon State Structure

```lua
local addon_state = {
    -- Core tracking
    vehicles = {}, -- number[] - array of vehicle IDs
    ticks = 0,

    -- Timing control
    tickCounter = 0,
    lastUpdateTick = 0,
    updateInterval = 6, -- ticks

    -- Network configuration
    bridgePort = 3000,
    bridgeHost = "localhost",

    -- ACMI metadata (constants)
    vehicleTag = "Air+FixedWing",
    vehicleName = "F-16C",
    vehicleColor = "Blue",

    -- Statistics (for debugging)
    totalVehiclesTracked = 0,
    totalUpdatessent = 0,
    lastError = nil
}
```

### Persistence Strategy

**No Persistent Storage Required**:

- Vehicle tracking is ephemeral (reset on addon reload)
- Configuration is hardcoded constants
- Statistics reset with each session

**State Recovery**:

- onLoad: Initialize empty vehicle collection
- onSave: Return empty table (no state to persist)
- Spawn events will rebuild vehicle tracking naturally

### Memory Management

**Object Lifecycle**:

- TrackedVehicle: Created on spawn, destroyed on despawn
- ACMIPackage: Created per update, garbage collected after transmission
- Base64Encoder: Singleton utility, persistent for performance

**Memory Optimization**:

- Reuse ACMI format strings where possible
- Limit vehicle collection size to prevent memory bloat
- Clear temporary data structures after each update cycle

## Data Flow

1. Vehicle Spawns -> onVehicleSpawn(id) -> table.insert(vehicles, id)
2. Update Tick -> iterate vehicles[] -> get positions -> ACMIPackage.create()
3. ACMI Package -> Base64Encoder.encode() -> HTTP Transmission
4. Vehicle Despawns -> onVehicleDespawn(id) -> remove id from vehicles[]

```

## Error Handling

**Invalid Vehicle Positions**:

- Skip vehicle in current update cycle
- Maintain vehicle in tracking collection
- Log error to addon state for debugging

**Network Failures**:

- Continue vehicle tracking regardless
- No retry mechanism (fire-and-forget)
- Graceful degradation maintains addon stability

**Memory Constraints**:

- Limit maximum tracked vehicles (50 vehicle limit)
- Clear temporary objects promptly
- Monitor and log memory usage patterns
```
