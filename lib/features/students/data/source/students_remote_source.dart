import 'dart:async';

import 'package:datn_mobile/features/students/data/dto/student_create_request_dto.dart';
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

  // GET /api/students/{studentId} - Get student by ID
  @GET("/api/students/{studentId}")
  Future<ServerResponseDto<StudentResponseDto>> getStudentById(
    @Path("studentId") String studentId,
  );

  // PUT /api/students/{studentId} - Update student
  @PUT("/api/students/{studentId}")
  Future<ServerResponseDto<StudentResponseDto>> updateStudent(
    @Path("studentId") String studentId,
    @Body() StudentUpdateRequestDto request,
  );

  // GET /api/classes/{classId}/students - Get students by class
  @GET("/api/classes/{classId}/students")
  Future<ServerResponseDto<List<StudentResponseDto>>> getStudentsByClass(
    @Path("classId") String classId,
  );

  // POST /api/classes/{classId}/students - Create and enroll student
  @POST("/api/classes/{classId}/students")
  Future<ServerResponseDto<StudentResponseDto>> createAndEnrollStudent(
    @Path("classId") String classId,
    @Body() StudentCreateRequestDto request,
  );

  // DELETE /api/classes/{classId}/students/{studentId} - Remove student from class
  @DELETE("/api/classes/{classId}/students/{studentId}")
  Future<ServerResponseDto<void>> removeStudentFromClass(
    @Path("classId") String classId,
    @Path("studentId") String studentId,
  );
}
