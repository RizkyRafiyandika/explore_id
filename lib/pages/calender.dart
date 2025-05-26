import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/components/global.dart';
import 'package:explore_id/models/event.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/widget/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
              id: data['id'], // id untuk trip
              title: data['title'],
              desk: data['desk'],
              date: (data['date'] as Timestamp).toDate(),
              start: data['start'],
              end: data['end'],
              place: data['place'],
              label: data['label'],
              docId: doc.id,
              isCheck:
                  data["isCheck"] is bool
                      ? data["isCheck"]
                      : false, // Add docId from Firestore document ID
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
            _MyCalender(context),
            // Menampilkan event berdasarkan tanggal yang dipilih
            _PlanToday(),
          ],
        ),
      ),
    );
  }

  Container _MyCalender(BuildContext context) {
    return Container(
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
    );
  }

  Container _PlanToday() {
    return Container(
      margin: const EdgeInsets.only(bottom: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 100,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            getEventsForDay(_selectedDay).isNotEmpty
                ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: getEventsForDay(_selectedDay).length,
                  itemBuilder: (context, index) {
                    final event = getEventsForDay(_selectedDay)[index];

                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Slidable(
                        key: ValueKey(event.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) async {
                                setState(() {
                                  event.isCheck = !event.isCheck;
                                });
                                print("DocID ${event.docId}");
                                if (event.docId != null) {
                                  await FirebaseFirestore.instance
                                      .collection("events")
                                      .doc(event.docId)
                                      .update({"isCheck": true});
                                  await fetchEvents();
                                } else {
                                  print(
                                    "❌ docId kosong! Tidak bisa update event.",
                                  );
                                }
                              },

                              backgroundColor:
                                  event.isCheck ? Colors.grey : tdcyan,
                              foregroundColor: Colors.white,
                              icon:
                                  event.isCheck
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline_outlined,
                              label: 'Check',
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  event.isCheck
                                      ? Colors.grey.withOpacity(0.5)
                                      : Colors.grey.withOpacity(0.1),
                            ),

                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.8),
                            //     blurRadius: 10,
                            //     offset: Offset(0, 2),
                            //   ),
                            // ],
                            // ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${event.place} - ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        decoration:
                                            event.isCheck
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        decorationThickness:
                                            event.isCheck ? 2.5 : null,
                                      ),
                                    ),
                                    TextSpan(
                                      text: event.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87.withOpacity(0.4),
                                        fontWeight: FontWeight.w400,
                                        decoration:
                                            event.isCheck
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        decorationThickness:
                                            event.isCheck ? 2.5 : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  "${event.start} - ${event.end}\n${event.desk}",
                                  style: const TextStyle(height: 1.4),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      final matchingTrips =
                                          ListTrips.where(
                                            (trip) => trip.id == event.id,
                                          ).toList();

                                      if (matchingTrips.isNotEmpty) {
                                        final trip = matchingTrips.first;
                                        globalDestination = LatLng(
                                          trip.latitude,
                                          trip.longitude,
                                        );
                                        globalTripEvent = {
                                          'id': event.id,
                                          'title': event.title,
                                          'desk': event.desk,
                                          'date': event.date,
                                          'start': event.start,
                                          'end': event.end,
                                          'place': event.place,
                                          'label': event.label,
                                        };

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => NavBar(selectedIndex: 1),
                                          ),
                                        );
                                      } else {
                                        print(
                                          "❌ Tidak ada trip dengan ID ${event.id}",
                                        );
                                      }
                                    },
                                    child: const Icon(
                                      Icons.location_searching_outlined,
                                      color: tdcyan,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: tdcyan,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Swipe",
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.black.withOpacity(0.4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
                : const Center(
                  child: Text(
                    "Tidak ada acara pada hari ini.",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
      ),
    );
  }
}
