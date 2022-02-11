class Cmd<T> {
  int cmd;
  T? data;

  static int CMD_UPDATE_MOBILE_INFO = 1;
  static int CMD_REPORT_DESKTOP_INFO = 2;

  Cmd(this.cmd, this.data);

  factory Cmd.fromJson(Map<String, dynamic> parsedJson) {
    return Cmd(
        parsedJson["cmd"],
        parsedJson["data"]
    );
  }

  Map<String, dynamic> toJson() => {
    "cmd": cmd,
    "data": data,
  };
}