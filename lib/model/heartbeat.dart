
class Heartbeat {
  String ip;
  int value;
  int time;

  Heartbeat(this.ip, this.value, this.time);

  factory Heartbeat.fromJson(Map<String, dynamic> parsedJson) {
    return Heartbeat(
        parsedJson["ip"],
        parsedJson["value"],
        parsedJson["time"]
    );
  }

  Map toJson() => {
    "ip": ip,
    "value": value,
    "time": time
  };
}