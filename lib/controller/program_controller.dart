import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schoolcrm/model/program_model.dart';

class ProgramController {
  String baseUrl =
      "https://api.json-generator.com/templates/VgqYD7kqOkGG/data?access_token=5to13khbnyhhldip0loy8xy2vm2aoq5ezl6pfv8o";

  Future<List<ProgramModel>> getProgram() async {
    try {
      var data = await http.get(Uri.parse(baseUrl));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<ProgramModel> programList = [];

        for (var obj in jsonData) {
          ProgramModel progObj = ProgramModel(
            course: obj['course'],
            period: obj['period'],
          );
          programList.add(progObj);
        }
        return programList; // Changed: Ensure to return programList on success
      } else {
        throw Exception('Failed to load programs: ${data.statusCode}');
      }

    } catch (exception) {
      throw exception; // Changed: Re-throw caught exception
    }
  }
}