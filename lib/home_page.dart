import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/db/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;
  TextEditingController noteTitleController = TextEditingController();
  TextEditingController noteDescController = TextEditingController();
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  void updateErrorMsg() {
    setState(() {
      errorMsg = "Please fill all the required fields";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      //Notes viewed here
      body: allNotes.isNotEmpty
          ? ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  iconColor: index % 2 != 0
                      ? Colors.lightGreen[200]
                      : Colors.lightGreen[400],
                  tileColor:
                      index % 2 != 0 ? Colors.grey[400] : Colors.grey[200],
                  leading: Text("${index + 1}"),
                  title: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  "${allNotes[index][DbHelper.COLUMN_NOTE_TITLE]}"),
                          TextSpan(
                              text:
                                  "  ${DateFormat('MMMEd').format(DateTime.now())}",
                              style: const TextStyle(fontSize: 12)),
                        ]),

                    // allNotes[index][DbHelper.COLUMN_NOTE_TITLE] +
                    //     "    ${DateFormat('MMMd').format(DateTime.now())}",
                    // style: const TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black87,
                    //     fontSize: 18,
                    //     letterSpacing: 1.5),
                  ),
                  subtitle: Text(
                    allNotes[index][DbHelper.COLUMN_NOTE_DESC],
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: (c) {
                                  noteTitleController.text = allNotes[index]
                                      [DbHelper.COLUMN_NOTE_TITLE];
                                  noteDescController.text = allNotes[index]
                                      [DbHelper.COLUMN_NOTE_DESC];
                                  return getBottomSheetView(
                                      isUpdate: true,
                                      sno: allNotes[index]
                                          [DbHelper.COLUMN_NOTE_SNO]);
                                });
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        InkWell(
                          onTap: () async {
                            bool check = await dbRef!.deleteNote(
                                sno: allNotes[index][DbHelper.COLUMN_NOTE_SNO]);
                            if (check) {
                              getNotes();
                            }
                          },
                          child: Icon(
                            Icons.delete,
                            color: Colors.red[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // trailing: const Row(
                  //   children: [Icon(Icons.delete), Icon(Icons.check_box)],
                  // ),
                );
              })
          : const Center(
              child: Text("No notes yet"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Notes to be added
          // bool check = await dbRef!
          //     .addNote(mTitle: "First note", mDesc: "This is a test note");
          // if (check) {
          //   getNotes();
          // }
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                noteTitleController.clear();
                noteDescController.clear();
                return getBottomSheetView();
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.lightGreen,
        ),
      ),
    );
  }

  Widget getBottomSheetView({bool isUpdate = false, int sno = 0}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 +
          MediaQuery.of(context).viewInsets.bottom,
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 11,
        top: 11,
        bottom: 11 + MediaQuery.of(context).viewInsets.bottom,
        right: 11,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isUpdate ? "Update Note" : "Add Note",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 11,
          ),
          TextField(
            //keyboardType: const TextInputType.numberWithOptions(),
            controller: noteTitleController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                hintText: "Enter a title",
                label: const Text("*Title"),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11))),
          ),
          const SizedBox(
            height: 11,
          ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: noteDescController,
            decoration: InputDecoration(
              hintText: "Enter your description",
              hintMaxLines: 4,
              label: const Text("*Description"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            maxLines: 4,
          ),
          const SizedBox(
            height: 11,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    var mTitle = noteTitleController.text;
                    var mDesc = noteDescController.text;
                    if (mTitle.isNotEmpty && mDesc.isNotEmpty) {
                      bool check = isUpdate
                          ? await dbRef!
                              .updateNote(title: mTitle, desc: mDesc, sno: sno)
                          : await dbRef!.addNote(title: mTitle, desc: mDesc);

                      if (check) {
                        getNotes();
                      }
                    } else {
                      //updateErrorMsg();
                      errorMsg = "Please fill all the required (*) field";
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(errorMsg)));
                    }
                    noteTitleController.clear();
                    noteDescController.clear();

                    Navigator.pop(context);
                  },
                  child: Text(isUpdate ? "Update" : "Add Note"),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 11,
          ),
          // Text(errorMsg),
        ],
      ),
    );
  }
}
