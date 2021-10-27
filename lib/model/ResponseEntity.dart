

class ResponseEntity<T> {
  int code = -1;
  int cmd = 0;
  String? msg;
  T? data;
}