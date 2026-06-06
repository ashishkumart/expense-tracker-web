import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/category.dart';
import '../data/category_repository.dart';

enum CategoryStatus { initial, loading, success, failure, saving }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.message,
  });
  final CategoryStatus status;
  final List<Category> categories;
  final String? message;

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? message,
    bool clearMessage = false,
  }) => CategoryState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => [status, categories, message];
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState());
  final CategoryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: CategoryStatus.loading, clearMessage: true));
    try {
      emit(
        CategoryState(
          status: CategoryStatus.success,
          categories: await _repository.getAll(),
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: CategoryStatus.failure, message: '$error'));
    }
  }

  Future<bool> save({
    Category? existing,
    required String name,
    required TransactionType type,
    required String color,
  }) async {
    emit(state.copyWith(status: CategoryStatus.saving, clearMessage: true));
    try {
      if (existing == null) {
        await _repository.create(name: name, type: type, color: color);
      } else {
        await _repository.update(
          Category(id: existing.id, name: name, type: type, color: color),
        );
      }
      await load();
      return true;
    } catch (error) {
      emit(state.copyWith(status: CategoryStatus.failure, message: '$error'));
      return false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
    } catch (error) {
      emit(state.copyWith(status: CategoryStatus.failure, message: '$error'));
    }
  }
}
