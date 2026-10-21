import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info.dart';

abstract class NetworkState extends Equatable {
  const NetworkState({required this.isConnected});
  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

class NetworkInitial extends NetworkState {
  const NetworkInitial() : super(isConnected: true);
}

class NetworkConnected extends NetworkState {
  const NetworkConnected() : super(isConnected: true);
}

class NetworkDisconnected extends NetworkState {
  const NetworkDisconnected() : super(isConnected: false);
}

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit(this._networkInfo) : super(const NetworkInitial()) {
    _init();
  }

  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {
    final connected = await _networkInfo.isConnected;
    if (isClosed) return;
    emit(connected ? const NetworkConnected() : const NetworkDisconnected());

    _subscription = _networkInfo.onConnectivityChanged.listen((connected) {
      if (isClosed) return;
      emit(connected ? const NetworkConnected() : const NetworkDisconnected());
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
