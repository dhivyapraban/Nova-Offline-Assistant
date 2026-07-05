import '../../domain/entities/timer_entity.dart';
import '../../domain/repositories/timer_repository.dart';
import '../datasources/timer_local_datasource.dart';
import '../models/timer_model.dart';

class TimerRepositoryImpl implements TimerRepository {
  final TimerLocalDatasource _datasource;
  TimerRepositoryImpl(this._datasource);

  @override
  Future<List<TimerEntity>> getAll() => _datasource.getAll();

  @override
  Future<TimerEntity> create(TimerEntity timer) async {
    await _datasource.insert(TimerModel.fromEntity(timer));
    return timer;
  }

  @override
  Future<void> update(TimerEntity timer) async {
    await _datasource.update(TimerModel.fromEntity(timer));
  }

  @override
  Future<void> delete(String id) => _datasource.delete(id);

  @override
  Future<void> deleteAll() => _datasource.deleteAll();
}

