class Cmd<T> {
  int cmd;
  T? data;

  static int CMD_UPDATE_MOBILE_INFO = 1;

  Cmd(this.cmd, this.data);

  factory Cmd.fromJson(Map<String, dynamic> parsedJson) {
    return Cmd(
        parsedJson["cmd"],
        parsedJson["data"]
    );
  }
}