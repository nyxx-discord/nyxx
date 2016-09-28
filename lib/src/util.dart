/// Gets a DateTime from a snowflake ID.
DateTime getDate(String id) {
  return new DateTime.fromMillisecondsSinceEpoch(((int.parse(id) / 4194304) + 1420070400000).toInt());
}
