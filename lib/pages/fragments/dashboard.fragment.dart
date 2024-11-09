import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:flutterapp/widgets/AppCard.dart';
import 'package:provider/provider.dart';

class DashboardFragment extends StatelessWidget {
  const DashboardFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RewardEarnings(),
        const SizedBox(
          height: 36,
        ),
        Row(
          children: [
            Image.asset('assets/images/dinamon.png'),
            const SizedBox(width: 5),
            const Text(
              'Tasks',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
        List3DTask(),
      ],
    );
  }
}

class RewardEarnings extends StatelessWidget {
  const RewardEarnings({super.key});

  @override
  Widget build(BuildContext context) {
    final web3AuthProvider =
        Provider.of<Web3AuthProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          // image: const DecorationImage(
          //   image: AssetImage('assets/images/card-bg.png'),
          //   fit: BoxFit.cover,
          // ),
          ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/dinamon.png'),
                  const SizedBox(width: 5),
                  const Text(
                    'Reward Earnings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Text(
                'Real-time',
                style: TextStyle(color: Colors.blue),
              )
            ],
          ),
          const SizedBox(height: 16),
          ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xff585858).withOpacity(.25)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Points Earned',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8A8B9B)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/token.png',
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          context
                              .watch<Web3AuthProvider>()
                              .earnPoint
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '-60 pts.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(.3),
                            fixedSize: Size(110, 30),
                            padding: EdgeInsets.all(2),
                          ),
                          child: const Text(
                            'Convert Points',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ClipRect(
            // <-- clips to the 200x200 [Container] below
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 5.0,
                sigmaY: 5.0,
              ),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xff585858).withOpacity(.25)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Points to Earn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8A8B9B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          web3AuthProvider.unlockPoint.toString(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: Text(
                            '/${web3AuthProvider.lockPoint} pts.',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '20GB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: .3,
                      minHeight: 8,
                      semanticsLabel: 'Points to Earn Progress',
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class List3DTask extends StatelessWidget {
  List3DTask({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = [
      {
        "name": "3D Scanner Task",
        "description": "Lorem ipsum dolor sit amet, consectetur"
      },
      // {
      //   "name": "3D Task 2",
      //   "description": "Lorem ipsum dolor sit amet, consectetur"
      // },
      // {
      //   "name": "3D Task 3",
      //   "description": "Lorem ipsum dolor sit amet, consectetur"
      // },
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 14),
      // Let the ListView know how many items it needs to build.
      itemCount: items.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,

      itemBuilder: (context, index) {
        final item = items[index];

        return AppCardWidget(
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/cube.png"),
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item["description"],
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ))
            ],
          ),
          onTap: (){
            
          },
        );
 
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 12);
      },
    );
  }
}
