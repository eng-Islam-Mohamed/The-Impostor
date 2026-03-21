import 'package:bara_alsalfa/domain/models/category_pack.dart';

abstract class CategoryRepository {
  List<CategoryPack> getPacks();
  CategoryPack getPackById(String id);
}
