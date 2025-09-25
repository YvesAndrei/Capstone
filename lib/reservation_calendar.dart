import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../config/api.dart';

class ReservationCalendar extends StatefulWidget {
  const ReservationCalendar({super.key});

  @override
  _ReservationCalendarState createState() => _ReservationCalendarState();
}

class _ReservationCalendarState extends State<ReservationCalendar> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _events = {};
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse(ApiConfig.calendarReservations);
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["success"] == true && data["data"] is Map) {
        Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};

        (data["data"] as Map<String, dynamic>).forEach((dateStr, reservations) {
          DateTime date = DateTime.parse(dateStr);
          // normalize date to remove time
          date = DateTime(date.year, date.month, date.day);
          if (reservations is List) {
            fetchedEvents[date] = reservations.cast<Map<String, dynamic>>();
          }
        });

        setState(() {
          _events = fetchedEvents;
          isLoading = false;
        });
      } else {
        throw Exception("Invalid data format from API");
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case "day_tour":
        return Colors.blue;
      case "overnight":
        return Colors.green;
      case "whole_day":
        return Colors.red;
      case "events":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.black), // 👈 black for white bg
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      mainAxisSize: MainAxisSize.min, // 👈 avoid infinite height
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (_) => [], // disable default markers
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final events = _getEventsForDay(day);
              if (events.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}'),
                      Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: events.map((res) {
                          return Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorForType(
                                  res["reservation_type"] ?? "unknown"),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
              return null;
            },
            markerBuilder: (context, date, events) => null, // no black dots
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(Colors.blue, "Day Tour"),
            _buildLegendItem(Colors.green, "Overnight"),
            _buildLegendItem(Colors.red, "Whole Day"),
            _buildLegendItem(Colors.purple, "Events"),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null)
          Flexible(
            fit: FlexFit.loose, // 👈 fixes unbounded height issue
            child: ListView(
              shrinkWrap: true, // 👈 let list size itself
              children: _getEventsForDay(_selectedDay!).map((res) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _getColorForType(res["reservation_type"] ?? "unknown"),
                  ),
                  title: Text("Type: ${res["reservation_type"] ?? "Unknown"}"),
                  subtitle: Text("Status: ${res["status"] ?? "N/A"}"),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
