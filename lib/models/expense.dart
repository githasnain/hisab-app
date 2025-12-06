import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title; // New: Expense Name

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String note;

  @HiveField(6)
  final String paymentMethod; // New: Cash, Card, etc.

  @HiveField(7)
  final List<String> imagePaths; // New: Photo support

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
    required this.paymentMethod,
    required this.imagePaths,
  });
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      title: fields.containsKey(1) ? fields[1] as String : 'Expense',
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      category: fields[4] as String,
      note: fields[5] as String,
      paymentMethod: fields.containsKey(6) ? fields[6] as String : 'Cash',
      imagePaths:
          fields.containsKey(7) ? (fields[7] as List).cast<String>() : [],
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.imagePaths);
  }
}
