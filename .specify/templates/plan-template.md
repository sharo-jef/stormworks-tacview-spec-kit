# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Lua 5.4 (Stormworks subset)  
**Primary Dependencies**: None - self-contained code only, no LifeBoatAPI  
**Storage**: Stormworks property system and save/load callbacks  
**Testing**: Creative mode simulation and gameplay scenarios  
**Target Platform**: Stormworks game environment (Windows/Linux)
**Project Type**: Stormworks addon - single script.lua file  
**Performance Goals**: Complete execution within tick budget, responsive gameplay  
**Constraints**: No setmetatable(), no require(), tick-based execution model  
**Scale/Scope**: Single addon, single file, game performance critical

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

- [ ] **Self-Contained Code**: All implementation fits in single script.lua file
- [ ] **Simple Table Architecture**: No setmetatable() usage, plain table structures only
- [ ] **Tick-Based Performance**: No blocking operations, computations split across ticks
- [ ] **State Management Discipline**: Proper use of Stormworks property/save systems
- [ ] **Testing Through Simulation**: Testable scenarios in creative mode defined

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# Stormworks Addon Structure
script.lua                # All implementation code (single file)
playlist.xml             # Mission/addon configuration
vehicle_2.xml           # Associated vehicles if any
.specify/               # Project specification files
├── memory/
│   └── constitution.md
├── templates/
└── scripts/

# Testing Structure (Creative Mode)
Testing is performed through gameplay scenarios in Stormworks creative mode:
- Feature-specific test vehicles/scenarios
- Simulation verification of each user story
- Performance monitoring during gameplay
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation                  | Why Needed         | Simpler Alternative Rejected Because |
| -------------------------- | ------------------ | ------------------------------------ |
| [e.g., 4th project]        | [current need]     | [why 3 projects insufficient]        |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient]  |
