import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schoolcrm/model/api_host.dart';
import 'package:schoolcrm/model/student.dart';

class StudentController {
  Future<List<Student>> getChildrenByParentId(int id) async {
    try {
      var data = await http.get(Uri.parse("$api/parents/show/${id.toString()}"));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        var theChildren = jsonData['Students'];

        List<Student> students = [];

        for (var object in theChildren) {
          Student student = Student(
            id: object['id'],
            firstName: object['first_name'],
            lastName: object['last_name'],
            sectionId: object['section_id'],
            busSubscribe: object['bus_subscribe'],
          );
          students.add(student);
        }

        return students;
      } else {
        print("Request failed with status: ${data.statusCode}");
        return [];
      }
    } catch (exp) {
      print("Exception while fetching children: $exp");
      return []; // Consider returning a meaningful value or re-throwing the exception.
    }
  }

  Future<int> getNumberOfChildrenByParentId(int id) async {
    try {
      var data = await http.get(Uri.parse("$api/parents/show/${id.toString()}"));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        var theChildren = jsonData['Students'];
        var length = (theChildren as List<dynamic>).length;

        return length;
      } else {
        print("Request failed with status: ${data.statusCode}");
        return 0;
      }
    } catch (exp) {
      print("Exception while fetching number of children: $exp");
      return 0; // Consider returning a meaningful value or re-throwing the exception.
    }
  }

  Future<void> tester() async {
    try {
      var data = await http.get(Uri.parse("$api/absences/show/2"));

      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        print(jsonData);
      } else {
        print("Request failed with status: ${data.statusCode}");
      }
    } catch (exp) {
      print("Exception while testing: $exp");
    }
  }
}