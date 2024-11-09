import 'package:flutter/material.dart';
import 'package:flutterapp/pages/fragments/dashboard.fragment.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/widgets/icons/rounded_icon.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final web3AuthProvider =
        Provider.of<Web3AuthProvider>(context, listen: true);

    print("HOME");

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
              ),
              Text(
                '''Hi! ${web3AuthProvider.user.fullName}''',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                    ),
                    backgroundColor: Color(0xFFFFFFFF).withOpacity(.1),
                    padding: EdgeInsets.symmetric(vertical: 1, horizontal: 4)
                        .copyWith(right: 12)),
                onPressed: () {
                  web3AuthProvider.w3mService.openModal(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RoundedIcon(
                      imageUrl: web3AuthProvider.tokenImage,
                      size: 32 * 0.7,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '''${web3AuthProvider.shortAddress}''',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF).withOpacity(.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              DashboardFragment(),
              const SizedBox(
                height: 120,
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     web3AuthProvider.disconnectWallet();
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Theme.of(context).primaryColor,
              //     minimumSize: Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   child: const Text(
              //     'Disconnect',
              //     style: TextStyle(
              //         color: Color(0xFF000000), fontWeight: FontWeight.bold),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
