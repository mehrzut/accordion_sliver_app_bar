import 'package:accordion_sliver_app_bar/accordion_sliver_app_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accordion Sliver App Bar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: [
          AccordionSliverAppBar(
              delegate: AccordionSliverDelegate(
                  duration: Durations.medium2,
                  pinned: true,
                  floating: true,
                  safeArea: false,
                  children: [
                AccordionSliverChild(
                  wrapperBuilder: (context, child, size, isExpanded) =>
                      Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.deepPurple),
                    child: child,
                  ),
                  expanded: SizedSliverChild(
                      preferredSize: Size(
                        MediaQuery.sizeOf(context).width,
                        210,
                      ),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 210,
                        child: const Center(child: Text('expanded!')),
                      )),
                  collapsed: SizedSliverChild(
                    preferredSize: Size(
                      MediaQuery.sizeOf(context).width,
                      100,
                    ),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 100,
                      child: const Center(child: Text('collapsed!')),
                    ),
                  ),
                  priority: 10,
                ),
                AccordionSliverChild(
                  expanded: SizedSliverChild(
                      preferredSize: Size(
                        MediaQuery.sizeOf(context).width,
                        110,
                      ),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 110,
                        color: Colors.amber,
                      )),
                  collapsed: SizedSliverChild(
                    preferredSize: Size(
                      MediaQuery.sizeOf(context).width,
                      48,
                    ),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 48,
                      color: Colors.pink,
                    ),
                  ),
                  priority: 2,
                ),
              ])),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              height: 100,
              color: Colors.primaries.reversed
                  .toList()[index % Colors.primaries.length],
            ),
          )),
        ],
      ),
    );
  }
}
