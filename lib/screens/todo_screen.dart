import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../block/toodo_block.dart' as block;

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Work';

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
            borderRadius: BorderRadius.circular(10), // Rounded corners
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
                child: const Text('Add Todo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Use backgroundColor instead of primary
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