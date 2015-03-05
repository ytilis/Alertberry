# Alertberry  

Bash script to listen for audio and send a [Pushbullet](http://pushbullet.com) notification if a loud enough noise is heard

---

### To Use:

Add a `targets.txt` file to the directory (name and location are editable in the cfg file), with one colon delimited push target on each line, in the format `NAME:PUSHBULLET_API_KEY`

Example:

    John Anderson:abcdefghijklmnop
    Sarah Simmons:ponmlkjihgfedcba

---

Based on this post by Thomer M. Gil:
http://thomer.com/howtos/detect_sound.html

And the accompanying Ruby script:
http://thomer.com/howtos/sound-detect

Inspired by my dad's desire to get a notification on his phone when the alarm on his house went off. I decided to make a relatively simple shell script, in lieu of a similar existing Ruby script, which sent a push notification via Pushbullet when triggered.

---

Dependencies:
- arecord
- sox
