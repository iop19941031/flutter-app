import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddJourneyPage extends StatefulWidget {
  // final DateTime time;

  // AddJourneyPage(this.time);

  @override
  _AddJourneyState createState() {
    return _AddJourneyState();
  }
}

class _AddJourneyState extends State<AddJourneyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _password = TextEditingController();

  DateTime _startTime = DateTime.now();
  bool _warn = false;

  TextFormField buildAccountFormField() {
    return TextFormField(
      controller: _title,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
            borderSide: BorderSide(
              color: Colors.green,
              width: 2,
            )),
        hintText: "事件标题",
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: _password,
      decoration: InputDecoration(
          labelText: "Password",
          hintText: "Your login password",
          prefixIcon: Icon(Icons.lock)),
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        onPressed: () {
          // if (_formKey.currentState.validate()) {
          //   final User user = new User(_title.text);
          //   callback(user);
          //   Navigator.pop(context);
          // } else {
          //   Scaffold.of(context).showSnackBar(SnackBar(content: Text('?????')));
          // }
        },
        child: Text('Sign In'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in"),
        centerTitle: true,
        leading: Icon(Icons.home),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            padding: EdgeInsets.only(right: 3),
            onPressed: () {
              print(222);
            },
          )
        ],
      ),
      body: Center(
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                buildAccountFormField(),
                // buildPasswordFormField(),
                // buildPadding(),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        _warn = !_warn;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '开始时间',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          Switch(
                            onChanged: (bool v) {
                              setState(() {
                                _warn = v;
                              });
                            },
                            value: _warn,
                          )
                        ])),
                FlatButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          theme: DatePickerTheme(
                              headerColor: Colors.orange,
                              backgroundColor: Colors.blue,
                              itemStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              doneStyle:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              cancelStyle:
                                  TextStyle(color: Colors.red, fontSize: 16)),
                          showTitleActions: true, onChanged: (DateTime date) {
                        print('change $date in time zone ' +
                            date.timeZoneOffset.inHours.toString());
                      }, onConfirm: (DateTime date) {
                        setState(() {
                          _startTime = date;
                        });
                      }, currentTime: _startTime, locale: LocaleType.zh);
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '开始时间',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${_startTime.year.toString()}-${_startTime.month.toString()}-${_startTime.day.toString()} '
                                '${_startTime.hour.toString()}:${_startTime.minute.toString()}',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              )
                            ],
                          )
                        ])),
              ],
            )),
      ),
    );
  }
}

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return "|";
  }

  @override
  String rightDivider() {
    return "|";
  }

  @override
  List<int> layoutProportions() {
    return [1, 2, 1];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            this.currentLeftIndex(),
            this.currentMiddleIndex(),
            this.currentRightIndex())
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            this.currentLeftIndex(),
            this.currentMiddleIndex(),
            this.currentRightIndex());
  }
}

typedef OnStateUserGet = Function();