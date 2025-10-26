# Research: Tacview Integration Addon

**Feature**: 001-tacview-integration  
**Created**: 2025-10-26  
**Purpose**: Resolve technical unknowns for implementation planning

## Research Areas

### 1. Base64 Encoding in Lua

**Task**: Research Base64 encoding implementation for Lua 5.4 without external libraries

**Decision**: Implement custom Base64 encoder using lookup table approach

**Rationale**:

- Stormworks prohibits external libraries and require() statements
- Base64 algorithm is well-defined and can be implemented efficiently in pure Lua
- Lookup table approach provides good performance within tick budget constraints
- Only encoding needed (not decoding), simplifying implementation

**Implementation Approach**:

```lua
local Base64 = {
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
}

function Base64.encode(input)
    -- Implementation using string.byte, bit operations, and lookup table
    -- Process 3 bytes at a time, convert to 4 Base64 characters
    -- Handle padding with = characters for incomplete groups
end
```

**Alternatives Considered**:

- External Lua libraries (rejected: violates constitution)
- Built-in Stormworks encoding (not available)

### 2. ACMI Protocol Implementation

**Task**: Research ACMI data formatting best practices and error handling

**Decision**: Use strict protocol adherence with defensive formatting

**Rationale**:

- ACMI format is well-documented military standard
- Tacview expects precise formatting for proper parsing
- Error in format could cause entire data stream to be rejected

**Implementation Approach**:

- Timestamp format: `#{seconds}\n` where seconds is game time
- Vehicle data: `{id},T={lon}|{lat}|{alt}||||||,Type={tag},Name={name},Color={color}\n`
- Empty fields represented by consecutive separators (||||)
- Deletion format: `-{vehicleId}\n`

**Alternatives Considered**:

- Abbreviated ACMI format (rejected: may cause parsing issues)
- JSON format (rejected: not ACMI standard)

### 3. Stormworks HTTP API Error Handling

**Task**: Research server.httpGet error handling patterns and reliability

**Decision**: Fire-and-forget with graceful degradation strategy

**Rationale**:

- server.httpGet returns nil (no error feedback available)
- Cannot block or retry within tick budget constraints
- Network failures should not crash addon or affect game performance

**Implementation Approach**:

- No error handling for HTTP calls (API limitation)
- Continue vehicle tracking regardless of network state
- Log internal errors to addon state for debugging
- Graceful degradation: addon keeps running even if bridge server unavailable

**Alternatives Considered**:

- Retry mechanisms (rejected: would violate tick budget)
- Error callbacks (not available in Stormworks API)

### 4. Coordinate Conversion Precision

**Task**: Research coordinate transformation accuracy requirements

**Decision**: Use double-precision floating point with validation

**Rationale**:

- Conversion formula provided: x _ 0.000009090909090909091 (longitude), z _ 0.000009090909090909091 (latitude)
- Lua numbers are double-precision by default
- Tacview expects reasonable geographic precision for visualization

**Implementation Approach**:

```lua
local COORD_SCALE = 0.000009090909090909091

local function convertCoordinates(x, y, z)
    local lon = x * COORD_SCALE
    local lat = z * COORD_SCALE
    local alt = y
    return lon, lat, alt
end
```

**Alternatives Considered**:

- Integer scaling (rejected: insufficient precision)
- String formatting for precision control (unnecessary complexity)

### 5. Tick Budget Management

**Task**: Research optimal tick scheduling for multiple vehicle tracking

**Decision**: Staggered processing with 6-tick update cycle

**Rationale**:

- 6 ticks = 0.1 seconds provides responsive tracking
- Process all vehicles in single burst every 6 ticks
- Minimize per-tick overhead while maintaining responsiveness

**Implementation Approach**:

- Use tick counter modulo 6 to trigger update cycles
- Batch all vehicle position queries in single tick
- Prepare and send all ACMI data in same update cycle
- Vehicle spawn/despawn handled immediately in callbacks

**Alternatives Considered**:

- Per-tick processing (rejected: unnecessary overhead)
- Staggered vehicle updates (rejected: increased complexity)
- Variable timing based on vehicle count (rejected: unpredictable performance)

## Technology Decisions Summary

| Component            | Decision                  | Rationale                                          |
| -------------------- | ------------------------- | -------------------------------------------------- |
| Base64 Encoding      | Custom Lua implementation | Constitution compliance, single-file requirement   |
| ACMI Formatting      | Strict protocol adherence | Tacview compatibility, reliable parsing            |
| HTTP Error Handling  | Fire-and-forget pattern   | API limitations, tick budget constraints           |
| Coordinate Precision | Double-precision float    | Built-in Lua precision, adequate for visualization |
| Update Scheduling    | 6-tick batch processing   | Performance balance, responsive tracking           |

## Implementation Readiness

All technical unknowns resolved. Ready for Phase 1 design activities:

- Data model definition
- Contract specification
- Quickstart guide creation
