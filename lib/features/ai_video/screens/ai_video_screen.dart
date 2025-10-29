import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/ai_video_provider.dart';
import '../widgets/ai_video_card.dart';
import '../widgets/create_video_dialog.dart';
import '../models/ai_video.dart';

class AiVideoScreen extends StatefulWidget {
  const AiVideoScreen({super.key});

  @override
  State<AiVideoScreen> createState() => _AiVideoScreenState();
}

class _AiVideoScreenState extends State<AiVideoScreen> {
  final AiVideoProvider _provider = AiVideoProvider();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _provider.loadVideos(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Video Generator'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Videos')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
              const PopupMenuItem(value: 'Processing', child: Text('Processing')),
              const PopupMenuItem(value: 'Failed', child: Text('Failed')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedFilter),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AiVideo>>(
        stream: _provider.videosStream,
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
                    'Error loading videos',
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
                    onPressed: _loadVideos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final videos = snapshot.data ?? [];
          final filteredVideos = _filterVideos(videos);

          if (filteredVideos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'All'
                        ? 'No videos yet'
                        : 'No $_selectedFilter.toLowerCase() videos',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'All'
                        ? 'Create your first AI video to get started'
                        : 'Try a different filter',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateVideoDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create AI Video'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadVideos,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return AiVideoCard(
                  video: video,
                  onTap: () => _navigateToVideoPlayer(video),
                  onDelete: () => _showDeleteConfirmation(video),
                  onRetry: video.status == VideoStatus.failed ? () => _retryVideo(video) : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateVideoDialog,
        icon: const Icon(Icons.video_call),
        label: const Text('Create Video'),
      ),
    );
  }

  List<AiVideo> _filterVideos(List<AiVideo> videos) {
    switch (_selectedFilter) {
      case 'Completed':
        return videos.where((video) => video.status == VideoStatus.completed).toList();
      case 'Processing':
        return videos.where((video) => video.status == VideoStatus.processing).toList();
      case 'Failed':
        return videos.where((video) => video.status == VideoStatus.failed).toList();
      default:
        return videos;
    }
  }

  void _showCreateVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateVideoDialog(
        onCreate: (title, text, style) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _provider.createVideo(
              user.uid,
              title,
              text,
              style,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video creation started'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _navigateToVideoPlayer(AiVideo video) {
    if (video.status == VideoStatus.completed) {
      // TODO: Navigate to video player screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video player coming soon')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video is still processing')),
      );
    }
  }

  void _showDeleteConfirmation(AiVideo video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: Text('Are you sure you want to delete "${video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _provider.deleteVideo(video.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video deleted'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _retryVideo(AiVideo video) {
    // TODO: Implement retry functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retry functionality coming soon')),
    );
  }
}
