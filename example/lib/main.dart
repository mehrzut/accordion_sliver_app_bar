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
                  backgroundBuilder: (context, progress) => Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            fit: BoxFit.fitWidth,
                            'https://picsum.photos/200',
                          ),
                          Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(1 - progress),
                                Colors.black,
                              ],
                            )),
                          ),
                        ],
                      ),
                  children: [
                AccordionSliverChild.vanish(
                  child: SizedSliverChild(
                      preferredSize: Size(
                        MediaQuery.sizeOf(context).width,
                        110,
                      ),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 110,
                      )),
                  priority: 2,
                ),
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
                        child: const Center(child: Text('Expanded!')),
                      )),
                  collapsed: SizedSliverChild(
                    preferredSize: Size(
                      MediaQuery.sizeOf(context).width,
                      100,
                    ),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 100,
                      child: const Center(child: Text('Collapsed!')),
                    ),
                  ),
                  priority: 10,
                ),
                AccordionSliverChild.static(
                  child: SizedSliverChild(
                      preferredSize: Size(
                        MediaQuery.sizeOf(context).width,
                        50,
                      ),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        color: Colors.blue,
                        child: const Center(
                          child: Text('Static child'),
                        ),
                      )),
                  priority: 3,
                ),
                AccordionSliverChild.vanish(
                  child: SizedSliverChild(
                      preferredSize: Size(
                        MediaQuery.sizeOf(context).width,
                        50,
                      ),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        color: Colors.red,
                        child: const Center(
                          child: Text('Vanishing child'),
                        ),
                      )),
                  priority: 1,
                ),
              ])),
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => Container(
              height: 500,
              color: Colors.primaries.reversed
                  .toList()[index % Colors.primaries.length]
                  .withOpacity(0.4),
            ),
          )),
        ],
      ),
    );
  }
}
