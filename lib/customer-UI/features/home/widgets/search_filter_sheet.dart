import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/view/filter_result.dart';
import 'package:eventak/customer-UI/features/home/view/area_view.dart';

class SearchFilterSheet extends StatefulWidget {
  final List<Map<String, dynamic>> availableCategories;

  final List<Map<String, dynamic>> availableServiceTypes;
  final String? serviceTypeId;

  final List<AreaNode> areasTree;

  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool popular;

  final bool? includeServices;
  final bool? includePackages;

  final AreaNode? selectedCountry;
  final AreaNode? selectedGov;
  final AreaNode? selectedCity;
  final int? selectedAreaId;

  const SearchFilterSheet({
    super.key,
    required this.availableCategories,
    required this.availableServiceTypes,
    required this.serviceTypeId,
    required this.areasTree,
    required this.categoryId,
    required this.minPrice,
    required this.maxPrice,
    required this.popular,
    required this.includeServices,
    required this.includePackages,
    required this.selectedCountry,
    required this.selectedGov,
    required this.selectedCity,
    required this.selectedAreaId,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String? _categoryId;
  late String? _serviceTypeId;

  late bool _popular;

  late bool _incServicesUI;
  late bool _incPackagesUI;

  AreaNode? _country;
  AreaNode? _gov;
  AreaNode? _city;
  int? _areaId;

  late TextEditingController _minController;
  late TextEditingController _maxController;

  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();

    _categoryId = widget.categoryId;
    _serviceTypeId = widget.serviceTypeId;
    _popular = widget.popular;

    _incServicesUI = widget.includeServices != false;
    _incPackagesUI = widget.includePackages != false;

    _country = widget.selectedCountry;
    _gov = widget.selectedGov;
    _city = widget.selectedCity;
    _areaId = widget.selectedAreaId;

    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;

    _minController = TextEditingController(
      text: _minPrice == null ? '' : _minPrice!.toString(),
    );
    _maxController = TextEditingController(
      text: _maxPrice == null ? '' : _maxPrice!.toString(),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _categoryId = null;
      _serviceTypeId = null;
      _popular = false;

      _incServicesUI = true;
      _incPackagesUI = true;

      _country = null;
      _gov = null;
      _city = null;
      _areaId = null;

      _minPrice = null;
      _maxPrice = null;
      _minController.text = '';
      _maxController.text = '';
    });
  }

  void _apply() {
    if (!_incServicesUI && !_incPackagesUI) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable Services or Packages (at least one).'),
        ),
      );
      return;
    }

    bool? includeServicesParam;
    bool? includePackagesParam;

    if (_incServicesUI && _incPackagesUI) {
      includeServicesParam = null;
      includePackagesParam = null;
    } else {
      if (!_incServicesUI) includeServicesParam = false;
      if (!_incPackagesUI) includePackagesParam = false;
    }

    Navigator.pop(
      context,
      FilterResult(
        categoryId: _categoryId,
        serviceTypeId: _serviceTypeId,
        popular: _popular,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        includeServices: includeServicesParam,
        includePackages: includePackagesParam,
        selectedCountry: _country,
        selectedGov: _gov,
        selectedCity: _city,
        selectedAreaId: _areaId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _reset,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary,
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    children: [
                      _sectionTitle('Service Type'),
                      if (widget.availableServiceTypes.isEmpty)
                        Text(
                          'No service types found',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(
                              label: 'All',
                              active: _serviceTypeId == null,
                              onTap: () =>
                                  setState(() => _serviceTypeId = null),
                            ),
                            ...widget.availableServiceTypes.map((t) {
                              final id = t['id'].toString();
                              final name = (t['name'] ?? 'Unknown').toString();
                              final active = _serviceTypeId == id;

                              return _chip(
                                label: name,
                                active: active,
                                onTap: () => setState(() {
                                  _serviceTypeId = active ? null : id;
                                }),
                              );
                            }).toList(),
                          ],
                        ),

                      const SizedBox(height: 18),

                      _sectionTitle('Service Category'),
                      if (widget.availableCategories.isEmpty)
                        Text(
                          'No categories found',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.availableCategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final cat = widget.availableCategories[index];
                              final id = cat['id'].toString();
                              final name = (cat['name'] ?? 'Unknown')
                                  .toString();
                              final active = _categoryId == id;

                              return _chip(
                                label: name,
                                active: active,
                                onTap: () => setState(() {
                                  _categoryId = active ? null : id;
                                }),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 18),

                      _sectionTitle('Area'),
                      _dropdown(
                        label: 'Country',
                        value: _country,
                        items: widget.areasTree,
                        enabled: true,
                        onChanged: (v) {
                          setState(() {
                            _country = v;
                            _gov = null;
                            _city = null;
                            _areaId = v?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Governorate',
                        value: _gov,
                        items: (_country?.children ?? const []),
                        enabled: _country != null,
                        onChanged: (v) {
                          setState(() {
                            _gov = v;
                            _city = null;
                            _areaId = v?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'City',
                        value: _city,
                        items: (_gov?.children ?? const []),
                        enabled: _gov != null,
                        onChanged: (v) {
                          setState(() {
                            _city = v;
                            _areaId = v?.id;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      _sectionTitle('Price Range'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) =>
                                  _minPrice = double.tryParse(v.trim()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _maxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) =>
                                  _maxPrice = double.tryParse(v.trim()),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _switchCard(
                        title: 'Popular only',
                        value: _popular,
                        onChanged: (v) => setState(() => _popular = v),
                      ),

                      const SizedBox(height: 12),

                      _switchCard(
                        title: 'Include Services',
                        value: _incServicesUI,
                        onChanged: (v) => setState(() {
                          _incServicesUI = v;
                          if (!v && !_incPackagesUI) _incPackagesUI = true;
                        }),
                      ),

                      const SizedBox(height: 12),

                      _switchCard(
                        title: 'Include Packages',
                        value: _incPackagesUI,
                        onChanged: (v) => setState(() {
                          _incPackagesUI = v;
                          if (!v && !_incServicesUI) _incServicesUI = true;
                        }),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _apply,
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? AppColor.primary.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColor.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: active ? AppColor.primary : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required AreaNode? value,
    required List<AreaNode> items,
    required bool enabled,
    required ValueChanged<AreaNode?> onChanged,
  }) {
    return DropdownButtonFormField<AreaNode>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      items: items
          .map((e) => DropdownMenuItem<AreaNode>(value: e, child: Text(e.name)))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _switchCard({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        value: value,
        activeColor: AppColor.primary,
        activeTrackColor: AppColor.primary.withOpacity(0.35),
        onChanged: onChanged,
      ),
    );
  }
}
