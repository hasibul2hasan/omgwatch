import 'dart:async';
import 'package:flutter/material.dart';

class SavedTime {
  final String stopwatchTime;
  final String realTimeDate;
  String property;
//Hhahahahah
  //Reallyk
  SavedTime(
      {required this.stopwatchTime,
      required this.realTimeDate,
      this.property = ''});
}

void main() {
  runApp(StopwatchApp());
}

class StopwatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OMGSTOPS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StopwatchHomePage(),
    );
  }
}

class StopwatchHomePage extends StatefulWidget {
  @override
  _StopwatchHomePageState createState() => _StopwatchHomePageState();
}

class _StopwatchHomePageState extends State<StopwatchHomePage> {
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  late Timer _timer;
  List<SavedTime> _savedTimes = [];
  List<SavedTime> _filteredTimes = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onTick(Timer timer) {
    if (_isRunning) {
      setState(() {
        _elapsedTime += Duration(seconds: 1);
      });
    }
  }

  void _startStopwatch() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
    }
  }

  void _stopStopwatch() {
    if (_isRunning) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetStopwatch() {
    setState(() {
      _elapsedTime = Duration.zero;
      _isRunning = false;
    });
  }

  void _saveTime() {
    if (_elapsedTime != Duration.zero) {
      String formattedTime = _formatTime(_elapsedTime);
      String currentTime = _getCurrentTime();
      setState(() {
        _savedTimes.add(SavedTime(
            stopwatchTime: formattedTime,
            realTimeDate: currentTime,
            property: ''));
        _filteredTimes =
            List.from(_savedTimes); // Ensure filtered list stays in sync
        _stopStopwatch(); // Stop the stopwatch
        _elapsedTime = Duration.zero; // Reset the stopwatch time
      });
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String hours = twoDigits(duration.inHours.remainder(60));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _getCurrentTime() {
    DateTime now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  void _saveTimeWithProperty(String property) {
    if (_elapsedTime != Duration.zero) {
      String formattedTime = _formatTime(_elapsedTime);
      String currentTime = _getCurrentTime();
      setState(() {
        _savedTimes.add(SavedTime(
            stopwatchTime: formattedTime,
            realTimeDate: currentTime,
            property: property));
        _filteredTimes =
            List.from(_savedTimes); // Ensure filtered list stays in sync
        _stopStopwatch(); // Stop the stopwatch
        _elapsedTime = Duration.zero; // Reset the stopwatch time
      });
    }
  }

  void _filterList(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredTimes = _savedTimes
            .where((time) =>
                time.stopwatchTime
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                time.realTimeDate.toLowerCase().contains(query.toLowerCase()) ||
                time.property.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredTimes = List.from(_savedTimes);
      }
    });
  }

  void _editTimeProperty(int index) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController propertyController =
            TextEditingController(text: _filteredTimes[index].property);
        return AlertDialog(
          title: Text('Edit Property'),
          content: TextField(
            controller: propertyController,
            decoration: InputDecoration(
              labelText: 'Property:',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filteredTimes[index].property = propertyController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _deleteTime(int index) async {
    bool confirmDelete = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Time'),
          content: Text('Are you sure you want to delete this time?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                confirmDelete = false;
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                confirmDelete = true;
                setState(() {
                  _savedTimes.remove(_filteredTimes[index]);
                  _filteredTimes.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    return confirmDelete;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showSearch(
              context: context, delegate: Search(_savedTimes, _filterList));
        },
        child: Icon(Icons.search),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 110.0),
                Text(
                  _formatTime(_elapsedTime),
                  style: TextStyle(fontSize: 60.0),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
                      child: Text(_isRunning ? 'Stop' : 'Start'),
                    ),
                    SizedBox(width: 20.0),
                    ElevatedButton(
                      onPressed: _resetStopwatch,
                      child: Text('Reset'),
                    ),
                    SizedBox(width: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController propertyController =
                                TextEditingController();
                            return AlertDialog(
                              title: Text('Save Time'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: propertyController,
                                    decoration: InputDecoration(
                                      labelText: 'Property (optional):',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Stopwatch Time:',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: TextEditingController()
                                      ..text = _formatTime(_elapsedTime),
                                  ),
                                  SizedBox(height: 10),
                                  TextField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Real Time Date:',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: TextEditingController()
                                      ..text = _getCurrentTime(),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _saveTimeWithProperty(
                                        propertyController.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Save Time'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text('Your saved times bellow'),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTimes.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_filteredTimes[index].stopwatchTime),
                  background: Container(
                    color: Colors.green,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editTimeProperty(index);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      return await _deleteTime(index);
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text('Time: ${_filteredTimes[index].stopwatchTime}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_filteredTimes[index].realTimeDate}'),
                        Text('${_filteredTimes[index].property}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: Text('OMGWATCH'),
          ),
        ],
      ),
    );
  }
}

class Search extends SearchDelegate<String> {
  final List<SavedTime> savedTimes;
  final Function(String) filterList;

  Search(this.savedTimes, this.filterList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          filterList(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    filterList(query);
    return Container(); // No need to display results as they are already filtered in the main widget
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : savedTimes
            .where((time) =>
                time.stopwatchTime
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                time.realTimeDate.toLowerCase().contains(query.toLowerCase()) ||
                time.property.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].stopwatchTime),
          subtitle: Text(suggestionList[index].realTimeDate),
          onTap: () {
            // You can add navigation or other actions here if needed
          },
        );
      },
    );
  }
}
