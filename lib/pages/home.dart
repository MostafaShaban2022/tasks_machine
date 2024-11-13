import 'package:flutter/material.dart';
import 'package:flutter_application_7/models/task.dart';
import 'package:flutter_application_7/services/database_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService.instance;
  String? _task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButton: _addTaskButton(),
      body: _tasksList(),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  cursorColor: Colors.red,
                  decoration: InputDecoration(
                    hintText: 'subscribe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MaterialButton(
                  onPressed: () {
                    if (_task == null || _task!.isEmpty) return;
                    _databaseService.addTask(_task!);
                    setState(() {
                      _task = null;
                    });
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                onLongPress: () {
                  _databaseService.deleteTask(task.id);
                  setState(() {});
                },
                title: Text(task.content),
                trailing: Checkbox(
                    value: task.status == 1,
                    onChanged: (value) {
                      _databaseService.updateTaskStatus(
                        task.id,
                        value == true ? 1 : 0,
                      );
                      setState(() {});
                    }),
              );
            },
          );
        }
      },
    );
  }
}
