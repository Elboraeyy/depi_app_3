import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../auth_cubit/auth_cubit.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../models/student_model.dart';
import '../../models/task_model.dart';
import '../../tasks/cubit/tasks_cubit.dart';
import '../../tasks/cubit/tasks_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()..getStudentsFromServer()),
        BlocProvider(create: (_) => TasksCubit()..loadTasks()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final name = context.read<AuthCubit>().currentUser?.displayName;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello${name == null || name.isEmpty ? '' : ', $name'}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Text(
                'Your DEPI workspace',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 10),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Students'),
              Tab(text: 'Tasks'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [OverviewTab(), StudentsTab(), TasksTab()],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
    }
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<HomeCubit>().getStudentsFromServer(),
          context.read<TasksCubit>().loadTasks(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _WelcomeCard(),
          const SizedBox(height: 16),
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => BlocBuilder<TasksCubit, TasksState>(
              builder: (context, tasksState) => Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Students',
                      value: '${state.students.length}',
                      icon: Icons.school_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Open tasks',
                      value:
                          '${tasksState.tasks.where((task) => !task.isCompleted).length}',
                      icon: Icons.task_alt_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.person_add_alt_1,
                  label: 'Add student',
                  onTap: () => _showStudentDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_task,
                  label: 'Add task',
                  onTap: () => _showTaskDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading && state.students.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: context.read<HomeCubit>().getStudentsFromServer,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All students',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _showStudentDialog(context),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.message != null) _ErrorCard(message: state.message!),
              if (state.students.isEmpty)
                const _EmptyCard(
                  icon: Icons.school_outlined,
                  text: 'No students yet. Add your first student.',
                ),
              ...state.students.map(
                (student) => _StudentCard(student: student),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state.status == TasksStatus.loading && state.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final open = state.tasks.where((task) => !task.isCompleted).toList();
        final done = state.tasks.where((task) => task.isCompleted).toList();
        return RefreshIndicator(
          onRefresh: context.read<TasksCubit>().loadTasks,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _showTaskDialog(context),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.message != null) _ErrorCard(message: state.message!),
              if (state.tasks.isEmpty)
                const _EmptyCard(
                  icon: Icons.task_alt_outlined,
                  text: 'No tasks yet. Add something you want to finish.',
                ),
              if (open.isNotEmpty) ...[
                const _SectionLabel(label: 'In progress'),
                ...open.map((task) => _TaskCard(task: task)),
              ],
              if (done.isNotEmpty) ...[
                const _SectionLabel(label: 'Completed'),
                ...done.map((task) => _TaskCard(task: task)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay organized',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keep your students and daily work in one simple place.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.auto_awesome,
              size: 58,
              color: Colors.white.withValues(alpha: .85),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            student.name.isEmpty ? '?' : student.name[0].toUpperCase(),
          ),
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('Age ${student.age}  •  Grade ${student.grade}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await _showStudentDialog(context, student: student);
            }
            if (value == 'delete' && context.mounted) {
              await context.read<HomeCubit>().deleteStudent(student.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => context.read<TasksCubit>().toggleTask(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(task.dueDate)}${task.description.isEmpty ? '' : '  •  ${task.description}'}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await _showTaskDialog(context, task: task);
            }
            if (value == 'delete' && context.mounted) {
              await context.read<TasksCubit>().deleteTask(task.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.black26),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.red.shade50,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(message, style: TextStyle(color: Colors.red.shade800)),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.black54,
      ),
    ),
  );
}

Future<void> _showStudentDialog(
  BuildContext context, {
  StudentModel? student,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) =>
        _StudentDialog(homeCubit: context.read<HomeCubit>(), student: student),
  );
}

Future<void> _showTaskDialog(BuildContext context, {TaskModel? task}) async {
  await showDialog<void>(
    context: context,
    builder: (_) =>
        _TaskDialog(tasksCubit: context.read<TasksCubit>(), task: task),
  );
}

class _StudentDialog extends StatefulWidget {
  const _StudentDialog({required this.homeCubit, this.student});

  final HomeCubit homeCubit;
  final StudentModel? student;

  @override
  State<_StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<_StudentDialog> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _grade;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student?.name);
    _age = TextEditingController(text: widget.student?.age);
    _grade = TextEditingController(text: widget.student?.grade);
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _grade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    return AlertDialog(
      scrollable: true,
      title: Text(isEditing ? 'Edit student' : 'Add student'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _grade,
              decoration: const InputDecoration(labelText: 'Grade'),
              validator: _required,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final item = StudentModel(
      id: widget.student?.id ?? '',
      name: _name.text.trim(),
      age: _age.text.trim(),
      grade: _grade.text.trim(),
    );
    if (widget.student == null) {
      widget.homeCubit.addStudent(item);
    } else {
      widget.homeCubit.updateStudent(item);
    }
    Navigator.of(context).pop();
  }
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({required this.tasksCubit, this.task});

  final TasksCubit tasksCubit;
  final TaskModel? task;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _dueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title);
    _description = TextEditingController(text: widget.task?.description);
    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return AlertDialog(
      scrollable: true,
      title: Text(isEditing ? 'Edit task' : 'Add task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(DateFormat('dd MMM yyyy').format(_dueDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: Text(isEditing ? 'Save' : 'Add')),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _dueDate,
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final item = TaskModel(
      id: widget.task?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      dueDate: _dueDate,
      isCompleted: widget.task?.isCompleted ?? false,
    );
    if (widget.task == null) {
      widget.tasksCubit.addTask(item);
    } else {
      widget.tasksCubit.updateTask(item);
    }
    Navigator.of(context).pop();
  }
}

String? _required(String? value) {
  return value == null || value.trim().isEmpty ? 'Required' : null;
}
