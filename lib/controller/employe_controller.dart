import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zylutask/model/employe_model.dart';

class EmployeeController extends GetxController {
  // ── State
  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Search & Filter
  final RxString searchQuery = ''.obs;
  final RxString activeFilter = 'all'.obs;

  static const String _baseUrl = "http://127.0.0.1:8000/api/employees";

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  List<Employee> dummyData = [
    Employee.fromJson({
      "id": 1,
      "name": "Ravi Kumar",
      "joining_date": "2017-01-10T00:00:00.000000Z",
      "is_active": true,
      "years": 9.124847135959348,
      "is_senior_active": true,
    }),
    Employee.fromJson({
      "id": 2,
      "name": "Priya Sharma",
      "joining_date": "2023-05-15T00:00:00.000000Z",
      "is_active": true,
      "years": 2.7823813825980785,
      "is_senior_active": false,
    }),
    Employee.fromJson({
      "id": 3,
      "name": "Arjun Reddy",
      "joining_date": "2015-03-20T00:00:00.000000Z",
      "is_active": false,
      "years": 10.935806040143486,
      "is_senior_active": false,
    }),
    Employee.fromJson({
      "id": 4,
      "name": "Sneha Patel",
      "joining_date": "2018-08-12T00:00:00.000000Z",
      "is_active": true,
      "years": 7.5385457661888955,
      "is_senior_active": true,
    }),
    Employee.fromJson({
      "id": 5,
      "name": "Rahul Verma",
      "joining_date": "2010-11-25T00:00:00.000000Z",
      "is_active": true,
      "years": 15.25087453332344,
      "is_senior_active": true,
    }),
  ];

  List<Employee> get filteredEmployees {
    var list = employees.toList();

    // Search filter
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        final statusLabel = e.isActive ? 'active' : 'inactive';
        return e.name.toLowerCase().contains(q) || statusLabel.contains(q);
      }).toList();
    }

    // Status filter
    switch (activeFilter.value) {
      case 'senior':
        list = list.where((e) => e.isSeniorActive).toList();
        break;
      case 'active':
        list = list.where((e) => e.isActive && !e.isSeniorActive).toList();
        break;
      case 'inactive':
        list = list.where((e) => !e.isActive).toList();
        break;
    }

    return list;
  }

  // ── Methods ──────────────────────────────────────────────────────────────────
  Future<void> fetchEmployees() async {
    try {
      _resetError();
      isLoading(true);

      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        employees.value = data.map((e) => Employee.fromJson(e)).toList();
      } else {
        _setError(
          "Server error ${response.statusCode}: ${_statusMessage(response.statusCode)}",
        );
        employees.value = dummyData;
      }
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      employees.value = dummyData;
    } finally {
      isLoading(false);
    }
  }

  void updateSearch(String value) => searchQuery.value = value;

  void setFilter(String filter) => activeFilter.value = filter;

  void retry() => fetchEmployees();

  // ── Helpers ──────────────────────────────────────────────────────────────────
  void _resetError() {
    hasError(false);
    errorMessage('');
  }

  void _setError(String message) {
    hasError(true);
    errorMessage(message);
  }

  String _friendlyError(Exception e) {
    final raw = e.toString();
    if (raw.contains('SocketException') || raw.contains('Connection refused')) {
      return "Cannot reach the server. Check your connection or API URL.";
    }
    if (raw.contains('TimeoutException')) {
      return "Request timed out. The server took too long to respond.";
    }
    if (raw.contains('FormatException')) {
      return "Received unexpected data format from the server.";
    }
    return "Something went wrong. Please try again.";
  }

  String _statusMessage(int code) {
    const messages = {
      400: "Bad request",
      401: "Unauthorized",
      403: "Forbidden",
      404: "Endpoint not found",
      500: "Internal server error",
      503: "Service unavailable",
    };
    return messages[code] ?? "Unexpected response";
  }
}
