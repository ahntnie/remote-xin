abstract class BaseDataMapper<D, E> {
  const BaseDataMapper();

  E mapToEntity(D data);

  List<E> mapToListEntity(List<D>? listData) {
    return listData?.map(mapToEntity).toList() ?? List.empty();
  }
}

/// Optional: if need map from entity to  data
mixin DataMapperMixin<D, E> on BaseDataMapper<D, E> {
  D mapToData(E entity);

  D? mapToNullableData(E? entity) {
    if (entity == null) {
      return null;
    }

    return mapToData(entity);
  }

  List<D>? mapToNullableListData(List<E>? listEntity) {
    return listEntity?.map(mapToData).toList();
  }

  List<D> mapToListData(List<E>? listEntity) {
    return mapToNullableListData(listEntity) ?? List.empty();
  }
}
