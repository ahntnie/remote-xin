import '../../../../core/all.dart';
import '../base/base_error_response_mapper.dart';

class JsonObjectErrorResponseMapper
    extends BaseErrorResponseMapper<Map<String, dynamic>> {
  @override
  ServerError mapToServerError(Map<String, dynamic>? errorResponse) {
    return ServerError(
      errorCode: errorResponse?['errorCode'] as String?,
      message: errorResponse?['message'] as String?,
      fieldErrors:
          _mapToFieldErrors(errorResponse?['fields'] as Map<String, dynamic>?),
      code: errorResponse?['code']?.toString(),
    );
  }

  List<ServerFieldError> _mapToFieldErrors(
    Map<String, dynamic>? errorResponse,
  ) {
    if (errorResponse == null) {
      return [];
    }

    /*
    "fields": {
        "field_name": [message]
    }
    */

    return errorResponse.entries
        .map(
          (entry) => ServerFieldError(
            field: entry.key,
            messages: (entry.value as List<dynamic>)
                .map((dynamic message) => message as String)
                .toList(),
          ),
        )
        .toList();
  }
}
