import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:flutter_auth/Screens/Home/notification_helper.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Store events in a Map<DateTime, List<String>>
  Map<DateTime, List<String>> events = {};

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFB793DA);
    final Color accentColor = const Color(0xFF8A56AC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Appointments"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add uniform spacing
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1) Calendar Box with Decorations
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2050),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) => events[day] ?? [],
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showHourlySlots(context, selectedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: accentColor.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      formatButtonTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // 2.1) Lottie Animation - Positioned at Top Left
            Positioned(
              left: -10,
              top: -10,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/animations/search_doc.json'),
              ),
            ),

            // 2.2) Lottie Animation - Positioned at Top right
            Positioned(
              right: -10,
              top: -10,
              child: SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset('assets/animations/time.json'),
              ),
            ),

            // 3) Lottie Animation - Positioned at Bottom Right
            Positioned(
              right: -10,
              bottom: -10,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset('assets/animations/extralottiefile.json'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Hourly Time Slots with Event Input
  void _showHourlySlots(BuildContext context, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 3,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Available Slots on ${DateFormat('EEE, MMM d').format(selectedDate)}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),

              // Hourly Slots
              Expanded(
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (ctx, index) {
                    final eventTime = DateTime(selectedDate.year,
                        selectedDate.month, selectedDate.day, index);
                    return ListTile(
                      title: Text(
                        DateFormat.jm().format(eventTime),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: events[eventTime] != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: events[eventTime]!
                                  .map((e) => Text(
                                        "• $e",
                                        style: const TextStyle(
                                            color: Colors
                                                .deepPurple, // Highlighted tasks
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ))
                                  .toList(),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.purple),
                        onPressed: () {
                          _showAddEventDialog(context, eventTime);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dialog to Add Event with Text
  void _showAddEventDialog(BuildContext context, DateTime eventTime) {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Appointment at ${DateFormat.jm().format(eventTime)}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: eventController,
          decoration:
              const InputDecoration(hintText: "Enter appointment details"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                _addEvent(eventTime, eventController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// Add an Event & Schedule a Notification
  void _addEvent(DateTime eventTime, String title) {
    setState(() {
      events[eventTime] = (events[eventTime] ?? [])..add(title);
    });

    // Schedule Notification 15 min before
    NotificationHelper.scheduleNotification(eventTime, title);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Appointment added: $title at ${DateFormat.jm().format(eventTime)}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
