import '../../../../core/all.dart';
import '../../../../models/base/paginated_list.dart';
import '../base/base_success_response_mapper.dart';

class PaginatedListSuccessResponseMapper<T>
    implements BaseSuccessResponseMapper<T, PaginatedList<T>> {
  @override
  PaginatedList<T> mapToDataModel(dynamic response, Decoder<T>? decoder) {
    if (decoder != null &&
        response is Map<String, dynamic> &&
        response.containsKey('data') &&
        response.containsKey('pagination')) {
      final pagination = response['pagination'] as Map<String, dynamic>;

      return PaginatedList<T>(
        items: (response['data'] as List)
            .map((dynamic jsonObject) => decoder(jsonObject))
            .toList(growable: false),
        currentPage: pagination['page'] as int,
        pageSize: pagination['per_page'] as int,
        isLastPage: !(pagination['hasMorePage'] as bool),
      );
    }

    throw ApiException(
      kind: ApiExceptionKind.invalidSuccessResponseMapperType,
      rootException: '$response is not a JSONArray',
    );
  }
}
