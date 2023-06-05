import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'package:omnimuse/pallete.dart';
import 'package:omnimuse/power_box.dart';
import 'package:omnimuse/services/openai_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool speechEnabled = false;
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  bool is_on = false;
  int start = 200;
  int delay = 200;
  final OpenAIService openAIService = OpenAIService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }
  Future<void> initTextToSpeech() async{
    try {
      await flutterTts.setSharedInstance(true);
      setState(() {});
    }
    catch(e){
      print('Failed to initialize speech to text: $e');
    }
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
  Container imageContainer() {
    if (generatedImageUrl == null) {
      // Return a placeholder or empty container for the null case
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
      decoration: BoxDecoration(
        color: Color.fromRGBO(130, 130, 130, 0.21),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
          child: GestureDetector(
    onTap: () {
    downloadImage(generatedImageUrl!);
    },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          generatedImageUrl!,
          fit: BoxFit.cover,
        ),
      ),
    ));
  }
  Future<void> downloadImage(String imageUrl) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission denied');
        return;
      }

      var directory = await getExternalStorageDirectory();
      var time = DateTime.now().microsecondsSinceEpoch;
      var path = '${directory?.path}/image-$time.jpg';
      var file = File(path);
      var response = await get(Uri.parse(imageUrl));
      await file.writeAsBytes(response.bodyBytes);

      print('Image downloaded successfully at: $path');
      await ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blueGrey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Image downloaded successfully at:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                path,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
      // Open the saved file
      showOpenFileDialog(context, file);
    } catch (error) {
      print('Error while downloading image: $error');
    }
  }
  void showOpenFileDialog(BuildContext context, File filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Open File'),
          content: Text('Do you want to open the file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openFile(filePath); // Open the file
              },
              child: Text('Open'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openFile(File file) async {
    try {
      if (await file.exists()) {
        // Open the file using the default file opener on the device
        await OpenFile.open(file.path);
      } else {
        print('File does not exist');
      }
    } catch (error) {
      print('Error while opening file: $error');
    }
  }
  void signUserOut()async{
    FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    Navigator.pushReplacementNamed(context, '/login');
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('OmniMuse',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),),
        ),
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
        actions: [
          IconButton(onPressed: signUserOut, icon: Icon(Icons.logout_rounded))
        ],
      ),
      drawer: Drawer(
        // Add your drawer content here
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Text('Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Cera Pro',
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Text('Timothy Mentowidjojo',
                      style: TextStyle(
                        color: Pallete.whiteColor,
                      ),),
                      SizedBox(width: 20,
                      ),
                      CircleAvatar(
                        child: Image.asset('assets/images/robot.png'),
                        radius: 30,
                      )
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              title: Text("Settings",
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Cera Pro',
                  fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
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
              ZoomIn(
                  child:Stack(
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
              ),),
              //chat bubble
              FadeInLeft(
                child: Container(
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
                  child:  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 10),
                    child:  Text(
                        generatedContent== null ?'Hello, I am OmniMuse! What can i do for you?'
                            : generatedContent!,
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontFamily: 'Cera Pro',
                      fontSize: generatedContent == null? 18 : 16
                    )),
                  ),
                ),
              ),
              Visibility(child: imageContainer(),
              visible: generatedImageUrl == null? false : true ),
              SlideInLeft(
                child: Container(
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
              ),
              //Power list
               Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const PowerBox(color: Pallete.firstPowerBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText: 'Where conversation transcends limits, knowledge comes alive.',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const PowerBox(color: Pallete.secondPowerBoxColor,
                      headerText: 'Dall-E',
                      descriptionText: 'AI wizardry creating mind-blowing digital art.',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2* delay),
                    child: const PowerBox(color: Pallete.thirdPowerBoxColor,
                      headerText: 'Omni Voice Assistant',
                      descriptionText: 'Unleash limitless possibilities with the coolest voice assistant powered by ChatGPT and Dall-E by your side.',
                    ),
                  ),
                ],
              )
            ],
          ),
        );}
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3* delay),
        child: FloatingActionButton(
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
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if(speech.contains('https')){
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              }else{
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
              setState(() {
                is_on = false;
              });
            } else {
              print('Initializing speech recognition');
               initSpeechToText();
            }
          },
          child:  Icon(speechToText.isListening? Icons.stop : Icons.mic_rounded),
        ),
      ),
    );
  }
}
