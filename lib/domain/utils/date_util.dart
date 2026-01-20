class DateUtil {
  static String dateFormatter(
    DateTime date, {
    bool withDay = false,
    bool withTime = false,
  }) {
    int wd = date.weekday;
    String day = "";
    switch (wd) {
      case 1:
        day = "Lundi";
      case 2:
        day = "Mardi";
      case 3:
        day = "Mercredi";
      case 4:
        day = "Jeudi";
      case 5:
        day = "Vendredi";
      case 6:
        day = "Samedi";
      case 7:
        day = "Dimanche";
        break;
      default:
        day = "Lundi";
    }
    String dd = date.day.toString().padLeft(2, "0");
    String mm = date.month.toString().padLeft(2, "0");
    String yyyy = date.year.toString();
    String time =
        "${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}";
    return "${withDay ? "$day " : ""}$dd/$mm/$yyyy${withTime ? ", $time" : ""}";
  }
}
