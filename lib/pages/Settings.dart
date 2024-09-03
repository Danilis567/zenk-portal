import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20), // Başlık ile butonlar arasında boşluk
            SizedBox(height: 20), // Başlık ile butonlar arasında boşluk
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Çıkış Yap butonuna tıklanınca yapılacak işlemler
                      // Örneğin, çıkış yapma işlemini buraya ekleyebilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Arka plan rengi turuncu
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Köşe yuvarlaması
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Çıkış Yap',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Butonlar arasında boşluk
                  ElevatedButton(
                    onPressed: () {
                      // Sorun Bildir butonuna tıklanınca yapılacak işlemler
                      // Örneğin, bir sorun bildirme ekranı açabilirsiniz.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Arka plan rengi turuncu
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Köşe yuvarlaması
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sorun Bildir',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
