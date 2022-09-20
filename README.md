
# midi_util  

Inspired by the python library -[MIDIUtil](https://github.com/MarkCWirt/MIDIUtil) written by Mark Conway Wirt,
**midi_util** is a pure dart library that allows one to create MIDI files (Musical Instrument Digital Interface) within a dart program
with minimum fuss, and supports both format 1 and 2 files.
Due to the large documentation as well as the organic growth of the MIDI files specifications, **midi_util** has been made to effectively 
implement aspects of this specifications that are commonly used and are in high demand.
The **midi_util** package is properly structured to give anyone with a good understanding of the MIDI file format, and demonstrates a 
good understanding of object oriented programming with dart the ability to extend  the library -Henc all of these makes this package easy to understand


    import 'dart:io';

    import 'package:midi_util/midi_util.dart';

    void main() {
      List notes = [60, 62, 64, 65, 67, 69, 71, 72]; //  # MIDI note number
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

  
  

There are several additional event types that can be added and there are various options available for creating the MIDIFile object, but the above is sufficient to begin using the library and creating note sequences. The above code is found in machine-readable form in the examples directory. A detailed class reference and documentation describing how to extend the library is provided in the documentation directory.





