import 'dart:io';
import 'package:test/test.dart';

import '../lib/midi_util.dart';

void main() {
  test('Create test_c_scale.mid', () async {
    List notes = [
      60,
      62,
      64,
      65,
      67,
      69,
      71,
      72
    ]; //  # MIDI note number
    var track = 0;
    var channel = 0;
    var time = 0; //    # In beats
    var duration = 0.5; //    # In beats
    var tempo = 60; //   # In BPM
    var volume = 100; //  # 0-127, as per the MIDI standard

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
      accidental_type: AccidentalType.SHARPS,
    );

    myMIDI.addTimeSignature(
      track: track,
      time: time,
      numerator: 2,
      denominator: 4,
      clocks_per_tick: 24,
    );

    List.generate(notes.length, (i) {
      if (i > 2) {
        myMIDI.addProgramChange(
          channel: 0,
          program: 45,
          time: time + i,
          tracknum: track,
        );
      }
      if (i > 5) {
        myMIDI.addProgramChange(
          channel: 0,
          program: 46,
          time: time + i,
          tracknum: track,
        );
      }
      myMIDI.addNote(
        track: track,
        channel: channel,
        pitch: notes[i],
        time: time + i,
        duration: duration,
        volume: volume,
      );
    });

    var outputFile = File('test_c_scale.mid');
    await myMIDI.writeFile(outputFile);
    bool outputFileExists = await outputFile.exists();
    expect(outputFileExists, true);
  });
}
