import 'package:flutter/material.dart';
import 'package:omnimuse/pallete.dart';
import 'package:omnimuse/power_box.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';
  bool is_on = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
  }
  void initSpeechToText() async {
    try {
      await speechToText.initialize();
      setState(() {});
    } catch (e) {
      // Handle initialization error
      print('Failed to initialize speech recognition: $e');
    }
  }

  Future<void> startListening() async {
    try {
      await speechToText.listen(onResult: onSpeechResult, listenFor: Duration(seconds: 10));
      setState(() {});
    } catch (e) {
      // Handle start listening error
      print('Failed to start speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await speechToText.stop();
      setState(() {});
    } catch (e) {
      // Handle stop listening error
      print('Failed to stop speech recognition: $e');
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }
  Container prompt(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40,).copyWith(top: 30),
      decoration: BoxDecoration(
          color: Color.fromRGBO(130, 130, 130, 0.21),
          border: Border.all(
              color: Pallete.borderColor
          ),
          borderRadius: BorderRadius.circular(20).copyWith(
              topRight: Radius.zero
          )
      ),
      child:  Padding(
        padding:  EdgeInsets.symmetric(vertical: 10),
        child:  Text(lastWords,
            style: TextStyle(
                color: Pallete.mainFontColor,
                fontFamily: 'Cera Pro',
                fontSize: 18
            )),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniMuse',
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        // Add your drawer content here
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle drawer item tap
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle drawer item tap
              },
            ),
            // Add more ListTile items as needed
          ],
        ),
      ),
      body: Builder(
        builder: (BuildContext context){
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5),
              Stack(
                children: [
                  //OmniMuse assistant
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/robot.png')),
                    ),
                  )
                ],
              ),
              //chat bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40,).copyWith(top: 30),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(130, 130, 130, 0.21),
                  border: Border.all(
                      color: Pallete.borderColor
                  ),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero
                  )
                ),
                child: const Padding(
                  padding:  EdgeInsets.symmetric(vertical: 10),
                  child:  Text('Hello, I am OmniMuse! What can i do for you?',
                  style: TextStyle(
                    color: Pallete.mainFontColor,
                    fontFamily: 'Cera Pro',
                    fontSize: 18
                  )),
                ),
              ),
              Visibility(child: prompt(),
              visible: is_on ),
              Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top:10, left: 22),
                child: const Text('Here are some of my powers',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),),
              ),
              //Power list
              Column(
                children: [
                  PowerBox(color: Pallete.firstPowerBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText: 'Where conversation transcends limits, knowledge comes alive.',
                  ),
                  PowerBox(color: Pallete.secondPowerBoxColor,
                    headerText: 'Dall-E',
                    descriptionText: 'AI wizardry creating mind-blowing digital art.',
                  ),
                  PowerBox(color: Pallete.thirdPowerBoxColor,
                    headerText: 'Omni Voice Assistant',
                    descriptionText: 'Unleash limitless possibilities with the coolest voice assistant powered by ChatGPT and Dall-E by your side.',
                  ),
                ],
              )
            ],
          ),
        );}
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.firstPowerBoxColor,
        onPressed: () async {
          print('Button pressed');

          if (await speechToText.hasPermission && speechToText.isNotListening) {
            print('Starting speech recognition');
            await startListening();
            setState(() {
              is_on = true;
            });
          } else if (speechToText.isListening) {
            print('Stopping speech recognition');
            await stopListening();
            setState(() {
              is_on = false;
            });
          } else {
            print('Initializing speech recognition');
             initSpeechToText();
          }
        },
        child: const Icon(Icons.mic_rounded),
      ),
    );
  }
}
