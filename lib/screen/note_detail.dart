import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper_app/model/note.dart';
import 'package:notekeeper_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  String appBarTitle;

  final Note note;

  NoteDetail(this.appBarTitle, this.note);
  @override
  _NoteDetailState createState() =>
      _NoteDetailState(this.appBarTitle, this.note);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorites = ['High', 'Low'];

  String appBarTitle;

  DatabaseHelper helper = DatabaseHelper();

  Note note;

  var _formKey = GlobalKey<FormState>();

  _NoteDetailState(this.appBarTitle, this.note);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // DropDown
                ListTile(
                  title: DropdownButton(
                    items: _priorites.map((String dropDownItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownItem,
                        child: Text(dropDownItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelected) {
                      setState(() {
                        debugPrint('User selected $valueSelected');
                        updatePriorityAsInt(valueSelected);
                      });
                    },
                  ),
                ),

                // TextFiele title :
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: titleController,
                    style: textStyle,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please insert title';
                      }
                    },
                    onChanged: (value) {
                      debugPrint('something changed in title text field');

                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        errorStyle:
                            TextStyle(color: Colors.red, fontSize: 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Textfield description :
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: descriptionController,
                    style: textStyle,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please insert description';
                      }
                    },
                    onChanged: (value) {
                      debugPrint('something changed in description text field');

                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        errorStyle:
                            TextStyle(color: Colors.red, fontSize: 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Button-button
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    children: <Widget>[
                      // Button Save :
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            debugPrint('Save button clicked');

                            _save();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColorDark),
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                      )),

                      SizedBox(
                        width: 5,
                      ),

                      // Button Delete :
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            debugPrint('Delete button clicked');
                            _delete();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColorDark),
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    //  Tambahkan true
    // 20 .. pergi ke noteList ke navigate to detail ->
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorites[0]; // High
        break;
      case 2:
        priority = _priorites[1]; // low
        break;
    }

    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    note.date = DateFormat.yMMMd().format(DateTime.now());

    moveToLastScreen();

    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while deleting note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }
}
