import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/control_provider.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Micro-animation rotation controller for exhaust fan feedback
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = Provider.of<ControlProvider>(context);

    if (control.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exhaust Control')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final controlData = control.controlData;
    if (controlData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exhaust Control')),
        body: const Center(
          child: Text('Unable to connect to controls.'),
        ),
      );
    }

    final isAuto = controlData.isAuto;
    final isFanOn = controlData.fan;

    // Toggle rotation animation loop based on fan status
    if (isFanOn) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Select Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings_suggest_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Operation Mode',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Material 3 Segmented Button
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'AUTO',
                            label: Text('AUTO'),
                            icon: Icon(Icons.autorenew_rounded),
                          ),
                          ButtonSegment<String>(
                            value: 'MANUAL',
                            label: Text('MANUAL'),
                            icon: Icon(Icons.touch_app_rounded),
                          ),
                        ],
                        selected: {controlData.mode},
                        onSelectionChanged: (newSelection) {
                          control.setMode(newSelection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAuto
                          ? 'In AUTO mode, the fan is managed automatically by the ESP8266 controller based on sensor safety limits.'
                          : 'In MANUAL mode, automatic fan speed configurations are disabled. You can control the ventilation status directly using the switch below.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Fan Control Toggle Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Spinning micro-animated icon feedback
                            AnimatedBuilder(
                              animation: _rotationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationController.value * 2 * math.pi,
                                  child: Icon(
                                    Icons.cyclone_rounded,
                                    size: 34,
                                    color: isFanOn ? Colors.indigoAccent : Colors.grey,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Exhaust Fan',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFanOn ? 'Ventilation Active' : 'Ventilation Idle',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: isFanOn,
                          onChanged: isAuto
                              ? null // Lock switches if AUTO mode handles it
                              : (value) {
                                  control.setFan(value);
                                },
                        ),
                      ],
                    ),
                    if (isAuto) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Manual toggle is disabled under AUTO mode. Change operation mode to MANUAL to override fan state.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
