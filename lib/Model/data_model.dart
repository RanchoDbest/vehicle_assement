import 'package:hive/hive.dart';
part 'data_model.g.dart';
@HiveType(typeId: 1)
class DataModel{
	@HiveField(0)
	 late final int average;
	@HiveField(1)
	 late final int years;

	DataModel({required this.average, required this.years});
}