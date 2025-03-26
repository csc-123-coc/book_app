import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'book.dart'; // Import your Book model
import 'renter.dart'; // Import your Renter model
import 'firstpage.dart'; // Import the Introduction Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BookAdapter());
  Hive.registerAdapter(RenterAdapter());
  await Hive.openBox<Book>('books');
  await Hive.openBox<List>('borrowedBooks');
  await Hive.openBox<List>('rentHistory'); // New box for rent history
  await Hive.openBox<Renter>('renters');
  runApp(const BookRentingApp());
}

class BookRentingApp extends StatelessWidget {
  const BookRentingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '📖Book Renting App📖',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.brown[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        buttonTheme: const ButtonThemeData(buttonColor: Colors.brown),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.brown,
        ).copyWith(secondary: Colors.brown[300]),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstPage(),
        '/home': (context) => const HomeScreen(),
        '/rentHistory':
            (context) => RentHistoryScreen(
              borrowedBooks:
                  Hive.box<List>('borrowedBooks')
                      .get('borrowedBooks', defaultValue: [])
                      ?.map((item) => Map<String, dynamic>.from(item))
                      .toList() ??
                  [],
            ),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Box<Book> bookBox = Hive.box<Book>('books');
  final Box<Renter> renterBox = Hive.box<Renter>('renters');
  List<Map<String, dynamic>> borrowedBooks = [];
  List<Map<String, dynamic>> rentHistory = []; // New list for rent history
  TextEditingController searchController = TextEditingController();
  List<Book> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadBorrowedBooks();
    _loadRentHistory(); // Load rent history
    searchController.addListener(_filterBooks);
  }

  void _loadBooks() {
    setState(() {
      filteredBooks = bookBox.values.toList();
    });
  }

  void _loadBorrowedBooks() {
    var box = Hive.box<List>('borrowedBooks');
    borrowedBooks =
        (box.get('borrowedBooks', defaultValue: []) ?? [])
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
  }

  void _loadRentHistory() {
    var box = Hive.box<List>('rentHistory');
    rentHistory =
        (box.get('rentHistory', defaultValue: []) ?? [])
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
  }

  void _filterBooks() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredBooks =
          bookBox.values.where((book) {
            return book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _saveBorrowedBooks() {
    Hive.box<List>('borrowedBooks').put('borrowedBooks', borrowedBooks);
  }

  void _saveRentHistory() {
    Hive.box<List>('rentHistory').put('rentHistory', rentHistory);
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Book Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (₱)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Book Cover URL',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String title = titleController.text;
                String author = authorController.text;
                String priceString = priceController.text;
                String imageUrl = imageUrlController.text;

                if (title.isEmpty ||
                    author.isEmpty ||
                    priceString.isEmpty ||
                    imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
                  );
                  return;
                }

                double? price = double.tryParse(priceString);
                if (price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price.'),
                    ),
                  );
                  return;
                }

                Book newBook = Book(
                  title: title,
                  author: author,
                  imageUrl: imageUrl,
                  price: price,
                  isRented: false,
                );
                bookBox.add(newBook);
                setState(() {
                  filteredBooks.add(newBook);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Book'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddRenterDialog() {
    final fullNameController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Renter'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String fullName = fullNameController.text;
                String contact = contactController.text;

                if (fullName.isEmpty || contact.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
                  );
                  return;
                }

                renterBox.add(Renter(fullName: fullName, contact: contact));
                Navigator.of(context).pop();
              },
              child: const Text('Add Renter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRenter(Renter renter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Renter'),
          content: Text(
            'Are you sure you want to delete "${renter.fullName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                renterBox.deleteAt(renterBox.values.toList().indexOf(renter));
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Renting App')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown),
              child: Text(
                'Library',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(LineAwesomeIcons.book_solid),
              title: const Text('Books'),
              onTap:
                  () => setState(() {
                    _selectedIndex = 0;
                    Navigator.pop(context);
                  }),
            ),
            ListTile(
              leading: const Icon(LineAwesomeIcons.handshake_solid),
              title: const Text('Borrowed Books'),
              onTap:
                  () => setState(() {
                    _selectedIndex = 1;
                    Navigator.pop(context);
                  }),
            ),
            ListTile(
              leading: const Icon(LineAwesomeIcons.book_dead_solid),
              title: const Text('Overdue Books'),
              onTap:
                  () => setState(() {
                    _selectedIndex = 2;
                    Navigator.pop(context);
                  }),
            ),
            ListTile(
              leading: const Icon(LineAwesomeIcons.users_solid),
              title: const Text('List of Renters'),
              onTap:
                  () => setState(() {
                    _selectedIndex = 3;
                    Navigator.pop(context);
                  }),
            ),
            ListTile(
              leading: const Icon(LineAwesomeIcons.history_solid),
              title: const Text('Rent History'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              RentHistoryScreen(borrowedBooks: borrowedBooks),
                    ),
                  ),
            ),
          ],
        ),
      ),
      body: _getBody(),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: _showAddBookDialog,
                tooltip: 'Add New Book',
                child: const Icon(Icons.add),
              )
              : _selectedIndex == 3
              ? FloatingActionButton(
                onPressed: _showAddRenterDialog,
                tooltip: 'Add New Renter',
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildBookList(filteredBooks);
      case 1:
        return _buildBorrowedBooksList();
      case 2:
        return _buildOverdueBooksList();
      case 3:
        return _buildRenterList();
      default:
        return _buildBookList(filteredBooks);
    }
  }

  Widget _buildBookList(List<Book> bookList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search Books',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: bookList.length,
            itemBuilder: (context, index) {
              final book = bookList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.asset(book.imageUrl, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '₱${book.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              book.author,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (book.isRented)
                              Text(
                                'Due on: ${book.availableDate ?? 'N/A'}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed:
                                      book.isRented
                                          ? () => _showReturnDialog(book)
                                          : () => _showRentDialog(book),
                                  child: Text(
                                    book.isRented ? 'Return' : 'Rent',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBorrowedBooksList() {
    return ListView.builder(
      itemCount: borrowedBooks.length,
      itemBuilder: (context, index) {
        final borrowedBook = borrowedBooks[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 150,
                  child: Image.network(
                    borrowedBook['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
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
                      Text('Due Date: ${borrowedBook['returnDate']}'),
                      Text(
                        'Payment: ₱${borrowedBook['payment']}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      Text(
                        borrowedBook['isReturned']
                            ? 'Returned'
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRentDialog(Book book) {
    final returnDateController = TextEditingController();
    DateTime rentedDate = DateTime.now();
    TimeOfDay rentedTime = TimeOfDay.now();
    Renter? selectedRenter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rent Book: ${book.title}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton<Renter>(
                  hint: const Text('Select Renter'),
                  value: selectedRenter,
                  onChanged:
                      (Renter? newValue) =>
                          setState(() => selectedRenter = newValue),
                  items:
                      renterBox.values.map((Renter renter) {
                        return DropdownMenuItem<Renter>(
                          value: renter,
                          child: Text(renter.fullName),
                        );
                      }).toList(),
                ),
                TextField(
                  controller: returnDateController,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      returnDateController.text = DateFormat(
                        'yMMMMd',
                      ).format(pickedDate);
                    }
                  },
                ),
                TextButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: rentedTime,
                    );
                    if (pickedTime != null) {
                      rentedTime = pickedTime;
                      rentedDate = DateTime(
                        rentedDate.year,
                        rentedDate.month,
                        rentedDate.day,
                        rentedTime.hour,
                        rentedTime.minute,
                      );
                    }
                  },
                  child: Text(
                    'Select Time Rented: ${rentedTime.format(context)}',
                  ),
                ),
                Text('Payment Amount: ₱${book.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedRenter == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a renter.')),
                  );
                  return;
                }

                String returnDate = returnDateController.text;
                if (returnDate.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
                  );
                  return;
                }

                borrowedBooks.add({
                  'title': book.title,
                  'renterName': selectedRenter!.fullName,
                  'contact': selectedRenter!.contact,
                  'rentedDate': DateFormat('yMMMMd').format(rentedDate),
                  'returnDate': returnDate,
                  'payment': book.price.toString(),
                  'imageUrl': book.imageUrl,
                  'isReturned': false,
                  'dueDate': DateTime.now().add(const Duration(days: 7)),
                });

                // Add to rent history immediately
                rentHistory.add({
                  'title': book.title,
                  'renterName': selectedRenter!.fullName,
                  'contact': selectedRenter!.contact,
                  'rentedDate': DateFormat('yMMMMd').format(rentedDate),
                  'returnDate': returnDate,
                  'payment': book.price.toString(),
                  'imageUrl': book.imageUrl,
                  'isReturned': false,
                  'dueDate': DateTime.now().add(const Duration(days: 7)),
                });

                _saveBorrowedBooks();
                _saveRentHistory(); // Save rent history
                book.isRented = true;
                book.availableDate = returnDate;

                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showReturnDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Book'),
          content: Text('Are you sure you want to return "${book.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                _returnBook(book);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm Return'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _returnBook(Book book) {
    for (var borrowedBook in borrowedBooks) {
      if (borrowedBook['title'] == book.title && !borrowedBook['isReturned']) {
        borrowedBook['isReturned'] = true;
        book.isRented = false;
        book.availableDate = null;

        // Update the rent history entry to mark it as returned
        for (var history in rentHistory) {
          if (history['title'] == book.title &&
              history['renterName'] == borrowedBook['renterName']) {
            history['isReturned'] = true;
            break;
          }
        }

        DateTime now = DateTime.now();
        DateTime dueDate = borrowedBook['dueDate'];
        double lateFee =
            now.isAfter(dueDate) ? (now.difference(dueDate).inDays * 10) : 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lateFee > 0
                  ? 'Late Fee: ₱$lateFee'
                  : 'Book returned successfully.',
            ),
          ),
        );
        _saveRentHistory(); // Save updated rent history
        setState(() {});
        return;
      }
    }
  }

  Widget _buildOverdueBooksList() {
    List<Map<String, dynamic>> overdueBooks =
        borrowedBooks
            .where(
              (book) =>
                  !book['isReturned'] &&
                  book['dueDate'].isBefore(DateTime.now()),
            )
            .toList();

    return ListView.builder(
      itemCount: overdueBooks.length,
      itemBuilder: (context, index) {
        final overdueBook = overdueBooks[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 150,
                  child: Image.network(
                    overdueBook['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title: ${overdueBook['title']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Renter: ${overdueBook['renterName']}'),
                      Text('Contact Info: ${overdueBook['contact']}'),
                      Text('Rented on: ${overdueBook['rentedDate']}'),
                      Text('Due Date: ${overdueBook['returnDate']}'),
                      const Text(
                        'Late Fee: ₱10 per day',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRenterList() {
    List<Renter> renters = renterBox.values.toList();

    return ListView.builder(
      itemCount: renters.length,
      itemBuilder: (context, index) {
        final renter = renters[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => RenterBooksScreen(
                      renter: renter,
                      borrowedBooks: borrowedBooks,
                    ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name: ${renter.fullName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Contact: ${renter.contact}'),
                  TextButton(
                    onPressed: () => _deleteRenter(renter),
                    child: const Text(
                      'Delete Renter',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RenterBooksScreen extends StatelessWidget {
  final Renter renter;
  final List<Map<String, dynamic>> borrowedBooks;

  const RenterBooksScreen({
    super.key,
    required this.renter,
    required this.borrowedBooks,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> renterBooks =
        borrowedBooks
            .where((book) => book['renterName'] == renter.fullName)
            .toList();
    renterBooks.sort((a, b) => a['title'].compareTo(b['title']));

    return Scaffold(
      appBar: AppBar(title: Text('${renter.fullName}\'s Rented Books')),
      body: ListView.builder(
        itemCount: renterBooks.length,
        itemBuilder: (context, index) {
          final book = renterBooks[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 150,
                    child: Image.network(book['imageUrl'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title: ${book['title']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Rented on: ${book['rentedDate']}'),
                        Text('Due Date: ${book['returnDate']}'),
                        Text('Payment: ₱${book['payment']}'),
                        Text(
                          book['isReturned']
                              ? 'Status: Returned'
                              : 'Status: Not Returned',
                          style: TextStyle(
                            color:
                                book['isReturned'] ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
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

class RentHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> borrowedBooks;

  const RentHistoryScreen({super.key, required this.borrowedBooks});

  @override
  Widget build(BuildContext context) {
    final Box<List> rentHistoryBox = Hive.box<List>('rentHistory');
    List<Map<String, dynamic>> rentHistory =
        (rentHistoryBox.get('rentHistory', defaultValue: []) ?? [])
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    // Remove duplicates from rent history
    final uniqueRentHistory = <Map<String, dynamic>>[];

    // Use a set to track seen combinations of title and renterName
    final seen = <String>{};

    for (var entry in rentHistory) {
      // Create a unique key based on title and renterName
      String key = entry['title'] + entry['renterName'];
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueRentHistory.add(entry);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rent History')),
      body: ListView.builder(
        itemCount: uniqueRentHistory.length,
        itemBuilder: (context, index) {
          final book = uniqueRentHistory[index]; // Access the entry directly
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RentersForBookScreen(
                        bookTitle: book['title'],
                        borrowedBooks: borrowedBooks,
                      ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 150,
                      child: Image.network(book['imageUrl'], fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        book['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class RentersForBookScreen extends StatelessWidget {
  final String bookTitle;
  final List<Map<String, dynamic>> borrowedBooks;

  const RentersForBookScreen({
    super.key,
    required this.bookTitle,
    required this.borrowedBooks,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> rentersForBook =
        borrowedBooks.where((book) => book['title'] == bookTitle).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Renters for "$bookTitle"')),
      body: ListView.builder(
        itemCount: rentersForBook.length,
        itemBuilder: (context, index) {
          final renter = rentersForBook[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Renter Name: ${renter['renterName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Contact Info: ${renter['contact']}'),
                  Text('Rented on: ${renter['rentedDate']}'),
                  Text('Due Date: ${renter['returnDate']}'),
                  Text('Payment: ₱${renter['payment']}'),
                  Text(
                    renter['isReturned']
                        ? 'Status: Returned'
                        : 'Status: Not Returned',
                    style: TextStyle(
                      color: renter['isReturned'] ? Colors.green : Colors.red,
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
