import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {

  final String title;
  final String author;
  final String subject;
  final String imageUrl;
  final String intro;


  const BookDetailPage({
    required this.title,
    required this.author,
    required this.subject,
    required this.imageUrl,
    required this.intro,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  height: 250.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              Text(
                'Intro:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8.0),
              Text(intro),
              SizedBox(height: 16.0),

              Text('Author: $author'),
              Text('Subject: $subject'),
            ],
          ),
        ),
      ),
    );
  }
}
