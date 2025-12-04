import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../bloc/comment_bloc.dart';
import '../widgets/forum_post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/category_filter_chip.dart';
import '../screens/post_details_screen.dart';
import '../models/forum_post.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Recent';
  final List<String> _categories = [
    'All',
    'Flutter',
    'Firebase',
    'Dart',
    'General',
    'Study Tips',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    context.read<ForumBloc>().add(
          ForumLoadRequested(
            category: _selectedCategory == 'All' ? null : _selectedCategory,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Post',
            onPressed: _showCreatePostDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Recent', child: Text('Most Recent')),
              const PopupMenuItem(value: 'Popular', child: Text('Most Popular')),
              const PopupMenuItem(value: 'Top', child: Text('Top Rated')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_sortBy),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return CategoryFilterChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'All';
                      _loadPosts();
                    });
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          
          // Posts List
          Expanded(
            child: BlocBuilder<ForumBloc, ForumState>(
              builder: (context, state) {
                if (state is ForumLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ForumError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPosts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                List<ForumPost> posts = [];
                if (state is ForumLoaded) {
                  posts = state.posts;
                }

                final filteredPosts = _filterAndSortPosts(posts);

                if (filteredPosts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == 'All'
                              ? 'No posts yet'
                              : 'No posts in $_selectedCategory',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory == 'All'
                              ? 'Be the first to start a discussion'
                              : 'Try a different category',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCreatePostDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Post'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return ForumPostCard(
                        post: post,
                        onTap: () => _navigateToPostDetails(post),
                        onUpvote: () => _handleUpvote(post),
                        onDownvote: () => _handleDownvote(post),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ForumPost> _filterAndSortPosts(List<ForumPost> posts) {
    // Filter by category
    List<ForumPost> filtered = posts;
    if (_selectedCategory != 'All') {
      filtered = posts.where((post) => post.category == _selectedCategory).toList();
    }

    // Sort posts
    switch (_sortBy) {
      case 'Popular':
        filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case 'Top':
        filtered.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'Recent':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  void _showCreatePostDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to create a post'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CreatePostDialog(
        categories: _categories.where((c) => c != 'All').toList(),
        onCreate: (title, content, category, tags) {
          context.read<ForumBloc>().add(
                ForumPostCreateRequested(
                  userId: user.uid,
                  userName: user.displayName ?? 'Anonymous',
                  userEmail: user.email ?? '',
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
                content: Text('Post created successfully'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
      ),
    );
  }

  void _navigateToPostDetails(ForumPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ForumBloc>()),
            BlocProvider(create: (_) => CommentBloc()),
          ],
          child: PostDetailsScreen(post: post),
        ),
      ),
    );
  }

  void _handleUpvote(ForumPost post) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    context.read<ForumBloc>().add(
          ForumPostUpvoteRequested(
            postId: post.id,
            userId: user.uid,
          ),
        );
  }

  void _handleDownvote(ForumPost post) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    context.read<ForumBloc>().add(
          ForumPostDownvoteRequested(
            postId: post.id,
            userId: user.uid,
          ),
        );
  }
}
