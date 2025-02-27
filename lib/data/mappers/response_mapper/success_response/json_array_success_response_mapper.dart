import '../../../../core/exceptions/api_exception.dart';
import '../base/base_success_response_mapper.dart';

class JsonArraySuccessResponseMapper<T>
    implements BaseSuccessResponseMapper<T, List<T>> {
  @override
  List<T> mapToDataModel(dynamic response, Decoder<T>? decoder) {
    return decoder != null && response is List
        ? response
            .map((dynamic jsonObject) => decoder(jsonObject))
            .toList(growable: false)
        : throw ApiException(
            kind: ApiExceptionKind.invalidSuccessResponseMapperType,
            rootException: '$response is not a JSONArray',
          );
  }
}
