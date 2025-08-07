import 'package:event/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static showErrorMessage(String? message) => Fluttertoast.showToast(
    msg: message ?? 'Something error',
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: AppTheme.red,
    textColor: AppTheme.backgroundWhite,
    fontSize: 16.0,
  );
  static showSuccessMessage(String message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 3,
    backgroundColor: AppTheme.green,
    textColor: AppTheme.backgroundWhite,
    fontSize: 16.0,
  );
}
