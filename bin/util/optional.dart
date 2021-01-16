class Optional<T> {
  T data;
  Optional.empty() {
    this.data = null;
  }
  bool isPresent() {
    if (data == null) return false;
    return true;
  }

  Optional(this.data);
  Optional.of(data) {
    Type type = data.runtimeType;
    this.data = data;
  }
  T obt() {
    if (data == null) {
      throw NullThrownError();
    }
    return data;
  }
}
