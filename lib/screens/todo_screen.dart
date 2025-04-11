import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../block/toodo_block.dart' as block;

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Work';
  DateTime? _selectedDate; // Variable to store the selected date
  DateTime _focusedDay = DateTime.now(); // Current focused day for the calendar
  CalendarFormat _calendarFormat = CalendarFormat.month; // Calendar format

  // Function to go to the current date
  void _goToCurrentDate() {
    setState(() {
      _focusedDay = DateTime.now(); // Set focused day to current date
      _selectedDate = DateTime.now(); // Optionally set selected date to current date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color for the entire screen
      body: Center(
        child: Container(
          width: 600, // Set a fixed width for the terminal-like container
          height: 800, // Set a fixed height for the terminal-like container
          decoration: BoxDecoration(
            color: Colors.black, // Background color for the terminal
            border: Border.all(color: Colors.grey, width: 2), // Terminal border
            borderRadius: BorderRadius.circular(0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.5), // Shadow color
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3), // Changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              // Calendar widget
              TableCalendar(
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay; // Store the selected date
                    _focusedDay = focusedDay; // Update the focused day
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                calendarFormat: _calendarFormat,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.green, // Highlight color for selected date
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow[700], // Highlight color for today's date
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Colors.grey[700], // Default date color
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Colors.grey[100], // Weekend date color
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              // Button to go to current date
              ElevatedButton(
                onPressed: _goToCurrentDate,
                child: Text('Go to Current Date', style: TextStyle(fontFamily: 'monospace')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Sharp corners
                  ),
                ),
              ),
              // Terminal-like input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      '> ', // Terminal prompt
                      style: TextStyle(color: Colors.green, fontFamily: 'monospace'),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter task...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        onSubmitted: (value) => _addTodo(context), // Add todo on enter
                      ),
                    ),
                  ],
                ),
              ),
              // Dropdown for category selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<String>(
                  items: <String>['Work', 'Personal'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      ),
                    );
                  }).toList(),
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                      // Dispatch the category change event
                      context.read<block.TodoBloc>().add(block.CategoryChanged(newValue));
                    }
                  },
                  dropdownColor: Colors.black, // Dropdown background color
                  hint: Text('Select Category', style: TextStyle(color: Colors.grey)),
                ),
              ),
              // Add Todo button
              ElevatedButton(
                onPressed: () {
                  _addTodo(context);
                },
                child: const Text('Add Todo', style: TextStyle(fontFamily: 'monospace')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0), // Sharp corners
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<block.TodoBloc, block.ToodoState>(
                  builder: (context, state) {
                    if (state is block.ToodoLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is block.ToodoError) {
                      return Center(child: Text(state.message, style: TextStyle(color: Colors.red)));
                    } else if (state is block.ToodoLoaded) {
                      return ListView(
                        children: [
                          ...state.workTodos.map((todo) {
                            return ListTile(
                              title: Text(
                                todo.title,
                                style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                              ),
                              subtitle: Text(
                                todo.dueDate != null
                                    ? 'Due: ${todo.dueDate!.year}-${todo.dueDate!.month}-${todo.dueDate!.day}'
                                    : 'No due date',
                                style: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context.read<block.TodoBloc>().add(block.ToodoDeleted(todo.id));
                                },
                              ),
                            );
                          }).toList(),
                          ...state.personalTodos.map((todo) {
                            return ListTile(
                              title: Text(
                                todo.title,
                                style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                              ),
                              subtitle: Text(
                                todo.dueDate != null
                                    ? 'Due: ${todo.dueDate!.year}-${todo.dueDate!.month}-${todo.dueDate!.day}'
                                    : 'No due date',
                                style: TextStyle(color: Colors.grey, fontFamily: 'monospace'),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  context.read<block.TodoBloc>().add(block.ToodoDeleted(todo.id));
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }
                    return Center(child: Text('No todos available.', style: TextStyle(color: Colors.white)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTodo(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      // Create a new Toodo object
      final newTodo = block.Toodo(
        id: DateTime.now().toString(), // Generate a unique ID
        title: _controller.text,
        content: '', // You can add content if needed
        category: _selectedCategory,
        dueDate: _selectedDate, // Add the selected date to the todo
      );

      // Dispatch the AddTodo event
      context.read<block.TodoBloc>().add(block.ToodoAdded(newTodo));
      _controller.clear();
      // Optionally show a snackbar or a message to confirm addition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo added successfully!')),
      );
    } else {
      // Optionally show a message if the input is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task.')),
      );
    }
  }
}