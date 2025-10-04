// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 3;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      amount: fields[2] as double,
      month: fields[3] as DateTime,
      targetAmount: fields[4] as double?,
      alertThreshold: fields[5] as double,
      alertsEnabled: fields[6] as bool,
      rolloverEnabled: fields[7] as bool,
      carriedOverAmount: fields[8] as double,
      note: fields[9] as String?,
      userId: fields[10] as String?,
      isActive: fields[11] as bool,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.alertThreshold)
      ..writeByte(6)
      ..write(obj.alertsEnabled)
      ..writeByte(7)
      ..write(obj.rolloverEnabled)
      ..writeByte(8)
      ..write(obj.carriedOverAmount)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
