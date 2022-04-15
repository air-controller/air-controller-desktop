class ResponseEntity<T> {
  int code = -1;
  String? msg;
  T? data;

  static const CODE_SUCCESS = 0;

  ResponseEntity(this.code, this.msg, this.data);

  factory ResponseEntity.fromJson(Map<String, dynamic> parsedJson) {
    return ResponseEntity(parsedJson["code"], parsedJson["msg"], parsedJson["data"]);
  }

  bool isSuccessful() {
    return code == CODE_SUCCESS;
  }
}