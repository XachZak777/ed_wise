import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/ai_video.dart';

class AiVideoCard extends StatelessWidget {
  final AiVideo video;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;

  const AiVideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onDelete,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: InkWell(
        onTap: video.status == VideoStatus.completed ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          onDelete?.call();
                          break;
                        case 'retry':
                          onRetry?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<String>>[];
                      
                      if (video.status == VideoStatus.failed && onRetry != null) {
                        items.add(
                          const PopupMenuItem(
                            value: 'retry',
                            child: Row(
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8),
                                Text('Retry'),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      items.add(
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppTheme.errorColor),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                            ],
                          ),
                        ),
                      );
                      
                      return items;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusIndicator(context),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(video.duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(video.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (video.status == VideoStatus.processing) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final color = _getStatusColor(video.status);
    final text = _getStatusText(video.status);
    final icon = _getStatusIcon(video.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (video.status == VideoStatus.processing) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VideoStatus status) {
    switch (status) {
      case VideoStatus.pending:
        return Colors.orange;
      case VideoStatus.processing:
        return AppTheme.primaryColor;
      case VideoStatus.completed:
        return AppTheme.successColor;
      case VideoStatus.failed:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(VideoStatus status) {
    switch (status) {
      case VideoStatus.pending:
        return 'Pending';
      case VideoStatus.processing:
        return 'Processing...';
      case VideoStatus.completed:
        return 'Completed';
      case VideoStatus.failed:
        return 'Failed';
    }
  }

  IconData _getStatusIcon(VideoStatus status) {
    switch (status) {
      case VideoStatus.pending:
        return Icons.schedule;
      case VideoStatus.processing:
        return Icons.sync;
      case VideoStatus.completed:
        return Icons.check_circle;
      case VideoStatus.failed:
        return Icons.error;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return 'Unknown duration';
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
