import '../../../../core/exceptions/api_exception.dart';
import '../base/base_success_response_mapper.dart';

class JsonObjectSuccessResponseMapper<T>
    implements BaseSuccessResponseMapper<T, T> {
  @override
  T mapToDataModel(dynamic response, Decoder<T>? decoder) {
    return decoder != null && response is Map<String, dynamic>
        ? decoder(response)
        : throw ApiException(
            kind: ApiExceptionKind.invalidSuccessResponseMapperType,
            rootException: '$response is not a JSONObject',
          );
  }
}
