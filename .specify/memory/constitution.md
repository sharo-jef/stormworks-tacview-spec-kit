<!--
Sync Impact Report:
- Version change: Initial → 1.0.0
- New constitution for Stormworks addon project
- Added sections: Core Principles (5), Stormworks Constraints, Performance Standards
- Templates requiring updates: ✅ updated
  - plan-template.md: Updated technical context, constitution check, project structure
  - spec-template.md: Updated edge cases and functional requirements for Stormworks
  - tasks-template.md: Updated path conventions and task examples for single-file addon
- Implementation: ✅ completed
  - script.lua: Basic Stormworks addon structure with constitution compliance
- Follow-up TODOs: None - all placeholders filled, templates aligned
-->

# Stormworks Addon Constitution

## Core Principles

### I. Self-Contained Code (NON-NEGOTIABLE)

All code MUST be contained within script.lua as a single file. No external dependencies, no `require()` statements, no LifeBoatAPI usage permitted. All functionality must be implemented from scratch using only Stormworks' built-in Lua 5.4 environment and provided APIs.

**Rationale**: Stormworks addons have strict constraints on external dependencies and module loading. Self-contained code ensures maximum compatibility and eliminates dependency-related failures.

### II. Simple Table Architecture

All data structures MUST use plain Lua tables without metatables. No `setmetatable()` calls permitted. Object-oriented patterns must be implemented through explicit function calls and table composition, not metamethod magic.

**Rationale**: Stormworks' Lua environment restricts metatable usage. Simple table structures are easier to debug, more predictable in performance, and align with Stormworks' execution constraints.

### III. Tick-Based Performance (NON-NEGOTIABLE)

All code MUST be designed for Stormworks' tick-based execution model. Heavy computations must be split across multiple ticks. No blocking operations, no infinite loops, maximum tick budget must never be exceeded.

**Rationale**: Stormworks addons execute within strict time limits per tick. Performance violations cause addon termination and negatively impact server/client performance.

### IV. State Management Discipline

All persistent state MUST be explicitly managed through Stormworks' property and save/load systems. No global variables that survive across addon reloads unless properly serialized. State changes must be predictable and debuggable.

**Rationale**: Stormworks addons can be reloaded at any time. Improper state management leads to data loss, memory leaks, and unpredictable behavior across game sessions.

### V. Testing Through Simulation

All features MUST be testable within Stormworks' creative mode before deployment. Each feature must have clear success/failure criteria that can be verified through gameplay scenarios.

**Rationale**: Stormworks addons cannot use traditional unit testing frameworks. Simulation-based testing ensures functionality works within the actual game environment and constraints.

## Stormworks Constraints

**Language**: Lua 5.4 (Stormworks subset)
**Forbidden Functions**: `setmetatable()`, `require()`, `loadstring()`, `dofile()`
**External Libraries**: None permitted - no LifeBoatAPI, no external modules
**File Structure**: Single file deployment to script.lua
**Memory Management**: Manual cleanup required, no garbage collection guarantees
**API Surface**: Only Stormworks-provided functions and callbacks allowed
**Execution Model**: Tick-based, non-blocking, time-limited execution per tick

## Performance Standards

**Tick Budget**: Each callback must complete within allocated tick time
**Memory Usage**: Minimize table allocation, reuse objects where possible
**Network Calls**: Batch server.\* API calls, avoid per-tick network operations
**Computation Splitting**: Break heavy operations across multiple ticks using coroutine patterns
**State Persistence**: Use property system efficiently, minimize save data size
**Error Handling**: Graceful degradation required, no addon crashes permitted

## Governance

This constitution supersedes all other development practices for this Stormworks addon project. All code changes must verify compliance with the five core principles before implementation. Performance violations are treated as critical defects requiring immediate resolution.

**Amendment Process**: Constitution changes require documented rationale, impact analysis, and verification that existing code remains compliant.

**Compliance Review**: Each feature implementation must demonstrate adherence to tick-based performance, self-contained architecture, and simple table patterns.

**Version**: 1.0.0 | **Ratified**: 2025-10-26 | **Last Amended**: 2025-10-26
