import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RentHistoryScreen extends StatelessWidget {
  const RentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<List> rentHistoryBox = Hive.box<List>('rentHistory');
    final List rentHistory =
        rentHistoryBox.get('rentHistory', defaultValue: []) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Rent History')),
      body: ListView.builder(
        itemCount: rentHistory.length,
        itemBuilder: (context, index) {
          final borrowedBook = rentHistory[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book Title: ${borrowedBook['title']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Renter Name: ${borrowedBook['renterName']}'),
                  Text('Contact Info: ${borrowedBook['contact']}'),
                  Text('Rented on: ${borrowedBook['rentedDate']}'),
                  Text('Return Date: ${borrowedBook['returnDate']}'),
                  Text(
                    'Payment: ₱${borrowedBook['payment']}',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    borrowedBook['isReturned']
                        ? 'Returned (Queue #: ${borrowedBook['queueNumber']})'
                        : 'Not Returned',
                    style: TextStyle(
                      color:
                          borrowedBook['isReturned']
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
