import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_providers.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/post.dart';

class CreatePostDialog extends ConsumerStatefulWidget {
  const CreatePostDialog({super.key});

  @override
  ConsumerState<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<CreatePostDialog> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  bool _isAlert = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Forum Topic', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _regionCtrl, decoration: const InputDecoration(labelText: 'Region')),
          const SizedBox(height: 12),
          TextField(controller: _contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Content')),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('Mark as Alert (Disease/Pests/Crime)'),
            value: _isAlert,
            onChanged: (v) => setState(() => _isAlert = v!),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;
              setState(() => _isLoading = true);
              final post = Post(
                id: 'POST-${DateTime.now().millisecondsSinceEpoch}',
                author: 'Current User', // To be pulled from Auth
                region: _regionCtrl.text.isEmpty ? 'General' : _regionCtrl.text,
                title: _titleCtrl.text,
                content: _contentCtrl.text,
                replies: 0,
                tags: [],
                isAlert: _isAlert,
                time: DateTime.now(),
              );
              await ref.read(communityRepositoryProvider).createPost(post);
              ref.invalidate(communityPostsProvider);
              if (mounted) Navigator.pop(context);
            },
            child: _isLoading ? const CircularProgressIndicator() : const Text('Post'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
