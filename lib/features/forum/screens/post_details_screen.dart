import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../models/forum_post.dart';
import '../widgets/comment_item.dart';
import '../widgets/edit_post_dialog.dart';

class PostDetailsScreen extends StatefulWidget {
  final ForumPost post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  late ForumPost _currentPost;
  final List<String> _categories = [
    'Flutter',
    'Firebase',
    'Dart',
    'General',
    'Study Tips',
  ];

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    context.read<CommentBloc>().add(CommentLoadRequested(postId: widget.post.id));
    
    // Listen to forum bloc to update post when it's edited
    final forumBloc = context.read<ForumBloc>();
    forumBloc.stream.listen((state) {
      if (state is ForumLoaded) {
        try {
          final updatedPost = state.posts.firstWhere(
            (p) => p.id == _currentPost.id,
          );
          if (mounted && updatedPost != _currentPost) {
            setState(() {
              _currentPost = updatedPost;
            });
          }
        } catch (e) {
          // Post not found in list (may have been deleted)
        }
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  bool get _isPostOwner {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.uid == _currentPost.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: _isPostOwner
            ? [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Text(widget.post.userName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPost.userName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _formatDate(_currentPost.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(_currentPost.category),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post Title
                  Text(
                    _currentPost.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Post Content
                  Text(
                    _currentPost.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_currentPost.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _currentPost.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Vote Section
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up_outlined,
                          color: _currentPost.upvotedBy.contains(
                            FirebaseAuth.instance.currentUser?.uid ?? '',
                          )
                              ? AppTheme.successColor
                              : null,
                        ),
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context.read<ForumBloc>().add(
                                  ForumPostUpvoteRequested(
                                    postId: _currentPost.id,
                                    userId: user.uid,
                                  ),
                                );
                          }
                        },
                      ),
                      Text('${_currentPost.upvotes}'),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down_outlined,
                          color: _currentPost.downvotedBy.contains(
                            FirebaseAuth.instance.currentUser?.uid ?? '',
                          )
                              ? AppTheme.errorColor
                              : null,
                        ),
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context.read<ForumBloc>().add(
                                  ForumPostDownvoteRequested(
                                    postId: _currentPost.id,
                                    userId: user.uid,
                                  ),
                                );
                          }
                        },
                      ),
                      Text('${_currentPost.downvotes}'),
                      const Spacer(),
                      Icon(
                        Icons.comment,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text('${_currentPost.commentCount}'),
                    ],
                  ),
                  const Divider(height: 32),

                  // Comments Section
                  Text(
                    'Comments (${_currentPost.commentCount})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Comments List
                  BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, state) {
                      if (state is CommentLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is CommentError) {
                        return Center(
                          child: Text('Error: ${state.message}'),
                        );
                      }

                      List<ForumComment> comments = [];
                      if (state is CommentLoaded) {
                        comments = state.comments;
                      }

                      if (comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return CommentItem(comment: comments[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppTheme.primaryColor,
                  onPressed: _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    context.read<CommentBloc>().add(
          CommentCreateRequested(
            postId: _currentPost.id,
            userId: user.uid,
            userName: user.displayName ?? 'Anonymous',
            userEmail: user.email ?? '',
            content: content,
          ),
        );

    _commentController.clear();
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditPostDialog(
        post: _currentPost,
        categories: _categories,
        onSave: (title, content, category, tags) {
          context.read<ForumBloc>().add(
                ForumPostEditRequested(
                  postId: _currentPost.id,
                  title: title,
                  content: content,
                  category: category,
                  tags: tags,
                ),
              );
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post updated successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ForumBloc>().add(
                    ForumPostDeleteRequested(postId: _currentPost.id),
                  );
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

