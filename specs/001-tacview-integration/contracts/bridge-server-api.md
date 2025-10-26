# Bridge Server API Contract

**Feature**: 001-tacview-integration  
**Created**: 2025-10-26  
**Purpose**: Define HTTP API contract for Tacview bridge server communication

## Overview

The bridge server receives ACMI data from Stormworks addon and forwards it to Tacview for visualization. Communication uses HTTP GET requests with Base64-encoded ACMI data in the URL path.

## Endpoint Specification

### ACMI Data Transmission

**Method**: `GET`  
**URL**: `http://localhost:3000/acmi/{BASE64_ACMI_DATA}`  
**Content-Type**: Not applicable (GET request)  
**Authentication**: None (localhost communication)

#### Parameters

| Parameter        | Type   | Location | Required | Description                      |
| ---------------- | ------ | -------- | -------- | -------------------------------- |
| BASE64_ACMI_DATA | string | Path     | Yes      | Base64-encoded ACMI data package |

#### Request Format

```http
GET /acmi/IzEyMy40NTYKMTIzLFQ9MC4wMDEyMzR8MC4wMDU2Nzh8MTUwLjV8fHx8fHwsVHlwZT1BaXIrRml4ZWRXaW5nLE5hbWU9Ri0xNkMsQ29sb3I9Qmx1ZQo= HTTP/1.1
Host: localhost:3000
User-Agent: Stormworks-Addon/1.0
```

#### Response Specification

**Success Response**:

- **Status Code**: `200 OK`
- **Body**: Empty or acknowledgment message
- **Headers**: Standard HTTP headers

**Error Responses**:

- **Status Code**: `400 Bad Request` - Invalid Base64 data
- **Status Code**: `500 Internal Server Error` - Server processing error
- **Body**: Error message (optional)

**Note**: Stormworks `server.httpGet()` API does not provide response data to the addon, so error handling is not possible on the client side.

## ACMI Data Format

### Encoded Data Structure

The BASE64_ACMI_DATA parameter contains a Base64-encoded string representing ACMI format data with the following structure:

```
#{timestamp}
{vehicleId},T={lon}|{lat}|{alt}||||||,Type={tag},Name={name},Color={color}
-{vehicleId}
```

### Example ACMI Data (Before Base64 Encoding)

```
#123.456
123,T=0.001234|0.005678|150.5||||||,Type=Air+FixedWing,Name=F-16C,Color=Blue
456,T=0.002468|0.011356|200.0||||||,Type=Air+FixedWing,Name=F-16C,Color=Blue
-789
```

### Field Specifications

| Field     | Type    | Format              | Example         | Description                             |
| --------- | ------- | ------------------- | --------------- | --------------------------------------- |
| timestamp | number  | Decimal seconds     | `123.456`       | Game time in seconds                    |
| vehicleId | integer | Positive integer    | `123`           | Stormworks vehicle ID                   |
| lon       | number  | Decimal degrees     | `0.001234`      | Longitude (converted from x coordinate) |
| lat       | number  | Decimal degrees     | `0.005678`      | Latitude (converted from z coordinate)  |
| alt       | number  | Decimal meters      | `150.5`         | Altitude (y coordinate)                 |
| tag       | string  | ACMI classification | `Air+FixedWing` | Vehicle type identifier                 |
| name      | string  | Display name        | `F-16C`         | Vehicle display name                    |
| color     | string  | Color identifier    | `Blue`          | Vehicle color code                      |

## Coordinate Conversion

Stormworks coordinates are converted to geographic coordinates using the following formulas:

```
longitude = x_coordinate * 0.000009090909090909091
latitude = z_coordinate * 0.000009090909090909091
altitude = y_coordinate (no conversion)
```

## Error Handling

### Client-Side (Stormworks Addon)

- **Fire-and-forget**: No error handling possible due to API limitations
- **Graceful degradation**: Continue tracking vehicles regardless of network status
- **No retries**: Single HTTP GET request per update cycle

### Server-Side (Bridge Server)

- **Invalid Base64**: Return 400 Bad Request
- **Malformed ACMI**: Log error, attempt partial processing
- **Tacview connection issues**: Handle gracefully, maintain buffer if possible

## Performance Considerations

### Request Frequency

- **Update Interval**: Every 6 ticks (0.1 seconds)
- **Maximum Vehicles**: 50 simultaneous vehicles
- **Typical Load**: 10-20 requests per second

### Data Size Limits

- **Base64 Overhead**: ~33% size increase from original ACMI data
- **URL Length**: Must fit within HTTP URL length limits (~2048 characters)
- **Typical Package Size**: 100-500 bytes encoded

### Reliability

- **Network Tolerance**: Addon continues operation if bridge server unavailable
- **No Acknowledgment**: Success/failure not reported to addon
- **Stateless**: Each request is independent, no session management

## Integration Testing

### Test Scenarios

1. **Single Vehicle Tracking**:

   ```
   Spawn vehicle -> Verify HTTP GET with correct ACMI data
   ```

2. **Multiple Vehicle Updates**:

   ```
   Spawn 3 vehicles -> Verify batched ACMI data in single request
   ```

3. **Vehicle Lifecycle**:

   ```
   Spawn -> Track -> Despawn -> Verify deletion command
   ```

4. **Network Resilience**:
   ```
   Stop bridge server -> Verify addon continues operation
   ```

### Validation Points

- Base64 encoding/decoding accuracy
- ACMI format compliance
- Coordinate conversion precision
- Update timing consistency
- Error tolerance under adverse conditions
