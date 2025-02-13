import 'dart:convert';

import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/calendar.dart';
import 'package:timely/selection.dart';
import 'package:timely/themes/themes.dart';
import 'package:timely/widgets/objects/majorobject.dart';
import 'package:timely/widgets/text.dart';

class ColorEditor extends StatefulWidget {
  final String majorId, majorLbl, loverMajorId;
  final bool grp, lover;
  const ColorEditor(
      {Key? key,
      required this.majorId,
      required this.majorLbl,
      required this.grp,
      required this.loverMajorId,
      required this.lover})
      : super(key: key);

  @override
  _ColorEditorState createState() => _ColorEditorState();
}

class _ColorEditorState extends State<ColorEditor> {
  Color tpcolor = Colors.red, tdcolor = Colors.blue, ccolor = Colors.green;
  late IconData darkModeIcon;
  late IconData loverModeIcon;
  late bool loverModeIsActive = widget.lover;
  List<Major> listToSearch = [];
  List<String> listOfMajors = [];
  String selectedMajor = "";

  @override
  void initState() {
    super.initState();

    loverModeIsActive = widget.lover;
    if (!widget.lover) {
      loverModeIcon = Icons.sentiment_dissatisfied_rounded;
    } else {
      loverModeIcon = Icons.sentiment_satisfied_alt;
    }
    getColors("tp").then((value) {
      setState(() {
        tpcolor = Color(value);
      });
    });

    getColors("td").then((value) {
      setState(() {
        tdcolor = Color(value);
      });
    });

    getColors("c").then((value) {
      setState(() {
        ccolor = Color(value);
      });
    });

    gettingMajor();
  }

  String getMajorId(majorLbl) {
    String majorId = "";
    for (int i = 0; i < listToSearch.length; i++) {
      if (listToSearch[i].label == majorLbl) {
        majorId = listToSearch[i].majorId;
      }
    }
    return majorId;
  }

  navigation() {
    if (loverModeIsActive && selectedMajor != "") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Calendar(
                grp: widget.grp,
                majorId: widget.majorId,
                majorLbl: widget.majorLbl,
                lover: loverModeIsActive,
                loverMajorId: getMajorId(selectedMajor),
              )));
    } else if (loverModeIsActive && selectedMajor == "") {
      final snackBar = SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text('You need to pick a major for your lover!!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Calendar(
                grp: true,
                majorId: widget.majorId,
                majorLbl: widget.majorLbl,
                lover: loverModeIsActive,
                loverMajorId: "",
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (DynamicTheme.of(context)!.themeId == AppThemes.Light.toInt()) {
      darkModeIcon = Icons.light_mode;
    } else {
      darkModeIcon = Icons.dark_mode;
    }
    return WillPopScope(
      onWillPop: () async {
        navigation();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              navigation();
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
            ),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //title
                SizedBox(
                  width: size.width * 0.8,
                  child: MyText(
                      mytext: "Customize your app",
                      textSize: 50.0,
                      myweight: FontWeight.w600,
                      mycolor: Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: size.height * 0.1,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: DynamicTheme.of(context)!.themeId ==
                                AppThemes.Light.toInt()
                            ? Colors.black12
                            : Colors.black26,
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                    color: DynamicTheme.of(context)!.themeId ==
                            AppThemes.Light.toInt()
                        ? Theme.of(context).backgroundColor
                        : const Color(0xff2d333d),
                  ),
                  width: size.width * 0.8,
                  //height: size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //lover mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "Lover mode",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          IconButton(
                            icon: Icon(loverModeIcon),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                if (loverModeIcon ==
                                    Icons.sentiment_dissatisfied_rounded) {
                                  loverModeIcon = Icons.sentiment_satisfied_alt;
                                } else {
                                  loverModeIcon =
                                      Icons.sentiment_dissatisfied_rounded;
                                }
                                loverModeIsActive = !loverModeIsActive;
                              });
                            },
                          ),
                        ],
                      ),
                      Visibility(
                        visible: loverModeIsActive,
                        child: SizedBox(
                          width: size.width * 0.70,
                          child: CustomSearchableDropDown(
                            padding: const EdgeInsets.all(5.0),
                            backgroundColor: const Color(0x19101010),
                            dropdownBackgroundColor: Colors.white,
                            primaryColor: Colors.black,
                            items: listOfMajors,
                            dropDownMenuItems: listOfMajors,
                            label: "Lover's major ",
                            suffixIcon: Icon(
                              Icons.arrow_drop_down_circle_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                            dropdownLabelStyle: const TextStyle(
                              fontFamily: 'Comforta',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                            labelStyle: TextStyle(
                              fontFamily: 'Comforta',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Theme.of(context).primaryColor,
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedMajor = value;
                                });
                              } else {
                                selectedMajor = "";
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      //TP COLOR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "TP color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 1, "TPs");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: tpcolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      //td color
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "TD color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 2, "TDs");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: tdcolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      //courses color
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "Courses color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 3, "Courses");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: ccolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //theme mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "Theme mode",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          IconButton(
                            icon: Icon(darkModeIcon),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                if (darkModeIcon == Icons.dark_mode) {
                                  darkModeIcon = Icons.light_mode;
                                  DynamicTheme.of(context)!
                                      .setTheme(AppThemes.Light);
                                } else {
                                  darkModeIcon = Icons.dark_mode;
                                  DynamicTheme.of(context)!
                                      .setTheme(AppThemes.Dark);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      //clear data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "Clear data",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          IconButton(
                            icon: const Icon(Icons.restore_page),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              showAlertDialog(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColorPicker1() => BlockPicker(
      pickerColor: tpcolor,
      onColorChanged: (color) {
        setState(() => this.tpcolor = color);
      });

  Widget buildColorPicker2() => BlockPicker(
      pickerColor: tdcolor,
      onColorChanged: (color) => setState(() => this.tdcolor = color));

  Widget buildColorPicker3() => BlockPicker(
      pickerColor: ccolor,
      onColorChanged: (color) => setState(() => this.ccolor = color));

  void pickColor(BuildContext context, int x, String type) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: MyText(
                mytext: "Pick A Color for your " + type,
                textSize: 22.0,
                myweight: FontWeight.normal,
                mycolor: Colors.black),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                x == 1
                    ? buildColorPicker1()
                    : x == 2
                        ? buildColorPicker2()
                        : buildColorPicker3(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        setColor();
                        final snackBar = SnackBar(
                          content: const Text('Color Saved!'),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {},
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(color: Colors.grey, width: 2.0)),
                        child: const MyText(
                            mytext: "Select",
                            textSize: 22.0,
                            myweight: FontWeight.normal,
                            mycolor: Colors.black),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(color: Colors.grey, width: 2.0)),
                        child: const MyText(
                            mytext: "Cancel",
                            textSize: 22.0,
                            myweight: FontWeight.normal,
                            mycolor: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  setColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("tp", tpcolor.value);
    await prefs.setInt("td", tdcolor.value);
    await prefs.setInt("c", ccolor.value);
  }

  Future<int> getColors(var type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int x = 0;
    if (null != prefs.getInt(type)) {
      x = prefs.getInt(type)!;
    }
    return x;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = FlatButton(
      child: const MyText(
          mytext: "NAAH",
          textSize: 14.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = FlatButton(
      child: const MyText(
          mytext: "HELL YEAH",
          textSize: 14.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      onPressed: () {
        reset();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Selection()));
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).backgroundColor,
      title: const MyText(
          mytext: "Highway To Clear Data",
          textSize: 20.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      content: MyText(
          mytext:
              "You sure you want to clear?\nThis means that all your saved schedules will be removed.",
          textSize: 16.0,
          myweight: FontWeight.bold,
          mycolor: Theme.of(context).primaryColor),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  reset() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    await pref.setBool('seen', true);
  }

  Future<List<Major>> getMajors() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: prefer_typing_uninitialized_variables
    var jsonData;
    List<Major> majors = [];
    jsonData = prefs.getString('major_key');

    jsonData = prefs.getString('major_key');
    majors = Major.decode(jsonData);

    return majors;
  }

  gettingMajor() async {
    await getMajors().then((value) {
      for (var item in value) {
        listToSearch.add(item);
        listOfMajors.add(item.label);
      }
    });
    setState(() {});
  }
}
