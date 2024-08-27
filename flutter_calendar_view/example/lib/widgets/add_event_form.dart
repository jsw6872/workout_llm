import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../app_colors.dart';
import '../constants.dart';
import '../extension.dart';
import 'custom_button.dart';
import 'date_time_selector.dart';

class AddOrEditEventForm extends StatefulWidget {
  final void Function(CalendarEventData)? onEventAdd;
  final CalendarEventData? event;

  const AddOrEditEventForm({
    super.key,
    this.onEventAdd,
    this.event,
  });

  @override
  _AddOrEditEventFormState createState() => _AddOrEditEventFormState();
}

class _AddOrEditEventFormState extends State<AddOrEditEventForm> {
  late DateTime _startDate = DateTime.now().withoutTime;
  late DateTime _endDate = DateTime.now().withoutTime;
  final List<String> _eventOptions1 = ["가슴", "등", "어깨", "팔"];
  String? _selectedEvent;

  DateTime? _startTime;
  DateTime? _endTime;

  Color _color = Colors.blue;

  final _form = GlobalKey<FormState>();

  late final _descriptionController = TextEditingController();
  late final _titleController = TextEditingController();
  late final _exerciseController = TextEditingController();
  late final _titleNode = FocusNode();
  late final _exerciseNode = FocusNode();
  late final _descriptionNode = FocusNode();

  final List<SetRecord> setRecords = [SetRecord(setNumber: 1, weight: '', reps: '')];

  @override
  void initState() {
    super.initState();
    _setDefaults();
  }

  @override
  void dispose() {
    _titleNode.dispose();
    _exerciseNode.dispose();
    _descriptionNode.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  void _addSet() {
    if (setRecords.length < 10) {
      setState(() {
        setRecords.add(SetRecord(setNumber: setRecords.length + 1, weight: '', reps: ''));
      });
    }
  }

  void _removeSet(int index) {
    if (setRecords.length > 1) {
      setState(() {
        setRecords.removeAt(index);
        for (int i = 0; i < setRecords.length; i++) {
          setRecords[i].setNumber = i + 1;
        }
        _updateDescription();
      });
    }
  }

  void _updateDescription() {
    String description = _exerciseController.text.trim() + "\n";
    for (var set in setRecords) {
      description += 'Set ${set.setNumber}  ${set.weight} kg    ${set.reps} 회\n';
    }
    _descriptionController.text = description.trim();
  }

  Widget _buildAddRemoveButton(int index) {
    bool isFirst = index == 0;
    return OutlinedButton(
      onPressed: isFirst ? _addSet : () => _removeSet(index),
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(10),
        side: BorderSide(color: Colors.black),
      ),
      child: Icon(isFirst ? Icons.add : Icons.remove, color: Colors.black),
    );
  }

  Widget _buildSetRow(SetRecord setRecord, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('Set ${setRecord.setNumber}', style: TextStyle(fontSize: 16)),
          SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    'kg',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16),
              onChanged: (value) {
                setRecord.weight = value;
                _updateDescription();
              },
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    '회',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16),
              onChanged: (value) {
                setRecord.reps = value;
                _updateDescription();
              },
            ),
          ),
          SizedBox(width: 20),
          _buildAddRemoveButton(index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DateTimeSelectorFormField(
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "Date",
                  ),
                  initialDateTime: _startDate,
                  onSelect: (date) {
                    _endDate = date.withoutTime;
                    _startDate = date.withoutTime;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  validator: (value) {
                    if (value == null || value == "") {
                      return "Please select start date.";
                    }
                    return null;
                  },
                  textStyle: TextStyle(
                    color: AppColors.black,
                    fontSize: 17.0,
                  ),
                  onSave: (date) {
                    _startDate = date ?? _startDate;
                    _endDate = _startDate;
                  },
                  type: DateTimeSelectionType.date,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  decoration: AppConstants.inputDecoration.copyWith(
                    hintText: "",
                    labelText: "운동 부위",
                    suffixIcon: DropdownButton<String>(
                      value: _selectedEvent,
                      icon: Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedEvent = newValue;
                          _titleController.text = newValue ?? '';
                        });
                      },
                      items: _eventOptions1
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 17.0,
                  ),
                  validator: (value) {
                    final title = value?.trim();
                    if (title == null || title == "") {
                      return "Please enter event title.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _exerciseController,
                  decoration: AppConstants.inputDecoration.copyWith(
                    labelText: "운동 종목",
                  ),
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 17.0,
                  ),
                  onChanged: (value) {
                    _updateDescription();  // 운동 종목이 변경될 때마다 Event Description 업데이트
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter exercise name.";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '세트 설정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '(${setRecords.length} / 10)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),
          Column(
            children: setRecords.asMap().entries.map((entry) {
              int index = entry.key;
              SetRecord setRecord = entry.value;
              return _buildSetRow(setRecord, index);
            }).toList(),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionNode,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 17.0,
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 10,
            maxLength: 1000,
            validator: (value) {
              if (value == null || value.trim() == "") {
                return "Please enter event description.";
              }
              return null;
            },
            decoration: AppConstants.inputDecoration.copyWith(
              hintText: "운동 요약",
            ),
          ),
          Row(
            children: [
              Text(
                "Event Color: ",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: _displayColorPicker,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: _color,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          CustomButton(
            onTap: _createEvent,
            title: widget.event == null ? "Add Event" : "Update Event",
          ),
        ],
      ),
    );
  }

  void _createEvent() {
    if (!(_form.currentState?.validate() ?? true)) return;

    _form.currentState?.save();

    final event = CalendarEventData(
      date: _startDate,
      endTime: _endTime,
      startTime: _startTime,
      endDate: _endDate,
      color: _color,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    widget.onEventAdd?.call(event);
    _resetForm();
  }

  void _setDefaults() {
    if (widget.event == null) return;

    final event = widget.event!;

    _startDate = event.date;
    _endDate = event.endDate;
    _startTime = event.startTime ?? _startTime;
    _endTime = event.endTime ?? _endTime;
    _titleController.text = event.title;
    _exerciseController.text = '';  // 운동 종목 초기화
    _descriptionController.text = event.description ?? '';
  }

  void _resetForm() {
    _form.currentState?.reset();
    _startDate = DateTime.now().withoutTime;
    _endDate = DateTime.now().withoutTime;
    _startTime = null;
    _endTime = null;
    _color = Colors.blue;
    setRecords.clear();
    setRecords.add(SetRecord(setNumber: 1, weight: '', reps: ''));
    _exerciseController.clear();

    if (mounted) {
      setState(() {});
    }
  }

  void _displayColorPicker() {
    var color = _color;
    showDialog(
      context: context,
      useSafeArea: true,
      barrierColor: Colors.black26,
      builder: (_) => SimpleDialog(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        contentPadding: EdgeInsets.all(20.0),
        children: [
          Text(
            "Select event color",
            style: TextStyle(
              color: AppColors.black,
              fontSize: 25.0,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            height: 1.0,
            color: AppColors.bluishGrey,
          ),
          ColorPicker(
            displayThumbColor: true,
            enableAlpha: false,
            pickerColor: _color,
            onColorChanged: (c) {
              color = c;
            },
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
              child: CustomButton(
                title: "Select",
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _color = color;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SetRecord {
  int setNumber;
  String weight;
  String reps;

  SetRecord({required this.setNumber, required this.weight, required this.reps});
}
