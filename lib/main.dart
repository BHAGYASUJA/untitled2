
import 'package:flutter/material.dart';
import 'package:untitled2/sqlHelper.dart';

void main(){
  runApp(const MaterialApp(home: MainSQl(),));
}


class MainSQl extends StatefulWidget {
  const MainSQl({Key? key}) : super(key: key);

  @override
  State<MainSQl> createState() => _MainSQlState();
}

class _MainSQlState extends State<MainSQl> {
  bool isloading = true;

  List<Map<String, dynamic>> note_from_db = [];

  @override
  void initState() { ///refershing UI
    refershData();
    super.initState();
  }

  void refershData() async{
    final datas = await SQLHelper.readNotes();

    setState(() {
      note_from_db =datas;
      isloading = false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact App"),
      ),
      body: isloading
          ? CircularProgressIndicator(

      )
          : ListView.builder(
          itemCount: note_from_db.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(note_from_db[index]['title']),
                subtitle: Text(note_from_db[index]['note']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showForm(note_from_db[index]['id']);
                          }, icon: Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            deleteNote(note_from_db[index]['id']);
                          }, icon: Icon(Icons.delete)),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }

  final title = TextEditingController();
  final note = TextEditingController();
  void showForm(int? id) async {
    if(id != null) {
      final exitingNote = note_from_db.firstWhere((note) => note['id'] == id);
      title.text = exitingNote['title'];
      note.text = exitingNote['note'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 3,
        isScrollControlled: true,
        builder: (context) => Container(
          padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                    hintText: "Name", border: OutlineInputBorder()),
              ),
              TextField(
                controller: note,
                decoration: InputDecoration(
                    hintText: "Mobile Number", border: OutlineInputBorder()),
              ),
              ElevatedButton(onPressed: () async{
                if(id == null){
                  await addNote();
                }
                if(id!=null){
                  await updateNote(id);
                }
                title.text = "";
                note.text = "";
                Navigator.of(context).pop();
              }, child: Text(id==null ? 'Add Contact' : "update"))
            ],
          ),
        ));
  }
//future will have
  Future addNote() async{
    await SQLHelper.createNote(title.text,note.text);
    refershData();
  }

  Future <void> updateNote(int id) async{
    await SQLHelper.updateNote(id,title.text,note.text);
    refershData();
  }

  void deleteNote(int id) async{
    await SQLHelper.deletenote(id);
    ///Delete msg floating show to them
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Contact Deleted")));
    refershData();
  }
}
