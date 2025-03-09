import 'package:accordion_sliver_app_bar/accordion_sliver_app_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return SafeArea(
      top: false,
      child: Material(
        child: CustomScrollView(
          slivers: [
            AccordionSliverAppBar(
              background: Image.network(
                fit: BoxFit.cover,
                'https://picsum.photos/200',
              ),
              backgroundOverlayBuilder: (progress) => Container(
                color: Color.lerp(Colors.black, Colors.transparent, progress),
              ),
              children: [
                AccordionSliverChild.staticVanish(
                  height: 110,
                  builder: (context) => SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 110,
                  ),
                  priority: 2,
                ),
                AccordionSliverChild(
                  expandedHeight: 200,
                  collapsedHeight: 100,
                  wrapperBuilder: (context, child) => Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white,
                        ),
                        color: Colors.deepPurple),
                    child: child,
                  ),
                  animatedBuilder: (context, value) => Container(
                    decoration: BoxDecoration(
                        color: Color.lerp(Colors.amber, Colors.green, value)),
                    width: MediaQuery.sizeOf(context).width,
                    height: 100 // collapsedHeight
                        +
                        (100 // difference of expanded and collapsed height
                            *
                            value) -
                        48 // vertical margin and padding
                    ,
                    child: Align(
                        alignment: Alignment(value - 1, value - 1),
                        child: Text(value > 0.5 ? 'Expanded!' : 'Collapsed!')),
                  ),
                  priority: 10,
                ),
                AccordionSliverChild.static(
                  height: 50,
                  builder: (context) => Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Static child'),
                    ),
                  ),
                  priority: 3,
                ),
                AccordionSliverChild.staticVanish(
                  height: 100,
                  builder: (context) => Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 100,
                    color: Colors.red,
                    child: const Center(
                      child: Text('Static vanishing child'),
                    ),
                  ),
                  priority: 1,
                ),
                AccordionSliverChild.vanish(
                  height: 100,
                  wrapperBuilder: (context, child) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: child,
                  ),
                  animatedBuilder: (context, value) => Opacity(
                    opacity: value,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width - 32,
                      height: 84,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white),
                      child: const Center(
                        child: Text('Animated vanishing child'),
                      ),
                    ),
                  ),
                  priority: 0,
                ),
              ],
            ),
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
      ),
    );
  }
}
