// ignore_for_file: unused_element

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

mixin class BaseStorage {
  String get boxName => '';

  GetStorage? box;

  Future<void> ensureInitStorage() async {
    if (box != null) {
      return;
    }

    await GetStorage.init(boxName);

    box = GetStorage(boxName);
  }

  @protected
  Future<T?> read<T>(String key) async {
    await ensureInitStorage();

    try {
      return box!.read(key);
    } catch (e) {
      debugPrint(e.toString());

      return null;
    } finally {}
  }

  // Make sure to use this method only when you are sure that the box is initialized
  @protected
  T readSync<T>(String key) {
    try {
      return box!.read(key);
    } catch (e) {
      debugPrint(e.toString());

      return null as T;
    } finally {}
  }

  @protected
  Future<void> write<T>(String key, T value) async {
    await ensureInitStorage();

    try {
      await box!.write(key, value);
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }

  @protected
  Future<void> delete(String key) async {
    await ensureInitStorage();

    try {
      await box!.remove(key);
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }

  // Be careful when using this method
  @protected
  Future<void> erase() async {
    try {
      await box!.erase();
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
  }
}
