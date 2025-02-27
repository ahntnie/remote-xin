import '../../../../core/exceptions/api_exception.dart';
import '../base/base_success_response_mapper.dart';

class DataJsonObjectSuccessResponseMapper<T>
    implements BaseSuccessResponseMapper<T, T> {
  @override
  T mapToDataModel(dynamic response, Decoder<T>? decoder) {
    return decoder != null &&
            response is Map<String, dynamic> &&
            response['data'] is Map<String, dynamic>
        ? decoder(response['data'])
        : throw ApiException(
            kind: ApiExceptionKind.invalidSuccessResponseMapperType,
            rootException: '$response is not a DataJSONObject',
          );
  }
}
