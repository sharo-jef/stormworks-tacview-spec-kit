---
description: "Task list for Tacview Integration Addon implementation"
---

# Tasks: Tacview Integration Addon

**Input**: Design documents from `/specs/001-tacview-integration/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are NOT explicitly requested in the feature specification, so no test tasks are included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Stormworks Addon**: All code in `script.lua` (single file)
- **Configuration**: `playlist.xml` for mission setup
- **Assets**: `vehicle_2.xml` and other game assets
- **Testing**: Creative mode scenarios and simulation verification

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Stormworks addon initialization and structure

- [x] T001 Initialize script.lua with basic addon structure and Stormworks callbacks (onCreate, onTick, onVehicleSpawn, onVehicleDespawn)
- [x] T002 Configure playlist.xml for mission/addon setup if needed
- [x] T003 [P] Set up creative mode testing environment with test vehicles per quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core Stormworks addon infrastructure that MUST be complete before ANY user story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Implement Base64 encoder utility in script.lua using lookup table approach from research.md (return nil on encoding failure)
- [x] T005 [P] Create addon state structure with vehicles array (number[]), tick counters, and configuration constants in script.lua
- [x] T006 [P] Implement coordinate conversion functions (Stormworks x,z to longitude/latitude) in script.lua
- [x] T007 Create ACMI data formatting functions for timestamp lines, vehicle lines, and deletion lines in script.lua
- [x] T008 Implement tick budget management with 6-tick update cycle control in script.lua
- [x] T009 Add error handling and graceful degradation patterns in script.lua

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Real-Time Vehicle Tracking (Priority: P1) 🎯 MVP

**Goal**: Automatically detect spawned vehicles and transmit their positions to Tacview in real-time every 0.1 seconds

**Independent Test**: Spawn a single vehicle in Stormworks and verify it appears in Tacview with correct position updates every 0.1 seconds

### Implementation for User Story 1

- [x] T010 [P] [US1] Implement onVehicleSpawn callback to add vehicle IDs to tracking array in script.lua
- [x] T011 [P] [US1] Implement vehicle position collection using server.getVehiclePos() and matrix.position() in script.lua
- [x] T012 [US1] Create ACMI data package generation for tracked vehicles with timestamp and position data in script.lua (depends on T010, T011)
- [x] T013 [US1] Implement Base64 encoding of ACMI data packages in script.lua
- [x] T014 [US1] Implement HTTP GET transmission to localhost:3000/acmi/{encoded_data} using server.httpGet() in script.lua
- [x] T015 [US1] Integrate 6-tick update cycle to batch process all vehicles and send data in script.lua
- [x] T016 [US1] Add vehicle metadata (Type=Air+FixedWing, Name=F-16C, Color=Blue) to ACMI format in script.lua

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Vehicle Lifecycle Management (Priority: P2)

**Goal**: Automatically remove vehicles from Tacview when they are despawned in Stormworks

**Independent Test**: Spawn a vehicle, verify it appears in Tacview, then despawn it and confirm it disappears from Tacview

### Implementation for User Story 2

- [x] T017 [P] [US2] Implement onVehicleDespawn callback to remove vehicle IDs from tracking array in script.lua
- [x] T018 [US2] Create ACMI deletion line formatting (-{vehicleId}) in script.lua
- [x] T019 [US2] Integrate vehicle deletion data into ACMI package generation in script.lua
- [x] T020 [US2] Add cleanup logic to prevent memory leaks from stale vehicle references in script.lua

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Consistent Vehicle Identification (Priority: P3)

**Goal**: Ensure all vehicles appear in Tacview with consistent, recognizable metadata

**Independent Test**: Spawn vehicles and verify they appear in Tacview with the specified name "F-16C", type "Air+FixedWing", and color "Blue"

### Implementation for User Story 3

- [x] T021 [P] [US3] Validate consistent metadata constants in addon state structure in script.lua
- [x] T022 [US3] Ensure all ACMI vehicle data lines use the same metadata regardless of vehicle type in script.lua
- [x] T023 [US3] Add metadata validation and fallback handling in script.lua

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T024 [P] Add performance monitoring and statistics tracking (totalVehiclesTracked, totalUpdatesSent) in script.lua
- [x] T025 [P] Add performance monitoring and vehicle count tracking (no hard limit enforced) in script.lua
- [x] T026 Code cleanup and optimization for tick budget compliance in script.lua
- [x] T028 Run quickstart.md validation scenarios in creative mode
- [x] T029 Performance testing with multiple vehicles (20+ simultaneous) in creative mode

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Uses vehicle tracking from US1 but is independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Uses ACMI formatting from US1 but is independently testable

### Within Each User Story

- Core implementation before integration
- Vehicle tracking before data transmission (US1)
- Spawn handling before despawn handling (US2)
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- Within each user story, tasks marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch parallel tasks for User Story 1:
Task T010: "Implement onVehicleSpawn callback to add vehicle IDs to tracking array"
Task T011: "Implement vehicle position collection using server.getVehiclePos()"
# Then sequential integration:
Task T012: "Create ACMI data package generation" (depends on T010, T011)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Real-Time Tracking)
   - Developer B: User Story 2 (Lifecycle Management)
   - Developer C: User Story 3 (Consistent Metadata)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different sections of script.lua, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- All code goes in single script.lua file (Stormworks constraint)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Constitution compliance: No setmetatable(), no require(), tick-based execution
