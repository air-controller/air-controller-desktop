import 'dart:collection';

class StackQueue<T> {
  final _stack = Queue<T>();

  void push(T element) {
    _stack.addLast(element);
  }
  
  T pop() {
    final T lastElement = _stack.last;
    _stack.removeLast();
    return lastElement;
  }

  T? takeLast() {
    List<T> list = _stack.toList();
    if (list.length > 1) {
      return list[list.length - 2];
    }

    return null;
  }

  /**
   * 回退到指定的栈数据
   *
   * @param data 栈数据目标
   */
  bool popTo(T data) {
    while (_stack.isNotEmpty) {
      T current = _stack.last;
      if (current == data) return true;

      _stack.removeLast();
    }

    return false;
  }

  bool contains(T data) => _stack.contains(data);

  int get length => _stack.length;

  List<T> toList() {
    return _stack.toList();
  }

  void clear() {
    _stack.clear();
  }
  
  bool get isEmpty => _stack.isEmpty;
  
  bool get isNotEmpty => !isEmpty;
}