import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Campus Connect',
    theme: ThemeData(
      fontFamily: 'Poppins',
    ),
    debugShowCheckedModeBanner: false,
    home: pageAccueil(),
  ));
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/primaryBg.png'),
              fit: BoxFit.cover,
            )),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 120,
                left: 30,
                child: Container(
                  child: Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 68,
                        fontFamily: 'Poppins-Medium',
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                )),
           // Positioned(top: 210, right: 0, bottom: 0, child: LayerOne()),
            //Positioned(top: 238, right: 0, bottom: 28, child: LayerTwo()),
            //Positioned(top: 240, right: 0, bottom: 38, child: LayerThree()),
          ],
        ),
      ),
    );
  }
}
class pageAccueil extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Stack(
      children:<Widget>[
        //Positioned(top: 210, right: 0, bottom: 0, child: LayerOne()),
      DefaultTabController
      (length: 3,
      child: Scaffold
        (appBar: AppBar(
        foregroundColor: Colors.white,

        bottom: TabBar(
          labelColor: Colors.amberAccent[400],

          unselectedLabelColor: Colors.grey[300],

          indicatorColor: Colors.amberAccent[400],

          tabs: const [
            Tab(icon: Icon(Icons.calendar_month)),
            Tab(icon: Icon(Icons.person)),
            Tab(icon: Icon(Icons.grade)),
          ],
        ),
      ),
          body:TabBarView(
              children:[
                Center(child:Text('this is Schedule page')),
                Center(child:stdCard(
                  name:'Bassem BENSID',
                  stdId:3108200425,
                  btdate:"31/08/2004",
                  photo:"images/MyPh.jpg",
                  Specialte:"MI",
                  Branche:"Technologies de l'information",
                  section:1,
                  groupe:1,
                )
                ),
                Center(
                    child:Text('this is Marks page'),
                ),
              ]
          )
      ),
    )
      ]
    );
}
}
class stdCard extends StatelessWidget {
  String name;
  int stdId;
  String btdate;
  String photo;
  String Specialte;
  String Branche;
  int section;
  int groupe;

  stdCard({
    required this.name,
    required this.stdId,
    required this.btdate,
    required this.photo,
    required this.Specialte,
    required this.Branche,
    required this.section,
    required this.groupe,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'images/NTICDRAW.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // card content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child:Card(
                      color:Colors.cyan.withOpacity(0.3),
                      child:
                      Row(
                       children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              _buildInfoRow("ID:", stdId.toString()),
                              _buildInfoRow("Date de naissance:", btdate),
                              _buildInfoRow("Spécialité:", Specialte),
                              _buildInfoRow("Branche:", Branche),
                              _buildInfoRow("Section:", section.toString()),
                              _buildInfoRow("Groupe:", groupe.toString()),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                photo,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
