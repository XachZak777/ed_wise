import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/forum_provider.dart';
import '../widgets/forum_post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/category_filter_chip.dart';
import '../models/forum_post.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumProvider _provider = ForumProvider();
  String _selectedCategory = 'All';
  String _sortBy = 'Recent';
  final List<String> _categories = [
    'All',
    'General',
    'Study Tips',
    'Science',
    'Mathematics',
    'Technology',
    'Q&A',
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    await _provider.loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        actions: [
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
                    });
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          
          // Posts List
          Expanded(
            child: StreamBuilder<List<ForumPost>>(
              stream: _provider.postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
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
                          snapshot.error.toString(),
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

                final posts = snapshot.data ?? [];
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
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
        onCreate: (title, content, category, tags) async {
          await _provider.createPost(
            user.uid,
            user.email ?? '',
            user.displayName ?? 'Anonymous',
            title,
            content,
            category,
            tags,
          );
          if (mounted) {
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
    // TODO: Navigate to post details screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post details coming soon')),
    );
  }

  void _handleUpvote(ForumPost post) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _provider.toggleUpvote(post.id, user.uid);
  }

  void _handleDownvote(ForumPost post) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _provider.toggleDownvote(post.id, user.uid);
  }
}
