import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ImageUploader {
  static const _timeOutConnection = 15;
  static const _host = 'http://10.0.2.2/image_uploader/image_uploader.php';

  static List<XFile> images = [];

  static Future<String> uploadImage({required Map<String, String> data}) async {
    late Future<String> serverResponse;

    int? statusCode;

    if (images.isNotEmpty) {
      // create multipart request

      Map<String, String> payload = {
        "sellerId": data["sellerId"]!,
        "productName": data['productName']!,
        "description": data['description']!,
        "price": data['price']!,
        "stock": data['stock']!,
        "token": data["token"]!
      };

      var request = http.MultipartRequest('POST', Uri.parse(_host));

      request.fields.addAll(payload);

      for (final img in images) {
        final imageName = img.path.split("/").last;
        final stream = File(img.path).readAsBytes().asStream();
        final length = File(img.path).lengthSync();

        // print('image name to send: $imageName');

        request.files.add(
          // userfile adalah key, digunakan juga di sisi server - userfile is the key, also used in the server side
          // http.MultipartFile('userfile', stream, length, filename: imageName) // to upload to Flask
            http.MultipartFile('userfile[]', stream, length, filename: imageName) // to upload to PHP
        );
      }

      // send data
      try {
        var streamResponse = await request.send().timeout(
          // http timeout reference:  https://stackoverflow.com/a/61542200/22171100
            const Duration(seconds: _timeOutConnection),
            onTimeout: () {
              return http.StreamedResponse(Stream.value([]), 408); // Request Timeout response status code
            }
        );

        if (streamResponse.statusCode == 200) {

          // reference: https://stackoverflow.com/a/69909117/22171100
          final response = await http.Response.fromStream(streamResponse);
          final responseMap = jsonDecode(response.body) as Map<String, dynamic>;

          final isProcessOk = responseMap["info"] == "OK";

          serverResponse = Future.value(jsonEncode(
              {
                "error": !isProcessOk,
                "message": isProcessOk ? "" : responseMap['error_msg'],
                "statusCode": streamResponse.statusCode,
                "data": jsonEncode(responseMap)
              }
          ));
        } else {
          statusCode = streamResponse.statusCode;
          final status = statusCode == 408 ? 'Connection timeout' : 'Failed to send data: ${statusCode.toString()}';
          throw(status);
        }
      } catch (error) {
        serverResponse = Future.value(jsonEncode(
            {
              "error": true,
              "message": "$error",
              "statusCode": statusCode.toString(),
              "data": {}
            }
        ));

        _showCustomToast(messages: error.toString());
      }
    } else {
      serverResponse = Future.value(jsonEncode(
        {
          "error": true,
          "message": "No image selected",
          "data": {}
        }
      ));
      _showCustomToast(messages: "Please select atleast one image");
    }

    return serverResponse;
  }

  static _showCustomToast({required String messages}) {
    return Fluttertoast.showToast(
        msg: messages,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}