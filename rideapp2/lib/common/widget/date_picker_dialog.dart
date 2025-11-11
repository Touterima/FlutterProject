import 'package:flutter/material.dart';

class DatePickerDialogBOx extends StatefulWidget {
  const DatePickerDialogBOx({super.key});

  @override
  _DatePickerDialogBoxState createState() => _DatePickerDialogBoxState();
}

class _DatePickerDialogBoxState extends State<DatePickerDialogBOx> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Date Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            child: Text(fromDate != null
                ? 'From Date: ${fromDate.toString().split(' ')[0]}'
                : 'Select From Date'),
            onPressed: () => _selectDate(context, true),
          ),
          ElevatedButton(
            child: Text(toDate != null
                ? 'To Date: ${toDate.toString().split(' ')[0]}'
                : 'Select To Date'),
            onPressed: () => _selectDate(context, false),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            // Do something with the selected dates
            print('From Date: $fromDate');
            print('To Date: $toDate');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
