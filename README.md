# Alarmberry  

Bash script to listen for audio and send a [Pushbullet](http://pushbullet.com) notification if a loud enough noise is heard

---

Based on this post by Thomer M. Gil:
http://thomer.com/howtos/detect_sound.html

And the accompanying Ruby script:
http://thomer.com/howtos/sound-detect

Inspired by my dad's desire to get a notification on his phone when the alarm on his house went off. I decided to make a relatively simple shell script instead of relying on Ruby, which sent a push notification via Pushbullet when triggered.

---

Dependencies:
- arecord
- sox
