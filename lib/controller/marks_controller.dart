import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schoolcrm/model/api_host.dart';
import 'package:schoolcrm/model/marks.dart';

class MarksController {
  String baseUrl = "https://api.json-generator.com/templates/OwM9RkB2D9hR/data?access_token=5to13khbnyhhldip0loy8xy2vm2aoq5ezl6pfv8o";


  Future<List<MarksModel>> getStudentMarks(String studentName) async {
    try {
      var data = await http.get(Uri.parse(baseUrl));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        List<MarksModel> marks = [];

        for (var u in jsonData) {
          MarksModel user = MarksModel(
              studentName: u['studentName'],
              course: u['course'],
              category: u['category'],
              mark: u['mark']);

          marks.add(user);
        }
        print(marks.length);
        return marks; // Changed: Return type Future<List<MarksModel>>
      }
      else {
        throw Exception('Failed to load student marks'); // Changed: Throw exception for HTTP status != 200
      }
    } catch (exception) {
      print('Error fetching student marks: $exception'); // Changed: Print the caught exception
      return []; // Changed: Return an empty list as a fallback
    }
  }

  Future<String> getCourseById(int courseId) async {
    try {
      var data = await http.get(Uri.parse("$api/subjects"));
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);

        for (var object in jsonData) {
          if (object['id'] == courseId) {
            print(object['name']);
            return object['name']; // Return the course name if found
          }
        }

        // If no course with matching ID is found
        throw Exception('Course with ID $courseId not found');
      } else {
        // Handle HTTP error
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error fetching course by ID: $e');
      // Return a default value or handle the error as appropriate for your application
      return ''; // Return an empty string as a fallback
    }
  }

  Future<void> getStudentMarks1() async {
    try{
      var data = await http.get(Uri.parse("$api/exam/show/3"));
      if(data.statusCode == 200){
        var jsonData = json.decode(data.body);
        print(jsonData);
      }
      else{
        print ("error");
      }




    }
    catch(exp){print(exp);}



  }


}
