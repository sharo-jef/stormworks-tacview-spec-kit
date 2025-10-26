-- Tacview Integration Addon for Stormworks
-- Automatically tracks spawned vehicles and transmits position data to Tacview
-- Author: Auto-generated from specification 001-tacview-integration
-- Date: 2025-10-26

-- ============================================================================
-- ADDON STATE STRUCTURE
-- ============================================================================

-- Global addon state - managed throughout lifecycle
local addon_state = {
    -- Core tracking
    vehicles = {}, -- number[] - array of vehicle IDs
    ticks = 0,

    -- Timing control
    tickCounter = 0,
    lastUpdateTick = 0,
    updateInterval = 6, -- ticks (0.1 seconds at 60 TPS)

    -- Network configuration
    bridgePort = 3000,
    bridgeHost = "localhost",

    -- ACMI metadata (constants)
    vehicleTag = "Air+FixedWing",
    vehicleName = "F-16C",
    vehicleColor = "Blue",

    -- Statistics (for debugging)
    totalVehiclesTracked = 0,
    totalUpdatesSent = 0,
    lastError = nil
}

-- ============================================================================
-- STORMWORKS LIFECYCLE CALLBACKS
-- ============================================================================

-- Called when the addon is loaded
function onCreate(is_world_create)
    -- Initialize addon state
    addon_state.vehicles = {}
    addon_state.ticks = 0
    addon_state.tickCounter = 0
    addon_state.lastUpdateTick = 0
    addon_state.totalVehiclesTracked = 0
    addon_state.totalUpdatesSent = 0
    addon_state.lastError = nil

    debug.log("Tacview Integration Addon: Initialized")
end

-- Called every game tick (60 times per second)
function onTick()
    -- Process tick data
    addon_state.ticks = addon_state.ticks + 1
    addon_state.tickCounter = addon_state.tickCounter + 1

    -- Check if it's time for an update cycle (every 6 ticks = 0.1 seconds)
    if addon_state.tickCounter % addon_state.updateInterval == 0 then
        -- Update cycle - process all vehicles and transmit data
        performUpdateCycle()
        addon_state.lastUpdateTick = addon_state.ticks
    end
end

-- Called when a vehicle is spawned
function onVehicleSpawn(vehicle_id)
    if not vehicle_id or vehicle_id <= 0 then
        addon_state.lastError = "onVehicleSpawn: Invalid vehicle_id"
        return
    end

    -- Check if vehicle is already being tracked
    for _, tracked_id in ipairs(addon_state.vehicles) do
        if tracked_id == vehicle_id then
            debug.log("Tacview Integration: Vehicle " .. tostring(vehicle_id) .. " already tracked")
            return
        end
    end

    -- Add vehicle to tracking array
    table.insert(addon_state.vehicles, vehicle_id)
    addon_state.totalVehiclesTracked = addon_state.totalVehiclesTracked + 1

    debug.log("Tacview Integration: Vehicle spawned and tracked - ID: " ..
        tostring(vehicle_id) .. " (Total: " .. tostring(#addon_state.vehicles) .. ")")
end

-- Called when a vehicle is despawned
function onVehicleDespawn(vehicle_id)
    if not vehicle_id or vehicle_id <= 0 then
        addon_state.lastError = "onVehicleDespawn: Invalid vehicle_id"
        return
    end

    -- Find and remove vehicle from tracking array
    for i = #addon_state.vehicles, 1, -1 do
        if addon_state.vehicles[i] == vehicle_id then
            table.remove(addon_state.vehicles, i)
            debug.log("Tacview Integration: Vehicle despawned and removed from tracking - ID: " ..
                tostring(vehicle_id) .. " (Remaining: " .. tostring(#addon_state.vehicles) .. ")")

            -- Send immediate deletion notification to Tacview
            sendVehicleDeletion(vehicle_id)
            return
        end
    end

    -- Vehicle was not being tracked
    debug.log("Tacview Integration: Vehicle despawned but was not tracked - ID: " .. tostring(vehicle_id))
end

-- ============================================================================
-- SAVE/LOAD CALLBACKS (Stormworks Persistence)
-- ============================================================================

-- Called when mission data needs to be saved
function onSave()
    -- No persistent state required - vehicle tracking is ephemeral
    return {}
end

-- Called when mission data is loaded
function onLoad(save_data)
    -- Vehicle tracking will rebuild naturally from spawn events
    debug.log("Tacview Integration Addon: Loaded (no persistent state)")
end

-- ============================================================================
-- BASE64 ENCODING UTILITY
-- ============================================================================

-- Base64 encoder using lookup table approach for performance
-- Returns nil on encoding failure for graceful error handling
local Base64 = {
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
}

function Base64.encode(input)
    if not input or type(input) ~= "string" then
        addon_state.lastError = "Base64.encode: Invalid input type"
        return nil
    end

    if #input == 0 then
        return ""
    end

    local result = {}
    local padding = ""

    -- Process input in 3-byte chunks
    for i = 1, #input, 3 do
        local byte1 = string.byte(input, i)
        local byte2 = string.byte(input, i + 1) or 0
        local byte3 = string.byte(input, i + 2) or 0

        -- Convert 3 bytes to 4 Base64 characters
        local combined = (byte1 << 16) + (byte2 << 8) + byte3

        local char1 = string.sub(Base64.chars, ((combined >> 18) & 63) + 1, ((combined >> 18) & 63) + 1)
        local char2 = string.sub(Base64.chars, ((combined >> 12) & 63) + 1, ((combined >> 12) & 63) + 1)
        local char3 = string.sub(Base64.chars, ((combined >> 6) & 63) + 1, ((combined >> 6) & 63) + 1)
        local char4 = string.sub(Base64.chars, (combined & 63) + 1, (combined & 63) + 1)

        table.insert(result, char1)
        table.insert(result, char2)
        table.insert(result, char3)
        table.insert(result, char4)
    end

    -- Handle padding for incomplete groups
    local remainder = #input % 3
    if remainder == 1 then
        result[#result] = "="
        result[#result - 1] = "="
    elseif remainder == 2 then
        result[#result] = "="
    end

    return table.concat(result)
end

-- ============================================================================
-- COORDINATE CONVERSION FUNCTIONS
-- ============================================================================

-- Coordinate scale factor for Stormworks to geographic conversion
local COORD_SCALE = 0.000009090909090909091

-- Convert Stormworks world coordinates to geographic coordinates
function convertCoordinates(x, y, z)
    if not x or not y or not z then
        addon_state.lastError = "convertCoordinates: Invalid coordinate values"
        return nil, nil, nil
    end

    -- Convert to numbers if they aren't already
    local num_x = tonumber(x)
    local num_y = tonumber(y)
    local num_z = tonumber(z)

    if not num_x or not num_y or not num_z then
        addon_state.lastError = "convertCoordinates: Non-numeric coordinate values"
        return nil, nil, nil
    end

    local longitude = num_x * COORD_SCALE
    local latitude = num_z * COORD_SCALE
    local altitude = num_y -- No conversion needed for altitude

    return longitude, latitude, altitude
end

-- ============================================================================
-- ACMI DATA FORMATTING FUNCTIONS
-- ============================================================================

local ACMIFormatter = {}

-- Format timestamp line for ACMI data
function ACMIFormatter.formatTimestamp(game_ticks)
    if not game_ticks or type(game_ticks) ~= "number" then
        addon_state.lastError = "ACMIFormatter.formatTimestamp: Invalid game_ticks"
        return nil
    end

    -- Convert game ticks to seconds (60 TPS)
    local seconds = game_ticks / 60.0
    return "#" .. tostring(seconds) .. "\n"
end

-- Format vehicle data line for ACMI
function ACMIFormatter.formatVehicleLine(vehicle_id, longitude, latitude, altitude)
    if not vehicle_id or not longitude or not latitude or not altitude then
        addon_state.lastError = "ACMIFormatter.formatVehicleLine: Missing required parameters"
        return nil
    end

    -- Validate parameters
    local num_id = tonumber(vehicle_id)
    local num_lon = tonumber(longitude)
    local num_lat = tonumber(latitude)
    local num_alt = tonumber(altitude)

    if not num_id or not num_lon or not num_lat or not num_alt then
        addon_state.lastError = "ACMIFormatter.formatVehicleLine: Invalid numeric parameters"
        return nil
    end

    -- Format: {vehicleId},T={lon}|{lat}|{alt}||||||,Type={tag},Name={name},Color={color}
    local line = string.format(
        "%d,T=%.6f|%.6f|%.1f||||||,Type=%s,Name=%s,Color=%s\n",
        num_id,
        num_lon,
        num_lat,
        num_alt,
        addon_state.vehicleTag,
        addon_state.vehicleName,
        addon_state.vehicleColor
    )

    return line
end

-- Format vehicle deletion line for ACMI
function ACMIFormatter.formatDeletionLine(vehicle_id)
    if not vehicle_id then
        addon_state.lastError = "ACMIFormatter.formatDeletionLine: Missing vehicle_id"
        return nil
    end

    local num_id = tonumber(vehicle_id)
    if not num_id then
        addon_state.lastError = "ACMIFormatter.formatDeletionLine: Invalid vehicle_id"
        return nil
    end

    return "-" .. tostring(num_id) .. "\n"
end

-- Create complete ACMI data package
function ACMIFormatter.createPackage(game_ticks, vehicle_data_lines, deletion_lines)
    if not game_ticks then
        addon_state.lastError = "ACMIFormatter.createPackage: Missing game_ticks"
        return nil
    end

    local package_lines = {}

    -- Add timestamp
    local timestamp_line = ACMIFormatter.formatTimestamp(game_ticks)
    if not timestamp_line then
        return nil -- Error already set
    end
    table.insert(package_lines, timestamp_line)

    -- Add vehicle data lines
    if vehicle_data_lines and type(vehicle_data_lines) == "table" then
        for _, line in ipairs(vehicle_data_lines) do
            if line then
                table.insert(package_lines, line)
            end
        end
    end

    -- Add deletion lines
    if deletion_lines and type(deletion_lines) == "table" then
        for _, line in ipairs(deletion_lines) do
            if line then
                table.insert(package_lines, line)
            end
        end
    end

    return table.concat(package_lines)
end

-- ============================================================================
-- TICK BUDGET MANAGEMENT AND UPDATE CYCLE
-- ============================================================================

-- Main update cycle - processes all vehicles and transmits data
function performUpdateCycle()
    -- Only proceed if we have vehicles to track
    if #addon_state.vehicles == 0 then
        return
    end

    -- Collect position data for all tracked vehicles
    local vehicle_data_lines = {}
    local deletion_lines = {}

    -- Process each tracked vehicle
    for i = #addon_state.vehicles, 1, -1 do -- Iterate backwards for safe removal
        local vehicle_id = addon_state.vehicles[i]
        if vehicle_id then
            local vehicle_line = processVehicleForACMI(vehicle_id)
            if vehicle_line then
                table.insert(vehicle_data_lines, vehicle_line)
            else
                -- Vehicle could not be processed - might be despawned
                -- Remove from tracking array
                table.remove(addon_state.vehicles, i)
            end
        end
    end

    -- Create and transmit ACMI package if we have data
    if #vehicle_data_lines > 0 or #deletion_lines > 0 then
        transmitACMIData(vehicle_data_lines, deletion_lines)
    end
end

-- Process a single vehicle for ACMI data generation
function processVehicleForACMI(vehicle_id)
    if not vehicle_id then
        return nil
    end

    -- Get vehicle transform matrix using the correct Stormworks API
    local transform_matrix, is_success = server.getVehiclePos(vehicle_id)
    if not is_success or not transform_matrix then
        addon_state.lastError = "Failed to get position for vehicle " .. tostring(vehicle_id)
        return nil
    end

    -- Extract position from transform matrix using matrix.position
    local x, y, z = matrix.position(transform_matrix)
    if not x or not y or not z then
        addon_state.lastError = "Failed to extract position from matrix for vehicle " .. tostring(vehicle_id)
        return nil
    end

    -- Convert to geographic coordinates
    local longitude, latitude, altitude = convertCoordinates(x, y, z)
    if not longitude or not latitude or not altitude then
        return nil -- Error already set
    end

    -- Format as ACMI vehicle line
    return ACMIFormatter.formatVehicleLine(vehicle_id, longitude, latitude, altitude)
end

-- Transmit ACMI data to bridge server
function transmitACMIData(vehicle_data_lines, deletion_lines)
    -- Create ACMI package
    local acmi_data = ACMIFormatter.createPackage(addon_state.ticks, vehicle_data_lines, deletion_lines)
    if not acmi_data then
        return -- Error already set
    end

    -- Encode as Base64
    local encoded_data = Base64.encode(acmi_data)
    if not encoded_data then
        return -- Error already set
    end

    -- Build HTTP path for the request
    local path = "/acmi/" .. encoded_data

    -- Send HTTP GET request (fire-and-forget)
    server.httpGet(addon_state.bridgePort, path)

    -- Update statistics
    addon_state.totalUpdatesSent = addon_state.totalUpdatesSent + 1
end

-- Send immediate vehicle deletion notification
function sendVehicleDeletion(vehicle_id)
    if not vehicle_id then
        addon_state.lastError = "sendVehicleDeletion: Missing vehicle_id"
        return
    end

    -- Create deletion line
    local deletion_line = ACMIFormatter.formatDeletionLine(vehicle_id)
    if not deletion_line then
        return -- Error already set
    end

    -- Send as immediate ACMI package
    transmitACMIData({}, { deletion_line })

    debug.log("Tacview Integration: Sent deletion notification for vehicle " .. tostring(vehicle_id))
end

-- Vehicle position tracking functions (to be implemented in Phase 3)
local VehicleTracker = {}

-- HTTP transmission functions (now implemented above)
local NetworkTransmitter = {}

-- ============================================================================
-- DEBUG AND MONITORING
-- ============================================================================

-- ============================================================================
-- PERFORMANCE MONITORING AND DEBUGGING
-- ============================================================================

-- Get current addon statistics for debugging
function getAddonStats()
    return {
        vehicleCount = #addon_state.vehicles,
        totalTracked = addon_state.totalVehiclesTracked,
        totalSent = addon_state.totalUpdatesSent,
        currentTick = addon_state.ticks,
        lastUpdateTick = addon_state.lastUpdateTick,
        ticksSinceLastUpdate = addon_state.ticks - addon_state.lastUpdateTick,
        lastError = addon_state.lastError,
        updateInterval = addon_state.updateInterval
    }
end

-- Log performance statistics (for debugging)
function logPerformanceStats()
    local stats = getAddonStats()
    debug.log(string.format(
        "Tacview Integration Stats - Vehicles: %d, Tracked: %d, Updates: %d, Tick: %d",
        stats.vehicleCount,
        stats.totalTracked,
        stats.totalSent,
        stats.currentTick
    ))
end

-- Validate addon state integrity
function validateAddonState()
    local errors = {}

    if not addon_state.vehicles or type(addon_state.vehicles) ~= "table" then
        table.insert(errors, "Invalid vehicles array")
    end

    if not addon_state.updateInterval or addon_state.updateInterval <= 0 then
        table.insert(errors, "Invalid update interval")
    end

    if #errors > 0 then
        addon_state.lastError = "State validation failed: " .. table.concat(errors, ", ")
        return false
    end

    return true
end

debug.log("Tacview Integration Addon: Script loaded successfully")
