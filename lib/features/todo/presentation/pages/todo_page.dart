import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/todo_controller.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  static const _categories = ['All', 'Work', 'Personal', 'Shopping', 'Health', 'Study'];
  static const _priorityColors = [Color(0xFF4CAF50), Color(0xFFFFC107), Color(0xFFFF5252)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoControllerProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(children: [
        // Category chips
        SizedBox(height: 48, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final isSelected = (cat == 'All' && selectedCategory == null) || cat == selectedCategory;
            return Padding(padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state =
                  cat == 'All' ? null : cat,
              ));
          },
        )).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 8),
        // Search
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(hintText: 'Search tasks...', prefixIcon: const Icon(Icons.search_rounded),
              filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            onChanged: (v) => ref.read(todoControllerProvider.notifier).search(v),
          )),
        const SizedBox(height: 8),
        Expanded(child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (todos) {
            var filtered = selectedCategory != null ? todos.where((t) => t.category == selectedCategory).toList() : todos;
            final active = filtered.where((t) => !t.isCompleted).toList();
            final done = filtered.where((t) => t.isCompleted).toList();
            if (filtered.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.checklist_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No tasks yet', style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              ]));
            }
            return ListView(padding: const EdgeInsets.all(16), children: [
              ...active.asMap().entries.map((e) => _buildTodoItem(context, ref, e.value, e.key, theme)),
              if (done.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Completed (${done.length})', style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                const SizedBox(height: 8),
                ...done.asMap().entries.map((e) => _buildTodoItem(context, ref, e.value, e.key + active.length, theme)),
              ],
            ]);
          },
        )),
      ]),
    );
  }

  Widget _buildTodoItem(BuildContext context, WidgetRef ref, todo, int index, ThemeData theme) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(todoControllerProvider.notifier).deleteTodo(todo.id),
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: theme.colorScheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error)),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => ref.read(todoControllerProvider.notifier).toggleComplete(todo.id),
            activeColor: theme.colorScheme.primary,
          ),
          title: Text(todo.title, style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : null)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (todo.category != null) Chip(label: Text(todo.category!, style: const TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            const SizedBox(width: 8),
            Container(width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _priorityColors[todo.priority.clamp(0, 2)])),
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    String title = ''; String? category; int priority = 0;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) =>
      StatefulBuilder(builder: (context, setState) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('New Task', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(autofocus: true, decoration: const InputDecoration(labelText: 'Task title'), onChanged: (v) => title = v),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Category'),
            items: ['Work', 'Personal', 'Shopping', 'Health', 'Study'].map((c) =>
              DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => category = v,
          ),
          const SizedBox(height: 12),
          Text('Priority', style: Theme.of(context).textTheme.labelMedium),
          Row(children: ['Low', 'Medium', 'High'].asMap().entries.map((e) =>
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
              label: Text(e.value), selected: priority == e.key,
              onSelected: (_) => setState(() => priority = e.key),
            ))).toList()),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              if (title.isNotEmpty) {
                ref.read(todoControllerProvider.notifier).addTodo(title: title, category: category, priority: priority);
                Navigator.pop(context);
              }
            }, child: const Text('Add Task'))),
        ]),
      )));
  }
}
