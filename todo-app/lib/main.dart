import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class Todo {
  String text;
  bool completed;

  Todo({
    required this.text,
    this.completed = false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late SharedPreferences _prefs;
  List<Todo> _todos = [];
  String newTodo = "";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    await _initSharedPreferences();
    _loadData();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    List<String> todoStrings = _prefs.getStringList('todos') ?? [];
    setState(() {
      _todos = todoStrings.map((text) => Todo(text: text)).toList();
    });
  }

  _saveData() async {
    List<String> todoStrings = _todos.map((todo) => todo.text).toList();
    await _prefs.setStringList('todos', todoStrings);
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a new To-Do"),
          content: TextField(
            onChanged: (value) {
              setState(() {
                newTodo = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter your to-do',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (newTodo.isNotEmpty) {
                  setState(() {
                    _todos.add(Todo(text: newTodo));
                    _saveData();
                    Navigator.pop(context);
                    _showSnackBar("To-Do added successfully");
                    newTodo = "";
                  });
                } else {
                  _showSnackBar("Please enter a to-do");
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete To-Do"),
          content: Text("Are you sure you want to delete this To-Do?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _todos.removeAt(index);
                  _saveData();
                  Navigator.pop(context);
                  _showSnackBar("To-Do deleted");
                });
              },
              child: Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aesthetic To-Do List"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                _todos[index].text,
                style: TextStyle(
                  fontSize: 18,
                  decoration: _todos[index].completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTodo(index);
                },
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Edit To-Do"),
                      content: TextField(
                        onChanged: (value) {
                          setState(() {
                            _todos[index].text = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Edit your to-do',
                        ),
                        controller:
                            TextEditingController(text: _todos[index].text),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _saveData();
                            _showSnackBar("To-Do edited");
                          },
                          child: Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              },
              onLongPress: () {
                setState(() {
                  _todos[index].completed = !_todos[index].completed;
                  _saveData();
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
}
