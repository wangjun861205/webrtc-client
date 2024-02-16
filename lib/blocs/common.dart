import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Query<P, R> {
  P params;
  R result;
  bool isLoading;
  Object? error;
  Future<R> Function(P params) fetchFunc;
  R Function({required R currResult, required R incomeResult}) handleResultFunc;
  P Function({required P currParams, required R incomeResult}) nextParamsFunc;

  Query({
    required this.params,
    required this.result,
    required this.fetchFunc,
    required this.handleResultFunc,
    required this.nextParamsFunc,
    this.isLoading = false,
    this.error,
  });
}

class QueryCubit<P, R> extends Cubit<Query<P, R>> {
  QueryCubit({required Query<P, R> query}) : super(query);

  void next() async {
    emit(Query(
        params: state.params,
        result: state.result,
        fetchFunc: state.fetchFunc,
        handleResultFunc: state.handleResultFunc,
        nextParamsFunc: state.nextParamsFunc,
        isLoading: true,
        error: null));
    try {
      final incomeResult = await state.fetchFunc(state.params);
      final newResult = state.handleResultFunc(
          currResult: state.result, incomeResult: incomeResult);
      final nextParams = state.nextParamsFunc(
          currParams: state.params, incomeResult: incomeResult);
      emit(Query(
        params: nextParams,
        result: newResult,
        fetchFunc: state.fetchFunc,
        handleResultFunc: state.handleResultFunc,
        nextParamsFunc: state.nextParamsFunc,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(Query(
          params: state.params,
          result: state.result,
          fetchFunc: state.fetchFunc,
          handleResultFunc: state.handleResultFunc,
          nextParamsFunc: state.nextParamsFunc,
          isLoading: false,
          error: e));
    }
  }

  void setResult(R newResult) {
    emit(Query(
        params: state.params,
        result: newResult,
        fetchFunc: state.fetchFunc,
        handleResultFunc: state.handleResultFunc,
        nextParamsFunc: state.nextParamsFunc,
        isLoading: state.isLoading,
        error: state.error));
  }

  void setParams(P newParams) {
    emit(Query(
        params: newParams,
        result: state.result,
        fetchFunc: state.fetchFunc,
        handleResultFunc: state.handleResultFunc,
        nextParamsFunc: state.nextParamsFunc,
        isLoading: state.isLoading,
        error: state.error));
  }
}
