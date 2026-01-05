import 'package:flutter/material.dart';

enum PostType { rating, note, wishlist }

class PostCard extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final String action;
  final String time;
  final String bookTitle;
  final Color bookCoverColor;
  final PostType type;
  final int? rating;
  final String? comment;
  final String? quote;

  const PostCard({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.action,
    required this.time,
    required this.bookTitle,
    required this.bookCoverColor,
    required this.type,
    this.rating,
    this.comment,
    this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Tên + Hành động
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " "),
                          TextSpan(
                            text: action,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Icon loại bài viết
              if (type == PostType.rating)
                const Icon(Icons.star, color: Colors.amber, size: 20)
              else if (type == PostType.note)
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.green,
                  size: 20,
                )
              else
                const Icon(
                  Icons.bookmark_outline,
                  color: Colors.purple,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Nội dung chính
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bìa sách (Giả lập)
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: bookCoverColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white24,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    // Rating stars
                    if (type == PostType.rating && rating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: index < rating!
                                ? Colors.amber
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Quote (Ghi chú)
                    if (type == PostType.note && quote != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: Colors.green, width: 3),
                          ),
                        ),
                        child: Text(
                          quote!,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ),

                    // Comment (Đánh giá)
                    if (type == PostType.rating && comment != null) ...[
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              comment!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
