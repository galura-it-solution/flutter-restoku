String mapToQueryParams(Map<String, dynamic> data) {
  final List<String> params = [];

  data.forEach((key, value) {
    if (key == 'filters' && value is List) {
      for (int i = 0; i < value.length; i++) {
        final filter = value[i];
        if (filter is Map) {
          filter.forEach((fKey, fVal) {
            if (fVal is List) {
              for (int j = 0; j < fVal.length; j++) {
                params.add(
                  'filters[$i][$fKey][$j]=${Uri.encodeComponent(fVal[j].toString())}',
                );
              }
            } else {
              params.add(
                'filters[$i][$fKey]=${Uri.encodeComponent(fVal.toString())}',
              );
            }
          });
        }
      }
    } else if (value is List) {
      for (var item in value) {
        params.add('$key[]=${Uri.encodeComponent(item.toString())}');
      }
    } else {
      params.add('$key=${Uri.encodeComponent(value.toString())}');
    }
  });

  return params.join('&');
}
