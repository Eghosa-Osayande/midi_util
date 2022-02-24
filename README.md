
# midi_util  

**midi_util** is a pure dart library that allows one to write multi-track Musical Instrument Digital Interface (MIDI) files from within dart programs (both format 1 and format 2 files are now supported).It is object-oriented and allows one to create and write these files with a minimum of fuss.

It is inspired by the python library [MIDIUtil](https://github.com/MarkCWirt/MIDIUtil) by Mark Conway Wirt.

midi_util isn't a full implementation of the MIDI specification. The actual specification is a large, sprawling document which has organically grown over the course of decades. I have selectively implemented some of the more useful and common aspects of the specification. Regardless, the code is fairly easy to understand and well structured. Additions can be made to the library by anyone with a good working knowledge of the MIDI file format and a good, working knowledge of Dart. Documentation for extending the library is provided.

This software is distributed under an Open Source license and you are free to use it as you see fit, provided that attribution is maintained. See License.txt in the source distribution for details.  

### Quick Start

-----------


Using the software is easy:

  

* The package must be imported into your namespace

* A MIDIFile object is created

* Events (notes, tempo-changes, etc.) are added to the object

* The MIDI file is written to disk.

  

Detailed documentation is provided; what follows is a simple example to get you going quickly. In this example we'll create a one track MIDI File, assign a tempo to the track, and write a C-Major scale. Then we write it to disk.

  

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





