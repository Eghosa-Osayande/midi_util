import 'dart:io';

import 'package:midi_util/midi_util.dart';

void main() {
  List degrees = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
  var track = 0;
  var channel = 0;
  var time = 0; //    # In beats
  var duration = 1; //    # In beats
  var tempo = 60; //   # In BPM
  var volume = 100; //  # 0-127, as per the MIDI standard

  MIDIFile myMIDI = MIDIFile(2); //  # One track
  myMIDI.addTempo(track, time, tempo);
  myMIDI.addKeySignature(track, time, 0, SHARPS, MAJOR);
  
  List.generate(degrees.length, (i) {
    myMIDI.addNote(track, channel, degrees[i], time + i, duration, 100);
  });

  myMIDI.addKeySignature(1, 4, 3, SHARPS, MAJOR);
  myMIDI.addProgramChange(1, 1, time, 40);

  List.generate(degrees.length, (i) {
    myMIDI.addNote(1, 1, degrees[i], time + i, duration, volume);
  });

  var outputFile = File('c_scale.mid');
  myMIDI.writeFile(outputFile);
}
