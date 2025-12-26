import 'package:datn_mobile/features/classes/data/dto/class_create_request_dto.dart';
import 'package:datn_mobile/features/classes/data/dto/class_list_response_dto.dart';
import 'package:datn_mobile/features/classes/data/source/class_remote_data_source.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/domain/repository/class_repository.dart';

/// Implementation of ClassRepository using remote data source.
class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDataSource _remoteDataSource;

  ClassRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ClassEntity>> getClasses({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool? isActive,
  }) async {
    final response = await _remoteDataSource.getClasses(
      page: page,
      pageSize: pageSize,
      search: search,
      isActive: isActive,
    );
    final dtos = response.data ?? [];
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<ClassEntity> createClass({
    required String name,
    String? description,
    String? settings,
  }) async {
    final request = ClassCreateRequestDto(
      name: name,
      description: description,
      settings: settings,
    );
    final response = await _remoteDataSource.createClass(request);
    return response.data!.toEntity();
  }

  @override
  Future<ClassEntity> joinClass({required String joinCode}) async {
    // TODO: Implement join class API when endpoint is available
    throw UnimplementedError('Join class API not yet implemented');
  }

  @override
  Future<ClassEntity> getClassById(String classId) async {
    final response = await _remoteDataSource.getClassById(classId);
    return response.data!.toEntity();
  }

  @override
  Future<ClassEntity> updateClass({
    required String classId,
    String? name,
    String? description,
    String? settings,
    bool? isActive,
  }) async {
    final Map<String, dynamic> request = {};

    if (name != null) request['name'] = name;
    if (description != null) request['description'] = description;
    if (settings != null) request['settings'] = settings;
    if (isActive != null) request['isActive'] = isActive;

    final response = await _remoteDataSource.updateClass(classId, request);
    return response.data!.toEntity();
  }
}
