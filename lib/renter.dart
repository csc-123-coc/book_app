import 'package:hive/hive.dart';

part 'renter.g.dart'; // This will be generated

@HiveType(typeId: 1)
class Renter {
  @HiveField(0)
  final String fullName;

  @HiveField(1)
  final String contact;

  Renter({required this.fullName, required this.contact});
}
