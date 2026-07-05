import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_local_datasource.dart';
import '../models/alarm_model.dart';

/// Implementation of AlarmRepository using local SQLite datasource
class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDatasource _datasource;

  AlarmRepositoryImpl(this._datasource);

  @override
  Future<List<Alarm>> getAll() async {
    return await _datasource.getAll();
  }

  @override
  Future<Alarm> create(Alarm alarm) async {
    final model = AlarmModel.fromEntity(alarm);
    await _datasource.insert(model);
    return alarm;
  }

  @override
  Future<void> update(Alarm alarm) async {
    final model = AlarmModel.fromEntity(alarm);
    await _datasource.update(model);
  }

  @override
  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  @override
  Future<void> toggleEnabled(String id, bool isEnabled) async {
    await _datasource.toggleEnabled(id, isEnabled);
  }
}
