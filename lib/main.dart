import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiple_image_uploader/image_uploader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload multiple image with Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MultipleImageUploader(),
    );
  }
}

class MultipleImageUploader extends StatefulWidget {
  const MultipleImageUploader({Key? key}) : super(key: key);

  @override
  State<MultipleImageUploader> createState() => _MultipleImageUploaderState();
}

class _MultipleImageUploaderState extends State<MultipleImageUploader> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter multiple image upload'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  // height: 100,
                  constraints: BoxConstraints(
                    maxHeight: screenHeight / 3,
                  ),
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    // border: Border.all(color: Colors.blue)
                  ),
                  child: _buildImageList()
                ),

                IconButton.filledTonal(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final images = await picker.pickMultiImage();

                    // lakukan looping sebanyak jumlah image - do a looping process as much image length
                    for (final img in images) {
                      // simpan ke variabel ImageUploader.images - save into ImageUploader.images variable
                      ImageUploader.images.add(XFile(img.path));
                    }

                    setState(() {

                    });
                  },

                  icon: const Icon(Icons.camera_alt),
                ),
                const Text('Select image'),

                const SizedBox(height: 40,),
                IconButton.filledTonal(
                  onPressed: () async {

                    // abaikan saja variabel dataForServer - ignore the dataForServer variable
                    final dataForServer = {
                      "token": 'seller1-token-12345678',
                      "sellerId": '1',
                      "productId": '1',
                      "productName": 'Product 1',
                      "description": 'Product 1 Description',
                      "stock": '3',
                      "price": '1000',
                    };

                    final uploadStatus = await ImageUploader.uploadImage(data: dataForServer);

                    final Map<String, dynamic> uploadStatusData = jsonDecode(uploadStatus);
                    print(uploadStatusData);
                  },

                  icon: const Icon(Icons.upload),
                ),

                const Text('Upload')
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget _buildImageList() {
    return CustomScrollView(
      slivers: [
        SliverGrid(
            delegate: SliverChildBuilderDelegate(
              childCount: ImageUploader.images.length,
              (context, index) {
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(left: 5, bottom: 10, right: 5),
                  decoration: const BoxDecoration(
                      // border: Border.all(color: Colors.red)
                  ),
                  child: Image.file(
                    File(ImageUploader.images[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4
            )
        )
      ],
    );
  }
}