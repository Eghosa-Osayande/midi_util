import 'dart:io';
import 'package:midi_util/midi_util.dart';

void main() {
  const List<int> notes = [60, 62, 64, 65, 67, 69, 71, 72]; // MIDI note numbers
  const int track = 0;
  const int channel = 0;
  const double duration = 0.5; // In beats
  const int tempo = 60; // In BPM
  const int volume = 100; // 0-127 (MIDI standard)

  MIDIFile myMIDI = MIDIFile(numTracks: 2);

  // Add tempo and key signature
  myMIDI.addTempo(track: track, time: 0, tempo: tempo);
  myMIDI.addKeySignature(
    track: track,
    time: 0,
    no_of_accidentals: 0,
    accidental_mode: AccidentalMode.MAJOR,
    accidental_type: AccidentalType.SHARPS,
  );

  // Add notes
  for (int i = 0; i < notes.length; i++) {
    myMIDI.addNote(
      track: track,
      channel: channel,
      pitch: notes[i],
      time: i, // Start time is incremented by the index
      duration: duration,
      volume: volume,
    );
  }

  // Write the MIDI file
  File outputFile = File('c_scale.mid');
  myMIDI.writeFile(outputFile);
}
