class PackageCategory {
  final int id;
  final String name;

  PackageCategory({required this.id, required this.name});
}

final dummyPackageCategories = [
  PackageCategory(id: 0, name: 'All'),
  PackageCategory(id: 1, name: 'Wedding'),
  PackageCategory(id: 2, name: 'Birthday'),
  PackageCategory(id: 3, name: 'Graduation'),
];
