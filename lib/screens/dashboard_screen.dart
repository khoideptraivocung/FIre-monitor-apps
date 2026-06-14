import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_banner.dart';
import '../widgets/skeleton_loader.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monitoring = Provider.of<MonitoringProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Dashboard'),
      ),
      body: monitoring.isLoading
          ? const SkeletonLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall state indicator
                  _buildSystemStatusBanner(monitoring),
                  const SizedBox(height: 24),
                  // Sensors Section header
                  Text(
                    'Environment Sensors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Responsively grid individual indicators
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.12,
                    children: _buildSensorCards(context, monitoring),
                  ),
                ],
              ),
            ),
    );
  }

  /// Evaluates fire data states to configure the hero status banner parameters
  Widget _buildSystemStatusBanner(MonitoringProvider provider) {
    final data = provider.fireData;
    if (data == null) {
      return const StatusBanner(
        status: 'SAFE',
        title: 'Connecting...',
        message: 'Establishing communication channels with Firebase...',
      );
    }

    if (data.fireRisk || data.flameDetected) {
      return const StatusBanner(
        status: 'DANGER',
        title: 'Fire Risk Detected',
        message: 'Critical safety breach! Active flames or dangerous conditions detected.',
      );
    } else if (data.gasStatus == 'WARNING' || data.gasStatus == 'DANGER') {
      return StatusBanner(
        status: 'WARNING',
        title: 'Warning Detected',
        message: 'Elevated MQ135 sensor gas density (${data.gasADC} ADC). Clear the area.',
      );
    } else {
      return const StatusBanner(
        status: 'SAFE',
        title: 'System Safe',
        message: 'All sensor nodes report normal safety metrics.',
      );
    }
  }

  /// Maps live database properties to color schemes and icons for individual cards
  List<Widget> _buildSensorCards(BuildContext context, MonitoringProvider provider) {
    final data = provider.fireData;
    if (data == null) return [];

    // Safety color palette matcher
    Color getStatusColor(String status) {
      switch (status) {
        case 'DANGER':
          return const Color(0xFFF44336); // Red
        case 'WARNING':
          return const Color(0xFFFF9800); // Orange
        case 'SAFE':
        default:
          return const Color(0xFF4CAF50); // Green
      }
    }

    // Custom check for temperature limits
    String tempStatus = 'SAFE';
    Color tempColor = const Color(0xFF4CAF50);
    if (data.temperature >= 50) {
      tempStatus = 'DANGER';
      tempColor = const Color(0xFFF44336);
    } else if (data.temperature >= 38) {
      tempStatus = 'WARNING';
      tempColor = const Color(0xFFFF9800);
    }

    return [
      SensorCard(
        title: 'Temperature',
        value: data.temperature.toStringAsFixed(1),
        unit: '°C',
        icon: Icons.thermostat_rounded,
        iconColor: Colors.redAccent,
        status: tempStatus,
        statusColor: tempColor,
      ),
      SensorCard(
        title: 'Humidity',
        value: data.humidity.toStringAsFixed(0),
        unit: '%',
        icon: Icons.water_drop_rounded,
        iconColor: Colors.blueAccent,
        status: 'SAFE',
        statusColor: const Color(0xFF4CAF50),
      ),
      SensorCard(
        title: 'Gas Status',
        value: data.gasADC.toString(),
        unit: 'ADC',
        icon: Icons.air_rounded,
        iconColor: Colors.blueGrey,
        status: data.gasStatus,
        statusColor: getStatusColor(data.gasStatus),
      ),
      SensorCard(
        title: 'Flame Detection',
        value: data.flameDetected ? 'Detected' : 'No Flame',
        unit: '',
        icon: Icons.local_fire_department_rounded,
        iconColor: Colors.deepOrangeAccent,
        status: data.flameDetected ? 'DANGER' : 'SAFE',
        statusColor: data.flameDetected ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
      ),
      SensorCard(
        title: 'Fire Risk',
        value: data.fireRisk ? 'Critical' : 'Safe',
        unit: '',
        icon: Icons.health_and_safety_rounded,
        iconColor: Colors.green,
        status: data.fireRisk ? 'DANGER' : 'SAFE',
        statusColor: data.fireRisk ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
      ),
      SensorCard(
        title: 'Fan Status',
        value: data.fanStatus ? 'ON' : 'OFF',
        unit: '',
        icon: Icons.toys_rounded,
        iconColor: Colors.indigoAccent,
        status: data.fanStatus ? 'RUNNING' : 'STOPPED',
        statusColor: data.fanStatus ? const Color(0xFF4CAF50) : Colors.grey,
      ),
    ];
  }
}
