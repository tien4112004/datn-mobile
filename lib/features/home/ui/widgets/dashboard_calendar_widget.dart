import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/home/data/models/calendar_event_model.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Material 3 Calendar Widget with Syncfusion Calendar
class DashboardCalendarWidget extends ConsumerStatefulWidget {
  final List<CalendarEventModel> events;
  final Function(CalendarEventModel)? onEventTap;

  const DashboardCalendarWidget({
    super.key,
    required this.events,
    this.onEventTap,
  });

  @override
  ConsumerState<DashboardCalendarWidget> createState() =>
      _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState
    extends ConsumerState<DashboardCalendarWidget> {
  DateTime? _selectedDate;
  List<CalendarEventModel> _selectedDateEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _onDateTapped(_selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dataSource = _CalendarDataSource(widget.events, colorScheme);
    final t = ref.read(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(LucideIcons.calendar, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              t.home.dashboard.calendar.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // Calendar View
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: Themes.boxRadius,
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: Themes.boxRadius,
                child: SfCalendar(
                  view: CalendarView.month,
                  cellBorderColor: Colors.transparent,
                  dataSource: dataSource,
                  firstDayOfWeek: 1, // Monday
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                    showAgenda: false,
                    monthCellStyle: MonthCellStyle(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      trailingDatesTextStyle: TextStyle(
                        fontSize: 14,
                        color: colorScheme.outline.withValues(alpha: 0.4),
                      ),
                      leadingDatesTextStyle: TextStyle(
                        fontSize: 14,
                        color: colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  headerStyle: const CalendarHeaderStyle(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    backgroundColor: Colors.transparent,
                  ),
                  todayHighlightColor: colorScheme.primary.withValues(
                    alpha: 0.8,
                  ),
                  selectionDecoration: BoxDecoration(
                    border: Border.all(color: colorScheme.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                  onTap: (CalendarTapDetails details) {
                    if (details.targetElement == CalendarElement.calendarCell) {
                      _onDateTapped(details.date!);
                    } else if (details.targetElement ==
                        CalendarElement.appointment) {
                      if (details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        final event =
                            details.appointments!.first as Appointment;
                        final originalEvent = widget.events.firstWhere(
                          (e) => e.id == event.id,
                        );
                        widget.onEventTap?.call(originalEvent);
                      }
                    }
                  },
                ),
              ),

              // Selected Date Events
              if (_selectedDate != null && _selectedDateEvents.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(
                    builder: (context, ref, child) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatHelper.formatMediumDate(
                            _selectedDate!,
                            ref: ref,
                          ),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ..._selectedDateEvents.map(
                          (event) => _CompactEventTile(
                            event: event,
                            onTap: () => widget.onEventTap?.call(event),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedDateEvents = widget.events.where((event) {
        final eventDate = event.date.toLocal();
        return eventDate.year == date.year &&
            eventDate.month == date.month &&
            eventDate.day == date.day;
      }).toList();
    });
  }
}

/// Custom Data Source for Syncfusion Calendar
class _CalendarDataSource extends CalendarDataSource {
  final ColorScheme colorScheme;

  _CalendarDataSource(List<CalendarEventModel> events, this.colorScheme) {
    appointments = events.map((event) {
      return Appointment(
        id: event.id,
        startTime: event.date.toLocal(),
        endTime: event.date.toLocal().add(const Duration(hours: 1)),
        subject: event.title,
        color: _getEventColor(event.status, event.type),
        notes: event.description,
      );
    }).toList();
  }

  Color _getEventColor(CalendarEventStatus? status, CalendarEventType type) {
    switch (status) {
      case CalendarEventStatus.overdue:
        return Colors.red;
      case CalendarEventStatus.dueSoon:
        return Colors.orange;
      case CalendarEventStatus.completed:
        return Colors.green;
      case CalendarEventStatus.submitted:
        return Colors.blue;
      default:
        return _getTypeColor(type);
    }
  }

  Color _getTypeColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.deadline:
        return colorScheme.error;
      case CalendarEventType.gradingReminder:
        return Colors.orange;
      case CalendarEventType.scheduledPost:
        return colorScheme.primary;
      case CalendarEventType.assignmentReturned:
        return Colors.green;
    }
  }
}

/// Compact Event Tile for Selected Date
class _CompactEventTile extends StatelessWidget {
  final CalendarEventModel event;
  final VoidCallback? onTap;

  const _CompactEventTile({required this.event, this.onTap});

  IconData _getTypeIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.deadline:
        return LucideIcons.clock;
      case CalendarEventType.gradingReminder:
        return LucideIcons.clipboardCheck;
      case CalendarEventType.scheduledPost:
        return LucideIcons.calendar;
      case CalendarEventType.assignmentReturned:
        return LucideIcons.circleCheck;
    }
  }

  Color _getStatusColor(BuildContext context, CalendarEventStatus? status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case CalendarEventStatus.overdue:
        return colorScheme.error;
      case CalendarEventStatus.dueSoon:
        return Colors.orange;
      case CalendarEventStatus.completed:
        return Colors.green;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context, event.status);
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(_getTypeIcon(event.type), color: statusColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.className,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  timeFormat.format(event.date),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading state for calendar widget
class DashboardCalendarShimmer extends StatelessWidget {
  const DashboardCalendarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: Themes.boxRadius,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Calendar shimmer
          Container(
            height: 380,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: Themes.boxRadius,
              border: Border.all(color: colorScheme.outlineVariant, width: 1),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                children: [
                  // Month header
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Week days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      7,
                      (index) => Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Calendar grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(
                        35,
                        (index) => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
