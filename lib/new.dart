import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phone_state/phone_state.dart';

class LiveRadioScreen extends StatefulWidget {
  const LiveRadioScreen({super.key});

  @override
  _LiveRadioScreenState createState() => _LiveRadioScreenState();
}

class _LiveRadioScreenState extends State<LiveRadioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAd();
    _handlePhoneCallState();
  }

  void _initializeAd() {
    _bannerAd = BannerAd(
      adUnitId: 'your-admob-banner-id',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  void _handlePhoneCallState() {
    PhoneState.stream.listen((event) {
      if (event == PhoneStateStatus.CALL_STARTED) {
        _audioPlayer.pause();
      } else if (event == PhoneStateStatus.CALL_ENDED) {
        _audioPlayer.play();
      }
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.brown],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tune in to our live stream now',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Image.asset('assets/logo.png', width: 150),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                _audioPlayer.setUrl('https://ia801609.us.archive.org/31/items/count_monte_cristo_0711_librivox/count_of_monte_cristo_001_dumas.mp3');
                _audioPlayer.play();
              },
              child: const Icon(Icons.play_arrow, color: Colors.deepPurple, size: 40),
            ),
            const SizedBox(height: 20),
            if (_isAdLoaded)
              SizedBox(
                height: 50,
                child: AdWidget(ad: _bannerAd),
              ),
            const Text(
              'Stay updated with our station events and promotions.',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
                 const Text(
              'Connect with us',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset('assets/facebook.png', width: 30),
                  onPressed: () => _launchURL('https://facebook.com'),
                ),
                IconButton(
                  icon: Image.asset('assets/instagram.png', width: 30),
                  onPressed: () => _launchURL('https://instagram.com'),
                ),
                IconButton(
                  icon: Image.asset('assets/twitter.png', width: 30),
                  onPressed: () => _launchURL('https://twitter.com'),
                ),
                IconButton(
                  icon: Image.asset('assets/youtube.png', width: 30),
                  onPressed: () => _launchURL('https://youtube.com'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'Live Radio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact Us',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigate to Live Radio Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LiveRadioScreen()),
            );
          } else if (index == 1) {
            // Navigate to Contact Us Screen
           
          }
        },
  
      ),
    );
  }
}