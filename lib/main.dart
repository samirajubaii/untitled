import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'book_detail_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
        ),
      ),
      home: BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<dynamic> books = [];
  bool isLoading = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllBooks();
  }

  Future<void> fetchAllBooks() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://192.168.0.105/pmobile/search_books.php'));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final fetchedBooks = json.decode(response.body);


        if (response.body.contains("No books found")) {
          setState(() {
            books = [];
          });
        } else if (fetchedBooks is List) {
          setState(() {
            books = fetchedBooks;
          });
        } else {
          print('Unexpected response format');
          setState(() {
            books = [];
          });
        }
      } catch (e) {
        print('Error parsing books: $e');
        setState(() {
          books = [];
        });
      }
    } else {
      print('Failed to load books');
      setState(() {
        books = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> searchBooks(String searchTerm) async {
    if (searchTerm.isEmpty) {
      fetchAllBooks();
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://192.168.0.105/pmobile/search_books.php?searchTerm=$searchTerm'));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final fetchedBooks = json.decode(response.body);

        if (response.body.contains("No books found")) {
          setState(() {
            books = []; // No books found
          });
        } else if (fetchedBooks is List) {
          setState(() {
            books = fetchedBooks;
          });
        } else {
          print('Search response is not a list');
          setState(() {
            books = [];
          });
        }
      } catch (e) {
        print('Error parsing books: $e');
        setState(() {
          books = [];
        });
      }
    } else {
      print('Failed to search books');
      setState(() {
        books = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books List'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              String searchTerm = searchController.text;
              searchBooks(searchTerm);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search for books by title, author, or subject',
                labelStyle: TextStyle(color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              onSubmitted: (value) {
                searchBooks(value);
              },
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
          if (!isLoading && books.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        book['title'] ?? 'No Title',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${book['author'] ?? 'No Author'} - ${book['subject'] ?? 'No Subject'}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailPage(
                              title: book['title'] ?? 'Unknown Title',
                              author: book['author'] ?? 'Unknown Author',
                              subject: book['subject'] ?? 'Unknown Subject',
                              imageUrl: book['image_url'] ?? '',
                              intro: book['intro'] ?? 'No introduction available',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          if (!isLoading && books.isEmpty)
            Center(child: Text('No books found')),
        ],
      ),
    );
  }
}
