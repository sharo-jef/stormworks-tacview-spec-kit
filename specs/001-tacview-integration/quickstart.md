# Quickstart Guide: Tacview Integration Addon

**Feature**: 001-tacview-integration  
**Created**: 2025-10-26  
**Purpose**: Quick setup and testing guide for Stormworks Tacview integration

## Prerequisites

### Software Requirements

- Stormworks Build and Rescue (latest version)
- Tacview (any compatible version)
- Bridge server running on localhost:3000

### Knowledge Requirements

- Basic Stormworks addon installation
- Creative mode vehicle spawning
- Basic Tacview operation

## Installation

### 1. Addon Installation

```bash
# Copy script.lua to your Stormworks addon directory
# Typically: %APPDATA%/Stormworks/data/missions/[mission-name]/
cp script.lua /path/to/stormworks/missions/tacview-integration/
```

### 2. Bridge Server Setup

Ensure bridge server is running and accessible:

```bash
# Test bridge server connectivity
curl http://localhost:3000/acmi/dGVzdA==
# Should return 200 OK or acknowledgment
```

### 3. Tacview Configuration

- Launch Tacview
- Configure to receive data from bridge server
- Set appropriate data source settings

## Quick Test

### Basic Functionality Test (5 minutes)

1. **Start Stormworks**

   - Load the addon-enabled mission
   - Enter Creative Mode

2. **Spawn Test Vehicle**

   ```
   1. Open vehicle spawner
   2. Select any vehicle
   3. Spawn in world
   4. Vehicle should appear in Tacview within 0.1 seconds
   ```

3. **Verify Position Updates**

   ```
   1. Move vehicle in Stormworks
   2. Observe position updates in Tacview
   3. Updates should occur every 0.1 seconds
   ```

4. **Test Vehicle Removal**
   ```
   1. Despawn vehicle in Stormworks
   2. Vehicle should disappear from Tacview within 0.1 seconds
   ```

### Expected Results

✅ Vehicle appears in Tacview with metadata:

- Name: "F-16C"
- Type: "Air+FixedWing"
- Color: "Blue"

✅ Position updates smoothly in real-time
✅ Vehicle removes cleanly when despawned

## Troubleshooting

### Vehicle Not Appearing in Tacview

**Symptoms**: Vehicle spawns in Stormworks but not visible in Tacview

**Possible Causes**:

1. Bridge server not running
2. Tacview not configured correctly
3. Network connectivity issues

**Solutions**:

```bash
# Check bridge server status
curl http://localhost:3000/health

# Verify Stormworks addon console for errors
# Check Tacview data source configuration
# Restart bridge server if needed
```

### Position Updates Not Working

**Symptoms**: Vehicle appears but doesn't move in Tacview

**Possible Causes**:

1. Coordinate conversion issues
2. ACMI format problems
3. Update timing problems

**Solutions**:

1. Verify vehicle is actually moving in Stormworks
2. Check bridge server logs for ACMI parsing errors
3. Restart addon (reload mission)

### Performance Issues

**Symptoms**: Game lag or stuttering with addon enabled

**Possible Causes**:

1. Too many vehicles tracked simultaneously
2. Network request bottleneck
3. Tick budget exceeded

**Solutions**:

1. Limit simultaneous vehicles to <20
2. Check network latency to localhost
3. Monitor Stormworks performance metrics

## Advanced Testing

### Multi-Vehicle Scenario (10 minutes)

1. **Spawn Multiple Vehicles**

   ```
   1. Spawn 5-10 vehicles simultaneously
   2. Verify all appear in Tacview
   3. Move vehicles independently
   4. Confirm independent tracking
   ```

2. **Stress Test**
   ```
   1. Spawn maximum vehicles (20+)
   2. Monitor performance impact
   3. Verify continued operation
   4. Test despawn cleanup
   ```

### Network Resilience Test (15 minutes)

1. **Bridge Server Interruption**

   ```
   1. Stop bridge server while addon running
   2. Verify Stormworks continues normally
   3. Restart bridge server
   4. Verify reconnection works
   ```

2. **Addon Reload Test**
   ```
   1. Reload mission with vehicles spawned
   2. Verify clean restart
   3. Confirm tracking resumes for new spawns
   ```

## Performance Benchmarks

### Normal Operation

- **Update Frequency**: 10 Hz (every 0.1 seconds)
- **Vehicle Limit**: 50 vehicles maximum
- **Memory Usage**: <1MB additional
- **Performance Impact**: <5% tick budget

### Success Criteria Validation

| Criteria                          | Test Method         | Expected Result        |
| --------------------------------- | ------------------- | ---------------------- |
| SC-001: 0.1s update latency       | Manual timing       | ✅ Within tolerance    |
| SC-002: 50 vehicle capacity       | Spawn test          | ✅ No degradation      |
| SC-003: 1 tick spawn detection    | Immediate spawn     | ✅ Instant detection   |
| SC-004: 0.1s despawn cleanup      | Despawn timing      | ✅ Clean removal       |
| SC-005: 95% network success       | Extended testing    | ✅ High reliability    |
| SC-006: 0.1% coordinate precision | Position comparison | ✅ Accurate conversion |
| SC-007: 60+ minute operation      | Long-term test      | ✅ Stable operation    |

## Next Steps

After successful quickstart testing:

1. **Production Usage**: Deploy in actual missions/scenarios
2. **Integration Testing**: Test with specific Tacview workflows
3. **Performance Optimization**: Fine-tune for specific vehicle counts
4. **Advanced Features**: Consider future enhancements based on usage

## Support

### Common Issues

- Check bridge server logs for detailed error information
- Verify Stormworks console for addon-specific messages
- Ensure Tacview is properly configured for data reception

### Debug Information

The addon maintains internal statistics accessible through:

- Total vehicles tracked
- Total updates sent
- Last error encountered (if any)

This information can help diagnose integration issues.
