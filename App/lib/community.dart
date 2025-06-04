import 'package:flutter/material.dart';

class HealthCommunityApp extends StatefulWidget {
  const HealthCommunityApp({Key? key}) : super(key: key);

  @override
  State<HealthCommunityApp> createState() => _HealthCommunityAppState();
}

class _HealthCommunityAppState extends State<HealthCommunityApp> {
  // Dummy data for community posts
  final List<CommunityPost> _posts = [
    CommunityPost(
      authorName: "Dr. Sarah Johnson",
      authorAvatar: "https://randomuser.me/api/portraits/women/44.jpg",
      title: "Tips for Managing Stress",
      content:
          "Regular exercise, adequate sleep, and mindfulness practices can significantly reduce stress levels.",
      likes: 128,
      comments: 32,
      timePosted: "2 hours ago",
    ),
    CommunityPost(
      authorName: "Mike Chen",
      authorAvatar: "https://randomuser.me/api/portraits/men/22.jpg",
      title: "My Diabetes Management Journey",
      content:
          "After being diagnosed last year, I've made significant lifestyle changes that have helped me control my blood sugar levels.",
      likes: 95,
      comments: 18,
      timePosted: "5 hours ago",
    ),
    CommunityPost(
      authorName: "Emma Wilson",
      authorAvatar: "https://randomuser.me/api/portraits/women/63.jpg",
      title: "Support Group for New Parents",
      content:
          "I'm starting a virtual support group for new parents. Join us every Thursday at 7 PM.",
      likes: 72,
      comments: 24,
      timePosted: "1 day ago",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Community',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4742DE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality would go here
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notifications functionality would go here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new post functionality would go here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new post')),
          );
        },
        backgroundColor: const Color(0xFF4742DE),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info row
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.authorAvatar),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post.timePosted,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Post title
            Text(
              post.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            // Post content
            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Likes and comments row
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red[400], size: 20),
                const SizedBox(width: 4),
                Text('${post.likes}'),
                const SizedBox(width: 24),
                Icon(Icons.comment, color: Colors.blue[400], size: 20),
                const SizedBox(width: 4),
                Text('${post.comments}'),
              ],
            ),
            const Divider(height: 24),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.favorite_border, 'Like'),
                _buildActionButton(Icons.comment_outlined, 'Comment'),
                _buildActionButton(Icons.share_outlined, 'Share'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            )
          ],
        ),
      ),
    );
  }
}

class CommunityPost {
  final String authorName;
  final String authorAvatar;
  final String title;
  final String content;
  final int likes;
  final int comments;
  final String timePosted;

  CommunityPost({
    required this.authorName,
    required this.authorAvatar,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.timePosted,
  });
}
