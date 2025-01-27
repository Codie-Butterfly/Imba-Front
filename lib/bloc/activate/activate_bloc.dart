import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/upload_repo.dart';
import '../../secure_storage/secure_storage_manager.dart';
import 'activate_event.dart';
import 'activate_state.dart';

class ActivateBloc extends Bloc<ActivateEvent, ActivateState> {
  final UploadRepositoryImpl uploadRepositoryImpl;

  final SecureStorageManager storage;

  static const String LOG_NAME = 'bloc.uploads';

  ActivateBloc({required this.storage, required this.uploadRepositoryImpl})
      : super(ActivateInitialState()) {
    on<ActivateHouseEvent>((event, emit) async {
      var token = await storage.getToken();
      emit(ActivateLoadingState());
      try {
        bool isActivated = await uploadRepositoryImpl.activateHouse(
            houseId: event.houseId, token: token);

        dev.log('activation successful, activation :$isActivated',
            name: LOG_NAME);
        emit(ActivateHouseSuccess(isActivated: isActivated,));
      } on SocketException catch (err) {
        dev.log('Failed to activate house, error: ${err.toString().replaceAll("Exception:","")}',
            name: LOG_NAME);
        emit(ActivateFailedState(err.toString()));
      } catch (err) {
        dev.log('Failed to activate house, error: $err');
        emit(ActivateFailedState(err.toString().replaceAll("Exception:","")));
      }
    });

    on<ActivationResetEvent>((event, emit) async {
      emit(ActivateInitialState());
    });
  }
}
