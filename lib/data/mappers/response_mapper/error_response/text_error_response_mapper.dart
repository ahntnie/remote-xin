import '../../../../core/exceptions/api_exception.dart';
import '../base/base_error_response_mapper.dart';

class PlainTextErrorResponseMapper extends BaseErrorResponseMapper<String> {
  @override
  ServerError mapToServerError(String? errorResponse) {
    return ServerError(
      message: errorResponse,
    );
  }
}
