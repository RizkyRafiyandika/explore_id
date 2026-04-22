import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/models/event.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:explore_id/widget/calendar_event_bottom_sheet.dart';
import 'package:explore_id/services/event_Service.dart';

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});

  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _eventsByDay = {};
  late AnimationController _fadeController;
  late AnimationController _slideController;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _setupEventStream();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupEventStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    _eventsSubscription = FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            final List<Event> events =
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  final startDate = (data['date'] as Timestamp).toDate();
                  final endDate =
                      data['endDate'] != null
                          ? (data['endDate'] as Timestamp).toDate()
                          : startDate; // Fallback if endDate doesn't exist yet

                  return Event(
                    id: data['id'],
                    title: data['title'],
                    desk: data['desk'],
                    date: startDate,
                    endDate: endDate,
                    start: data['start'],
                    end: data['end'],
                    place: data['place'],
                    label: data['label'],
                    docId: doc.id,
                    isCheck: data["isCheck"] is bool ? data["isCheck"] : false,
                  );
                }).toList();

            if (mounted) {
              setState(() {
                _eventsByDay = groupEventsByDate(events);
              });
              _slideController.forward();
            }
          },
          onError: (e) {
            print("Error fetching events: $e");
          },
        );
  }

  Map<DateTime, List<Event>> groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> data = {};

    for (var event in events) {
      // For multi-day support, we add the event to every day within its range
      DateTime current = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      final endDate = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
      );

      while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
        if (data[current] == null) {
          data[current] = [];
        }
        data[current]!.add(event);

        // Next day
        current = current.add(const Duration(days: 1));
      }
    }

    return data;
  }

  List<Event> getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _eventsByDay[date] ?? [];
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return const Color(0xFF6366F1);
      case 'personal':
        return const Color(0xFF10B981);
      case 'travel':
        return const Color(0xFFF59E0B);
      case 'health':
        return const Color(0xFFEF4444);
      default:
        return tdcyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeController,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildCalendarCard()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildEventsSection()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Calendar",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            "${_getMonthName(_focusedDay.month)} ${_focusedDay.year}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.today, color: tdcyan, size: 22),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: _calendarFormat,
          eventLoader: getEventsForDay,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
              );
              _focusedDay = focusedDay;
            });
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            formatButtonTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tdcyan,
            ),
            formatButtonDecoration: BoxDecoration(
              color: tdcyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: Color(0xFF64748B),
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: Color(0xFF64748B),
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            weekendStyle: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: const TextStyle(color: Color(0xFF1E293B)),
            holidayTextStyle: const TextStyle(color: Color(0xFF1E293B)),
            defaultTextStyle: const TextStyle(color: Color(0xFF1E293B)),
            todayDecoration: BoxDecoration(
              color: tdcyan.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: tdcyan, width: 2),
            ),
            selectedDecoration: const BoxDecoration(
              color: tdcyan,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            canMarkersOverflow: false,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getLabelColor((events.first as Event).label),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final eventsForDay = getEventsForDay(_selectedDay);
    final completedEvents = eventsForDay.where((e) => e.isCheck).length;
    final totalEvents = eventsForDay.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(totalEvents, completedEvents),
          const SizedBox(height: 16),
          eventsForDay.isNotEmpty
              ? _buildEventsList(eventsForDay)
              : _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int total, int completed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tdcyan.withOpacity(0.1), tdcyan.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tdcyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tdcyan,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_note, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_getDayName(_selectedDay.weekday)} Events",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  total > 0
                      ? "$completed of $total completed"
                      : "No events today",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (total > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: completed == total ? const Color(0xFF10B981) : tdcyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${((completed / total) * 100).round()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          return _buildEventCard(event, index);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Slidable(
              key: ValueKey(event.id),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.5,
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      event.isCheck = !event.isCheck;
                      if (event.docId != null) {
                        try {
                          await updateEvent(event);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(event.isCheck ? "Event marked as done" : "Event marked as undo"),
                                backgroundColor: event.isCheck ? Colors.green : Colors.blueGrey,
                              ),
                            );
                          }
                        } catch (e) {
                          // Revert UI state on error
                          setState(() {
                            event.isCheck = !event.isCheck;
                          });
                        }
                      }
                    },
                    backgroundColor:
                        event.isCheck
                            ? const Color(0xFF64748B)
                            : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    icon: event.isCheck ? Icons.undo : Icons.check_circle,
                    label: event.isCheck ? 'Undo' : 'Done',
                    borderRadius: BorderRadius.circular(20),
                  ),
                  SlidableAction(
                    onPressed: (context) async {
                      if (event.docId != null) {
                        try {
                          await deleteEvent(event.docId!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Event deleted successfully"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to delete: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: _getLabelColor(event.label),
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () => showCalendarEventBottomSheet(context, event),
                      contentPadding: const EdgeInsets.all(20),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getLabelColor(event.label).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getEventIcon(event.label),
                          color: _getLabelColor(event.label),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        event.place,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              event.isCheck
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF1E293B),
                          decoration:
                              event.isCheck ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  event.isCheck
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              decoration:
                                  event.isCheck
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${event.start} - ${event.end}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (event.desk.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.desk,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLabelColor(
                                event.label,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getLabelColor(event.label),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _navigateToLocation(event),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: tdcyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: tdcyan,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.event_busy,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No events today",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enjoy your free day!",
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLocation(Event event) {
    final List<ListTrip> listTrips =
        Provider.of<MytripProvider>(context, listen: false).allTrip;

    final matchingTrips =
        listTrips.where((trip) => trip.id == event.id).toList();

    if (matchingTrips.isNotEmpty) {
      final trip = matchingTrips.first;
      globalDestination = LatLng(trip.latitude, trip.longitude);
      globalTripEvent = {
        'id': event.id,
        'title': event.title,
        'desk': event.desk,
        'date': event.date,
        'endDate': event.endDate,
        'start': event.start,
        'end': event.end,
        'place': event.place,
        'label': event.label,
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavBar(selectedIndex: 1)),
      );
    }
  }

  IconData _getEventIcon(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'travel':
        return Icons.flight;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.event;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}
