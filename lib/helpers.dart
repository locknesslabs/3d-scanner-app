import 'package:web3modal_flutter/web3modal_flutter.dart';

String shortenAddress(String address, [int chars = 4, int? lastChar]) {
  final parsed = EthereumAddress.fromHex(address);
  if (parsed == null) {
    return "";
  }

  final _lastChar = lastChar ?? chars;

  return "${parsed.hex.substring(0, chars + 2)}...${parsed.hex.substring(42 - _lastChar)}";
}
