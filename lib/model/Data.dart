import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class DataBird with ChangeNotifier {
  String speed;
  String high;
  String lt;
  String lg;

  void setData(String _speed, String _high, String _lt, String _lg) {
    speed = _speed;
    high = _high;
    lt = _lt;
    lg = _lg;
    notifyListeners();
  }
}
