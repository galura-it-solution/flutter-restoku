import 'package:slims/infrastructure/models/query_parametes.model.dart';

extension QueryParametesModelDefaults on QueryParametesModel {
  static QueryParametesModel initial() {
    return const QueryParametesModel(
      search: "",
      searchFields: [],
      filters: [],
      orderKey: "id",
      orderBy: "asc",
      fieldRange: "",
      from: "",
      to: "",
      page: 1,
      pageSize: 5,
    );
  }
}
