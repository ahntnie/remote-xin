import '../../../../core/exceptions/api_exception.dart';
import '../base/base_success_response_mapper.dart';

class PlainResponseMapper<T> extends BaseSuccessResponseMapper<T, T> {
  @override
  T mapToDataModel(response, Decoder<T>? decoder) {
    assert(decoder == null);
    if (response is T) {
      return response;
    } else {
      throw ApiException(
        kind: ApiExceptionKind.invalidSuccessResponseMapperType,
        rootException: 'Response is not $T',
      );
    }
  }
}
