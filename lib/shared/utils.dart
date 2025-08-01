class Utility{
  static String getCurrentSemesterId() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 1 && month <= 5) return 'Spring$year';
    if (month >= 6 && month <= 7) return 'Summer$year';
    return 'Fall$year';
  }
}