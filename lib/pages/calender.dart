import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyCalendar extends StatefulWidget {
  @override
  _MyCalendarState createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: userId)
              .get();

      final List<Event> events =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Event(
              title: data['title'],
              desk: data['desk'],
              date: (data['date'] as Timestamp).toDate(),
              start: data['start'],
              end: data['end'],
              place: data['place'],
              label: data['label'], 
            );
          }).toList();

      setState(() {
        _eventsByDay = groupEventsByDate(events);
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Map<DateTime, List<Event>> groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> data = {};

    for (var event in events) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(event);
    }

    return data;
  }

  List<Event> getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _eventsByDay[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Kalender
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
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
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),

            // Menampilkan event berdasarkan tanggal yang dipilih
            Padding(
              padding: EdgeInsets.all(16),
              child:
                  getEventsForDay(_selectedDay).isNotEmpty
                      ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: getEventsForDay(_selectedDay).length,
                        itemBuilder: (context, index) {
                          final event = getEventsForDay(_selectedDay)[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${event.place} - ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: event.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87.withOpacity(0.4),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              subtitle: Text(
                                "${event.start} - ${event.end}\n${event.desk}",
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      )
                      : Center(
                        child: Text(
                          "Tidak ada acara pada hari ini.",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
