Future<void> refreshPage(Future<void> Function() fetchFunction) async {
  await fetchFunction();
  await Future.delayed(const Duration(milliseconds: 100));
}
