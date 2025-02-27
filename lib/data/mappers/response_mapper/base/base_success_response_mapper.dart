import '../success_response/all.dart';

typedef Decoder<T> = T Function(Object? data);

enum SuccessResponseMapperType {
  jsonObject,
  jsonArray,
  paginatedList,
  dataJsonObject,
  plain,
}

abstract class BaseSuccessResponseMapper<I, O> {
  const BaseSuccessResponseMapper();

  factory BaseSuccessResponseMapper.fromType(SuccessResponseMapperType type) {
    switch (type) {
      case SuccessResponseMapperType.jsonObject:
        return JsonObjectSuccessResponseMapper<I>()
            as BaseSuccessResponseMapper<I, O>;
      case SuccessResponseMapperType.jsonArray:
        return JsonArraySuccessResponseMapper<I>()
            as BaseSuccessResponseMapper<I, O>;
      case SuccessResponseMapperType.paginatedList:
        return PaginatedListSuccessResponseMapper<I>()
            as BaseSuccessResponseMapper<I, O>;
      case SuccessResponseMapperType.dataJsonObject:
        return DataJsonObjectSuccessResponseMapper<I>()
            as BaseSuccessResponseMapper<I, O>;
      case SuccessResponseMapperType.plain:
        return PlainResponseMapper<I>() as BaseSuccessResponseMapper<I, O>;
    }
  }

  O mapToDataModel(dynamic response, Decoder<I>? decoder);
}
