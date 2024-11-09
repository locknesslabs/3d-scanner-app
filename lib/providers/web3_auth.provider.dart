import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterapp/helpers.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/models/bearer-token.dart';
import 'package:flutterapp/models/user.dart';
import 'package:flutterapp/pages/login.dart';
import 'package:flutterapp/utils/dart_defines.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/services/explorer_service/explorer_service_singleton.dart';
import 'package:web3modal_flutter/utils/asset_util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart' as Log;

class Web3AuthProvider extends ChangeNotifier {
  late Web3App wcClient;
  final w3mService = W3MService(
    projectId: 'a99cac5fec76ce36cc9ef195ffc5f879',
    metadata: const PairingMetadata(
      name: 'Web3Modal Flutter Example',
      description: 'Web3Modal Flutter Example',
      url: 'https://www.walletconnect.com/',
      icons: ['https://walletconnect.com/walletconnect-logo.png'],
      redirect: Redirect(
        native: 'flutterdapp://',
        universal: 'https://www.walletconnect.com',
      ),
    ),
    enableAnalytics: false,
    featuredWalletIds: {
      'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
      '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // Trust
      'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
    },
    includedWalletIds: {
      'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // MetaMask
      '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // Trust
      'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
    },
  );

  User user = User.empty();
  BearerToken token = BearerToken.empty();
  static final Log.Logger _logger = Log.Logger();

  double lockPoint = 0;
  double unlockPoint = 0;
  double earnPoint = 0;

  String accountBalance = '0';
  bool loading = true;

  bool signing = false;

  Web3AuthProvider() {
    _initConnectWallet();
  }

  bool get isAuthenticated {
    return isConnected && token.token.isNotEmpty;
  }

  String? get address {
    return w3mService.session?.address;
  }

  String? get shortAddress {
    return shortenAddress(address ?? "", 2, 4);
  }

  String? get chainId {
    return w3mService.session?.chainId;
  }

  String get tokenImage {
    final chainId = w3mService.selectedChain?.chainId ?? '1';
    final imageId = AssetUtil.getChainIconId(chainId) ?? '';
    return explorerService.instance.getAssetImageUrl(imageId);
  }

  String? get connectedWalletName {
    return w3mService.session?.connectedWalletName;
  }

  ConnectionMetadata? get peer {
    return w3mService.session?.peer;
  }

  Future<void> setAccessToken(Map<String, dynamic> payload) async {
    token = BearerToken.fromJSON(payload);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token.toString());
  }

  Future<void> removeAccessToken() async {
    token = BearerToken.empty();
    signing = false;
    loading = false;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
  }

  void initialize(BuildContext context) async {
    await w3mService.init();
    print("w3 initialized");
    print(w3mService.status);

    connectWallet();
    w3mService.onModalConnect.subscribe((ModalConnect? event) {
      print("w3mService.onModalConnect.subscribe");
      connectWallet();
    });

    w3mService.onModalDisconnect.subscribe((ModalDisconnect? event) {
      disconnectApi();

      _isConnected = false;
      notifyListeners();

      // WidgetsBinding.instance!.addPostFrameCallback((_) {
      //   if (navigatorKey.currentContext != null) {
      //     Navigator.pushReplacement(
      //       navigatorKey.currentContext!,
      //       MaterialPageRoute(builder: (context) => const LoginScreen()),
      //     );
      //   } else {
      //     _logger.e("Navigator context is null, cannot navigate to LoginPage");
      //   }
      // });
    });
  }

  Future<void> getBalance() async {
    accountBalance = w3mService.chainBalance;
    print("Balance $accountBalance");
    notifyListeners();
  }

  Future<void> getNFTs() async {
    var client = http.Client();
    try {
      http.Response res =
          await http.get(Uri.parse('http://localhost:3000/getNFTs'));
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
      }
    } finally {
      client.close();
    }
    notifyListeners();
  }

  _initConnectWallet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? tokenCached = prefs.getString('token');

    if (tokenCached != null) {
      setAccessToken(jsonDecode(tokenCached));
    }

    notifyListeners();
    print("Acess token ${token.accessToken}");

    // wcClient = await Web3App.createInstance(
    //   relayUrl: 'wss://relay.walletconnect.com',
    //   projectId: '482390abbe2d10158e1d448b5bb705aa',
    //   metadata: const PairingMetadata(
    //     name: 'lockness',
    //     description: 'A dapp that can request that transactions be signed',
    //     url: 'https://walletconnect.com',
    //     icons: ['https://avatars.githubusercontent.com/u/37784886'],
    //   ),
    // );
  }

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<dynamic> personalSign(String message) async {
    w3mService.launchConnectedWallet();
    return await w3mService.request(
      topic: w3mService.session!.topic,
      chainId: w3mService.selectedChain!.chainId,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [
          message,
          w3mService.session!.address!,
        ],
      ),
    );
  }

  Future<bool> connectWallet() async {
    try {
      _isConnected = w3mService.isConnected;

      if (_isConnected) {
        if (token.accessToken.isEmpty) {
          signing = true;
          notifyListeners();

          String domain = "https://lockness.xyz";
          String from = w3mService.session!.address!;

          var siweMessage =
              '''${domain} wants you to sign in with your Ethereum account:\n${from}\n\nI accept the MetaMask Terms of Service: https://community.metamask.io/tos\n\nURI: https://${domain}\nVersion: 1\nChain ID: 1\nNonce: 32891757\nIssued At: 2021-09-30T16:25:24.000Z''';

          var sign = await personalSign(siweMessage);

          print("sign: ${sign}");

          try {
            http.Response res = await http
                .post(Uri.parse('${DartDefines.apiUrl}/web3/verify'), body: {
              "message": siweMessage,
              "address": from,
              "signature": sign
            });
            if (res.body.isNotEmpty) {
              Map<String, dynamic> body = jsonDecode(res.body);
              print(body);

              setAccessToken(body["accessToken"]);
              user = User.fromJSON(body["user"]);
              signing = false;
            }
          } catch (e) {
            print("verify error: ${e}");
             disconnectWallet();
          }
        } else {
          fetchUser();
        }
      }
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      loading = false;
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  fetchUser() async {
    if (token.accessToken.isEmpty) return;

    try {
      http.Response res =
          await http.get(Uri.parse('${DartDefines.apiUrl}/me'), headers: {
        "Authorization": token.accessToken,
      });

      print("fetchUser");
      print(res.body);
      Map<String, dynamic> body = jsonDecode(res.body);

      user = User.fromJSON(body["user"]);
      notifyListeners();
    } catch (e) {
      disconnectWallet();
    }
  }

  disconnectApi() async {
    try {
      http.Response res = await http
          .delete(Uri.parse('${DartDefines.apiUrl}/logout'), headers: {
        "Authorization": token!.accessToken,
      });
    } catch (e) {}
    removeAccessToken();
  }

  disconnectWallet() async {
    await disconnectApi();
    await w3mService.disconnect(disconnectAllSessions: true);
  }
}
