import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'activity_detail_screen.dart';

class ActivitiesListScreen extends StatelessWidget {
  const ActivitiesListScreen({super.key});

  static const List<Activity> activities = [
    Activity(
      id: 92,
      arName: "اقرأ",
      enName: "Read",
      fileUrl: "https://s3.us-east-1.amazonaws.com/bucket.schoobrary.com/eduBook.zip",
      logoUrl: "https://test2data2.s3.us-east-1.amazonaws.com/public/uploads/logo/reading.png",
      fileType: "2",
    ),
    // Activity(
    //   id: 93,
    //   arName: "اكتب",
    //   enName: "Write",
    //   fileUrl: "https://s3.us-east-1.amazonaws.com/bucket.schoobrary.com/eduBook.zip",
    //   logoUrl: "https://test2data2.s3.us-east-1.amazonaws.com/public/uploads/logo/write.png",
    //   fileType: "1",
    // ),
    // Activity(
    //   id: 94,
    //   arName: "العب",
    //   enName: "Play",
    //   fileUrl: "https://s3.us-east-1.amazonaws.com/bucket.schoobrary.com/eduBook.zip",
    //   logoUrl: "https://test2data2.s3.us-east-1.amazonaws.com/public/uploads/logo/game.png",
    //   fileType: "1",
    // ),
    // Activity(
    //   id: 95,
    //   arName: "تدرب",
    //   enName: "Practice",
    //   fileUrl: "https://s3.us-east-1.amazonaws.com/bucket.schoobrary.com/eduBook.zip",
    //   logoUrl: "https://test2data2.s3.us-east-1.amazonaws.com/public/uploads/logo/elearning.png",
    //   fileType: "1",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الكتب'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetailScreen(activity: activity),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Hero(
                      tag: 'logo_${activity.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          activity.logoUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.arName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.enName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
