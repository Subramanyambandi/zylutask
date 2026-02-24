import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zylutask/model/employe_model.dart';

class EmployeeController extends GetxController {
  // ── State ────────────────────────────────────────────────────────────────────
  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Search & Filter ──────────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxString activeFilter = 'all'.obs;

  static const String _baseUrl = "http://127.0.0.1:8000/api/employees";

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  // ── Computed ─────────────────────────────────────────────────────────────────
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
      }
    } on Exception catch (e) {
      _setError(_friendlyError(e));
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
