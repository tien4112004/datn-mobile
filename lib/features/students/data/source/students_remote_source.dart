import 'dart:async';
import 'dart:io';

import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_import_response_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_response_dto.dart';
import 'package:datn_mobile/features/students/data/dto/student_update_request_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'students_remote_source.g.dart';

@RestApi()
abstract class StudentsRemoteSource {
  factory StudentsRemoteSource(Dio dio, {String baseUrl}) =
      _StudentsRemoteSource;

  // GET /students/{studentId} - Get student by ID
  @GET("/students/{studentId}")
  Future<ServerResponseDto<StudentResponseDto>> getStudentById(
    @Path("studentId") String studentId,
  );

  // PUT /students/{studentId} - Update student
  @PUT("/students/{studentId}")
  Future<ServerResponseDto<StudentResponseDto>> updateStudent(
    @Path("studentId") String studentId,
    @Body() StudentUpdateRequestDto request,
  );

  // GET /classes/{classId}/students - Get students by class
  @GET("/classes/{classId}/students")
  Future<ServerResponseDto<List<StudentResponseDto>>> getStudentsByClass(
    @Path("classId") String classId,
    @Query('page') int page,
    @Query('size') int size,
  );

  // POST /classes/{classId}/students - Create and enroll student
  @POST("/classes/{classId}/students")
  Future<ServerResponseDto<StudentResponseDto>> createAndEnrollStudent(
    @Path("classId") String classId,
    @Body() StudentCreateRequestDto request,
  );

  // POST /classes/{classId}/students/import - Import students
  @POST("/classes/{classId}/students/import")
  @MultiPart()
  Future<ServerResponseDto<StudentImportResponseDto>> importStudents(
    @Path("classId") String classId,
    @Part(name: "file") File file,
  );

  // DELETE /classes/{classId}/students/{studentId} - Remove student from class
  @DELETE("/classes/{classId}/students/{studentId}")
  Future<ServerResponseDto<void>> removeStudentFromClass(
    @Path("classId") String classId,
    @Path("studentId") String studentId,
  );
}
