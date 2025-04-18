import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/controllers/date_time_controller.dart';

class DateTimeWidget extends StatelessWidget {
  DateTimeWidget({super.key});
  final DateTimeController dateTimeController = Get.put(DateTimeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateTimeController.formattedDay.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  Text(
                    dateTimeController.formattedDate.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Image.asset('assets/images/Crystal Gold Logo-01.png', height: 80)),
            Expanded(
              child: Text(
                dateTimeController.formattedTime.value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        ));
  }
}