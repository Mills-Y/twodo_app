import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart'; // Import Mockito for mocking
import 'package:todo/block/toodo_block.dart';
import 'package:todo/screens/todo_screen.dart';

// Create a Mock class for TodoBloc
class MockTodoBloc extends Mock implements TodoBloc {}

void main() {
  testWidgets('Add and remove Todo item', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => MockTodoBloc(),
          child: TodoScreen(),
        ),
      ),
    );

    // Verify that the initial state is empty.
    expect(find.text('Enter task'), findsOneWidget); // Adjust based on your actual UI
    expect(find.text('No todos available.'), findsOneWidget); // Adjust based on your actual UI

    // Add a new Todo item.
    await tester.enterText(find.byType(TextField), 'New Work Task');
    await tester.tap(find.text('Work')); // Ensure this matches your dropdown
    await tester.tap(find.text('Add Todo'));
    await tester.pumpAndSettle(); // Rebuild the widget after the state has changed

    // Verify that the new Todo item is displayed.
    expect(find.text('New Work Task'), findsOneWidget);

    // Remove the Todo item.
    await tester.tap(find.byIcon(Icons.delete)); // Assuming you have a delete icon
    await tester.pumpAndSettle(); // Rebuild the widget after the state has changed

    // Verify that the Todo item is removed.
    expect(find.text('New Work Task'), findsNothing);
  });

  testWidgets('Edit Todo item', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => MockTodoBloc(),
          child: TodoScreen(),
        ),
      ),
    );

    // Add a new Todo item.
    await tester.enterText(find.byType(TextField), 'Todo to Edit');
    await tester.tap(find.text('Work')); // Ensure this matches your dropdown
    await tester.tap(find.text('Add Todo'));
    await tester.pumpAndSettle();

    // Verify that the new Todo item is displayed.
    expect(find.text('Todo to Edit'), findsOneWidget);

    // Tap on the Todo item to edit it.
    await tester.tap(find.text('Todo to Edit'));
    await tester.pumpAndSettle();

    // Edit the Todo item.
    await tester.enterText(find.byType(TextField), 'Edited Todo Item');
    await tester.tap(find.text('Save')); // Adjust this based on your button text
    await tester.pumpAndSettle();

    // Verify that the edited Todo item is displayed.
    expect(find.text('Edited Todo Item'), findsOneWidget);
    expect(find.text('Todo to Edit'), findsNothing);
  });
}