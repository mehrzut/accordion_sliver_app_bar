extension ListExt<T> on List<T> {
  List<List<T>> splitAtNotContaining(int index) {
    return [sublist(0, index), sublist(index + 1)];
  }

  List<T> addOrUpdateWhere(
    bool Function(T e) condition,
    T Function(T? e) updatedItemGenerator,
  ) {
    if (any((e) => condition(e))) {
      return map((e) => condition(e) ? updatedItemGenerator(e) : e).toList();
    } else {
      return [...this, updatedItemGenerator(null)];
    }
  }
}
