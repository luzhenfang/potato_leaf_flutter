
class Result {
  var code;
  var msg;
  var type;
  var conf;

  var color;

  Result(this.code, this.msg, this.type, this.conf);

  Result.parse(dynamic obj) {
    try {
      code = obj["code"];
      msg = obj["msg"];
      type = obj["type"];
      conf = obj["conf"];
    } catch (e) {
      // print("parse Error:" + e.toString());
    }
  }
}
