import 'dart:io';

import 'package:midi_util/midi_util.dart';

void main() {
  List notes = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
  var track = 0;
  var channel = 0;
  var time = 0; //    # In beats
  var duration = 0.5; //    # In beats
  var tempo = 60; //   # In BPM
  var volume = 100; //  # 0-127,  (MIDI standard)

  MIDIFile myMIDI = MIDIFile(numTracks: 2);
  myMIDI.addTempo(
    track: track,
    time: time,
    tempo: tempo,
  );
  myMIDI.addKeySignature(
      track: track,
      time: time,
      no_of_accidentals: 0,
      accidental_mode: AccidentalMode.MAJOR,
      accidental_type: AccidentalType.SHARPS);

  List.generate(notes.length, (i) {
    myMIDI.addNote(
        track: track,
        channel: channel,
        pitch: notes[i],
        time: time + i,
        duration: duration,
        volume: 100);
  });

  var outputFile = File('c_scale.mid');
  myMIDI.writeFile(outputFile);
}
