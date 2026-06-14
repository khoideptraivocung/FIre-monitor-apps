import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_event.dart';

class TimelineCard extends StatelessWidget {
  final LogEvent event;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.event,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData icon;

    switch (event.eventType) {
      case 'Fire Risk Detected':
      case 'Flame Detected':
        statusColor = const Color(0xFFF44336); // Danger red
        icon = Icons.local_fire_department_rounded;
        break;
      case 'Gas Warning':
        statusColor = const Color(0xFFFF9800); // Warning orange
        icon = Icons.warning_amber_rounded;
        break;
      case 'Fan Turned On':
        statusColor = const Color(0xFF4CAF50); // Success green
        icon = Icons.wind_power_rounded;
        break;
      case 'Fan Turned Off':
        statusColor = Colors.grey;
        icon = Icons.power_settings_new_rounded;
        break;
      default:
        statusColor = Colors.blue;
        icon = Icons.info_outline_rounded;
        break;
    }

    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(event.dateTime);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline Node Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Connecting line to previous node
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey.withAlpha(80),
                  ),
                ),
                // Color-coded event category dot
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: statusColor,
                  ),
                ),
                // Connecting line to next node
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey.withAlpha(80),
                  ),
                ),
              ],
            ),
          ),
          // Detail card container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event.eventType,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
