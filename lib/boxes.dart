import 'package:hive/hive.dart';
import 'models/expense.dart';

class Boxes {
  static Box<Expense> getExpenses() => Hive.box<Expense>('expenses');
}
