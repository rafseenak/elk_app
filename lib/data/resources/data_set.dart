class DataSet<T> {
  bool success;
  T? data;
  String? message;
  DataSet.success(this.data) : success = true;
  DataSet.error(this.message) : success = false;
}
