import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zylutask/controller/employe_controller.dart';

class EmployeeView extends StatefulWidget {
  const EmployeeView({super.key});

  @override
  State<EmployeeView> createState() => _EmployeeViewState();
}

class _EmployeeViewState extends State<EmployeeView> {
  final EmployeeController controller = Get.put(EmployeeController());

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Employees",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF1A1D2E),
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE8EAF0)),
        ),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                backgroundColor: const Color(0xFFE8F5E9),
                label: Text(
                  "${controller.filteredEmployees.length} total",
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: controller.updateSearch,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1D2E)),
              decoration: InputDecoration(
                hintText: "Search by name or status…",
                hintStyle: const TextStyle(
                  color: Color(0xFFADB3C8),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFADB3C8),
                  size: 20,
                ),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFFADB3C8),
                          ),
                          onPressed: () {
                            searchController.clear();
                            controller.updateSearch('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF5B6AF0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter Chips ────────────────────────────────────────────
          Container(
            // color: Colors.white,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: 12,
            ),
            child: Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: "All",
                      selected: controller.activeFilter.value == 'all',
                      onTap: () => controller.setFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Senior Active",
                      selected: controller.activeFilter.value == 'senior',
                      onTap: () => controller.setFilter('senior'),
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Active",
                      selected: controller.activeFilter.value == 'active',
                      onTap: () => controller.setFilter('active'),
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Inactive",
                      selected: controller.activeFilter.value == 'inactive',
                      onTap: () => controller.setFilter('inactive'),
                      color: const Color(0xFF757575),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Employee List ────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.fetchEmployees();
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5B6AF0)),
                  );
                }

                final employees = controller.filteredEmployees;

                if (employees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No employees found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => controller.retry(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B6AF0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Retry",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return _EmployeeCard(emp: emp);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Employee Card ──────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final dynamic emp;
  const _EmployeeCard({required this.emp});

  @override
  Widget build(BuildContext context) {
    final isSenior = emp.isSeniorActive as bool;
    final isActive = emp.isActive as bool;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (isSenior) {
      statusColor = const Color(0xFF2E7D32);
      statusLabel = "Senior Active";
      statusIcon = Icons.workspace_premium_rounded;
    } else if (isActive) {
      statusColor = const Color(0xFF1565C0);
      statusLabel = "Active";
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = const Color(0xFF757575);
      statusLabel = "Inactive";
      statusIcon = Icons.remove_circle_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSenior ? const Color(0xFFA5D6A7) : const Color(0xFFE8EAF0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: statusColor.withOpacity(0.12),
          child: Text(
            emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          emp.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1A1D2E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                "${emp.years.toStringAsFixed(1)} yrs",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 13, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter Chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF5B6AF0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : const Color(0xFFE0E3EF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
