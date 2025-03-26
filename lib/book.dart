import 'package:hive/hive.dart';

part 'book.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Book {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String author;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double price;

  @HiveField(4)
  bool isRented; // Rental status

  @HiveField(5)
  String? availableDate; // Availability date

  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.price,
    this.isRented = false, // Default to not rented
    this.availableDate, // Default to null
  });
}
