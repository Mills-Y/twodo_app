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
  DateTime? _selectedDate;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _goToCurrentDate() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  void _editTodo(BuildContext context, block.Toodo todo) {
    final TextEditingController titleController = TextEditingController(text: todo.title);
    String? _editedCategory = todo.category;
    DateTime? _editedDueDate = todo.dueDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Edit Todo', style: TextStyle(fontFamily: 'monospace', color: Colors.yellow, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Title: '),
                SizedBox(height: 10),
                _buildCategoryDropdown(_editedCategory, (newValue) {
                  setState(() {
                    _editedCategory = newValue;
                  });
                }),
                SizedBox(height: 10),
                _buildDueDateRow(context, _editedDueDate, (pickedDate) {
                  setState(() {
                    _editedDueDate = pickedDate;
                  });
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontFamily: 'monospace', color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final updatedTodo = block.Toodo(
                    id: todo.id,
                    title: titleController.text,
                    content: todo.content,
                    category: _editedCategory ?? todo.category,
                    dueDate: _editedDueDate,
                  );

                  context.read<block.TodoBloc>().add(block.EditToodo(updatedTodo));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save', style: TextStyle(fontFamily: 'monospace', color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.green, fontFamily: 'monospace')),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'Enter title',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(String? selectedCategory, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Text('Category: ', style: TextStyle(color: Colors.green, fontFamily: 'monospace')),
        Expanded(
          child: DropdownButton<String>(
            value: selectedCategory,
            dropdownColor: Colors.black,
            items: <String>['Work', 'Personal'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              );
            }).toList(),
            onChanged: onChanged,
            hint: Text('Select Category', style: TextStyle(color: Colors.grey, fontFamily: 'monospace')),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateRow(BuildContext context, DateTime? dueDate, ValueChanged<DateTime?> onDateChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dueDate != null
              ? ' Due: ${dueDate.year}-${dueDate.month}-${dueDate.day}'
              : '>Empty...',
          style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        ElevatedButton(
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: dueDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            onDateChanged(pickedDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            minimumSize: Size(100, 10),
          ),
          child: Text('Edit Due Date', style: TextStyle(fontFamily: 'monospace', color: Colors.yellow)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 600,
          height: 800,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              TableCalendar(
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
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
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
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
                    color: Colors.green,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow[700],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Colors.grey[700],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _goToCurrentDate,
                child: Text('Go to Current Date', style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 17)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TodoInput(
                  controller: _controller,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                      context.read<block.TodoBloc>().add(block.CategoryChanged(newValue));
                    }
                  },
                  onAddTodo: () {
                    _addTodo(context);
                  },
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
                            return _buildTodoTile(context, todo);
                          }).toList(), ...state.personalTodos.map((todo) {
                            return _buildTodoTile(context, todo);
                          }).toList(),
                        ],
                      );
                    }
                    return Center(child: Text('No todos available.', style: TextStyle(color: Colors.white, fontFamily: 'monospace')));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoTile(BuildContext context, block.Toodo todo) {
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              _editTodo(context, todo);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              context.read<block.TodoBloc>().add(block.ToodoDeleted(todo.id));
            },
          ),
        ],
      ),
    );
  }

  void _addTodo(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      final newTodo = block.Toodo(
        id: DateTime.now().toString(),
        title: _controller.text,
        content: '',
        category: _selectedCategory,
        dueDate: _selectedDate,
      );

      context.read<block.TodoBloc>().add(block.ToodoAdded(newTodo));
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todo added successfully!', style: TextStyle(fontFamily: 'monospace'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task.', style: TextStyle(fontFamily: 'monospace'))),
      );
    }
  }
}

class TodoInput extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onAddTodo;

  TodoInput({
    required this.controller,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddTodo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '>Add todo...',
              hintStyle: TextStyle(color: Colors.white),
            ),
            onSubmitted: (value) => onAddTodo(),
          ),
        ),
        Container(
          width: 103, // Set the desired width for the dropdown
          child: DropdownButton<String>(
            value: selectedCategory,
            items: <String>['Work', 'Personal'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
              );
            }).toList(),
            onChanged: onCategoryChanged,
            dropdownColor: Colors.black,
            hint: Text('Select', style: TextStyle(color: Colors.grey)),
          ),
        ),
        SizedBox(width: 40), // Add spacing between the dropdown and the button
        ElevatedButton(
          onPressed: onAddTodo,
          child: const Text('Enter', style: TextStyle(fontFamily: 'monospace', color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2), // Adjust padding
            minimumSize: Size(100, 30), // Adjust minimum size if needed
          ),
        ),
      ],
    );
  }
}