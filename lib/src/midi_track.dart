import 'dart:io';
import 'dart:typed_data';

import 'package:midi_util/src/midi_file.dart';

import 'events/contoller_event.dart';
import 'events/generic_event.dart';
import 'events/key_signature.dart';
import 'events/note_off_event.dart';
import 'events/note_on_event.dart';
import 'events/program_change.dart';
import 'events/tempo.dart';
import 'events/time_signature.dart';
import 'events/track_name.dart';
import 'events/utils.dart';

///A class that encapsulates a MIDI track
///

class MIDITrack extends Object {
  List<int> dataLength = [0]; // Is calculated after the data is in place
  List<int> MIDIdata = [];
  bool closed = false;
  List<GenericEvent> eventList = [];
  List<GenericEvent> MIDIEventList = [];
  late bool remdep;
  late bool deinterleave;

  MIDITrack([removeDuplicates = false, deinterleave = false]) {
    this.remdep = removeDuplicates;
    this.deinterleave = deinterleave;
  }

  static List<int> get headerString => [77, 84, 114, 107];
  static List<int> get closeEvent => [0x00, 0xFF, 0x2F, 0x00];

  ///   Add a note by chromatic MIDI number
  /// This event is not in chronological order. But before writing all the
  /// events to the file, I sort self.eventlist on (tick, sec_sort_order, insertion_order)
  /// which puts the events in chronological order.
  addNoteByNumber(channel, pitch, tick, duration, volume,
      {annotation, insertion_order = 0}) {
    this.eventList.add(NoteOn(channel, pitch, tick, duration, volume,
        annotation = annotation, insertion_order = insertion_order));

    this.eventList.add(NoteOff(channel, pitch, tick + duration, volume,
        annotation = annotation, insertion_order = insertion_order));
  }

  ///Add a controller event.
  addControllerEvent(channel, tick, controller_number, parameter,
      {insertion_order = 0}) {
    this.eventList.add(ControllerEvent(channel, tick, controller_number,
        parameter, insertion_order = insertion_order));
  }

  /// Add a tempo change (or set) event.
  addTempo(tick, tempo, {insertion_order = 0}) {
    eventList.add(Tempo(tick, tempo, insertion_order = insertion_order));
  }

  /// Add a program change event.
  addProgramChange(channel, tick, program, {insertion_order = 0}) {
    eventList.add(ProgramChange(
        channel, tick, program, insertion_order = insertion_order));
  }

  /// Add a track name event.
  addTrackName(tick, trackName, {insertion_order = 0}) {
    this
        .eventList
        .add(TrackName(tick, trackName, insertion_order = insertion_order));
  }

  /// Add a time signature.
  addTimeSignature(
      tick, numerator, denominator, clocks_per_tick, notes_per_quarter,
      {insertion_order = 0}) {
    this.eventList.add(TimeSignature(tick, numerator, denominator,
        clocks_per_tick, notes_per_quarter, insertion_order = insertion_order));
  }

  /// Add a key signature
  addKeySignature(tick, accidentals, accidental_type, mode,
      {insertion_order = 0}) {
    this.eventList.add(KeySignature(tick, accidentals, accidental_type, mode,
        insertion_order = insertion_order));
  }

  /// Remove duplicates from the eventList.

  /// This function will remove duplicates from the eventList. This is
  ///  necessary because we the MIDI event stream can become confused
  ///  otherwise.

  /// For this algorithm to work, the events in the eventList must be
  /// hashable (that is, they must have a __hash__() and __eq__() function
  /// defined).
  removeDuplicates() {
    var s = this.eventList.toSet();
    this.eventList = s.toList();
    this.eventList = sortEvents(this.eventList);
  }

  /// Called to close a track before writing

  ///  This function should be called to "close a track," that is to
  /// prepare the actual data stream for writing. Duplicate events are
  ///   removed from the eventList, and the MIDIEventList is created.

  ///   Called by the parent MIDIFile object.

  closeTrack() {
    if (this.closed) {
      return;
    }

    this.closed = true;

    if (this.remdep) {
      this.removeDuplicates();
    }

    this.processEventList();
  }

  ///  Write the meta data and note data to the packed MIDI stream.

  writeMIDIStream() {
    // Process the events in the eventList

    this.writeEventsToStream();

    // Write MIDI close event.
//TODO: check that the next line is correct
    this.MIDIdata.addAll(MIDITrack.closeEvent);

    // Calculate the entire length of the data and write to the header

    this.dataLength = unsignedLong(this.MIDIdata.length);
  }

  /// Write the events in MIDIEvents to the MIDI stream.
  /// MIDIEventList is presumed to be already sorted in chronological order.

  writeEventsToStream() {
    int previous_event_tick = 0;
    for (var event in this.MIDIEventList) {
      this.MIDIdata.addAll(event.serialize(previous_event_tick));
      // previous_event_tick = event.tick
      // I do not like that adjustTimeAndOrigin() changes GenericEvent.tick
      // from absolute to relative. I intend to change that, and just
      // calculate the relative tick here, without changing GenericEvent.tick
    }
  }

  /// Process the event list, creating a MIDIEventList,
  /// which is then sorted to be in chronological order by start tick.
  processEventList() {
    this.MIDIEventList = this.eventList.sublist(0);
    // Assumptions in the code expect the list to be time-sorted.
    this.MIDIEventList = sortEvents(this.MIDIEventList);

    if (this.deinterleave) {
      this.deInterleaveNotes();
    }
  }

  /// Correct Interleaved notes.

  /// Because we are writing multiple notes in no particular order, we
  /// can have notes which are interleaved with respect to their start
  /// and stop times. This method will correct that. It expects that the
  /// MIDIEventList has been time-ordered.
  deInterleaveNotes() {
    List<GenericEvent> tempEventList = [];
    Map<dynamic, List> stack = {};

    for (var event in this.MIDIEventList) {
      if (['NoteOn', 'NoteOff'].contains(event.evtname)) {
        // !!! Pitch 101 channel 5 produces the same key as pitch 10 channel 15.
        // !!! This is not the only pair of pitch,channel tuples which
        // !!! collide to the same key, just one example.  Should fix by
        // !!! putting a separator char between pitch and channel.
        if ((event.evtname == 'NoteOn')) {
          event = event as NoteOn;
          var noteeventkey = event.pitch.toString() + event.channel.toString();
          if (stack.containsKey(noteeventkey)) {
            stack[noteeventkey]?.add(event.tick);
          } else {
            stack[noteeventkey] = [event.tick];
          }
          tempEventList.add(event);
        } else if (event.evtname == 'NoteOff') {
          event = event as NoteOff;
          var noteeventkey = event.pitch.toString() + event.channel.toString();
          if (stack[noteeventkey]!.length > 1) {
            event.tick = stack[noteeventkey]?.removeLast();
            tempEventList.add(event);
          } else {
            stack[noteeventkey]?.removeLast();
            tempEventList.add(event);
          }
        }
      } else {
        tempEventList.add(event);
      }
    }

    this.MIDIEventList = tempEventList;

    // Note NoteOff events have a lower secondary sort key than NoteOn
    // events, so this sort will make concomitant NoteOff events
    // processed first.

    this.MIDIEventList = sortEvents(this.MIDIEventList);
  }

  /// Adjust Times to be relative, and zero-origined.

  ///  If adjust is True, the track will be shifted. Regardelss times
  ///  are converted to relative values here.
  adjustTime() {
    if (this.MIDIEventList.length == 0) return;
    List<GenericEvent> tempEventList = [];
    final internal_origin = 0;
    var runningTick = 0;

    for (var event in this.MIDIEventList) {
      var adjustedTick = event.tick - internal_origin;
      event.tick = adjustedTick - runningTick;
      runningTick = adjustedTick;
      tempEventList.add(event);
    }

    this.MIDIEventList = tempEventList;
  }

  /// Write track to disk.
  Future<void> writeTrack(File fileHandle) async {
    await fileHandle.writeAsBytes(headerString, mode: FileMode.append);
    await fileHandle.writeAsBytes(this.dataLength, mode: FileMode.append);
    await fileHandle.writeAsBytes(this.MIDIdata, mode: FileMode.append);
    print(dataLength);
    print(MIDIdata);
    print("");
  }

  static (MIDITrack?, int?) fromMIDIBytes(Uint8List bytes, int offset) {
    if (offset >= bytes.length) {
      return (null, null);
    }

    offset = offset + MIDITrack.headerString.length;

    final dataLength = unsignedLongToInt(bytes, offset);

    offset += 4;

    final MIDIdata = bytes.sublist(
        offset, offset + dataLength - MIDITrack.closeEvent.length);

    print("====");
    print(dataLength);
    print(MIDIdata);

    var last_status = null;
    final notes = <GenericEvent>[];

    while (true) {
      // End of track reached.
      if (offset >= dataLength) {
        return (null, null);
      }

      var (delta, newOff) = readVarLength(bytes, offset);

      offset = newOff;

      var status_byte = bytes[offset];
      var peek_data = <int>[];
      if (status_byte < 0x80) {
        if (last_status == null) {
          throw OSError('running status without last_status');
        }
        peek_data = [status_byte];
        status_byte = last_status;
      } else {
        if (status_byte != 0xff)
          // Meta messages don't set running status.
          last_status = status_byte;
        peek_data = [];
      }

      var msg;

      if (status_byte == 0xff) {
        // msg = read_meta_message(infile, delta);
      } else if ([0xf0, 0xf7].contains(status_byte)) {
        // I'm not quite clear on the difference between
        // # f0 and f7 events.
        // msg = read_sysex(infile, delta, clip);
      } else {
        // msg = read_message(infile, status_byte, peek_data, delta, clip);
      }

      notes.add(msg);
    }

    offset = offset + dataLength;

    return (null, offset);
  }
}
