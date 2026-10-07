import 'package:flutter/material.dart';
class FilmCardItem extends StatelessWidget {
  final String title;
  final String imagepath;
  const FilmCardItem({super.key, required this.title, required this.imagepath});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child:Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Image.asset("assets/images/$imagepath"),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  Icon(Icons.star,color: Colors.amber,size: 25,)
                ],
              ),
            )
          ],
        ),
      ) ,
    );
  }
}
