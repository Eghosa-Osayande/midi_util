import 'dart:io';

import 'constants.dart';
import 'events/utils.dart';
import 'midi_header.dart';
import 'midi_track.dart';

///    A class that encapsulates a full, well-formed MIDI file object.

/// This is a container object that contains a header (:class:`MIDIHeader`),
///   one or more tracks (class:`MIDITrack`), and the data associated with a
///proper and well-formed MIDI file.
///
class MIDIFile extends Object {
  late List<MIDITrack> tracks;
  late int numTracks;
  late MIDIHeader header;
  late bool adjust_origin;
  late bool closed;
  late int ticks_per_quarternote;
  late bool eventtime_is_ticks;
  late Function time_to_ticks;
  late int event_counter;

  MIDIFile(
      [numTracks = 1,
      bool removeDuplicates = true,
      bool deinterleave = true,
      bool adjust_origin = false,
      int file_format = 1,
      int ticks_per_quarternote = TICKSPERQUARTERNOTE,
      bool eventtime_is_ticks = false]) {
    this.tracks = [];
    if (file_format == 1) {
      this.numTracks =
          numTracks + 1; // this.tracks[0] is the baked-in tempo track
    } else {
      this.numTracks = numTracks;
    }

    this.header =
        MIDIHeader(this.numTracks, file_format, ticks_per_quarternote);

    this.adjust_origin = adjust_origin;
    this.closed = false;

    this.ticks_per_quarternote = ticks_per_quarternote;
    this.eventtime_is_ticks = eventtime_is_ticks;

    if (this.eventtime_is_ticks) {
      this.time_to_ticks = (x) => x;
    } else {
      this.time_to_ticks = this.quarter_to_tick;
    }

    List.generate(this.numTracks, (index) {
      this.tracks.add(MIDITrack(removeDuplicates, deinterleave));
    });

    this.event_counter = 0;
  }

  quarter_to_tick(quarternote_time) {
    return int.parse(
        (quarternote_time * this.ticks_per_quarternote).toString());
  }

  tick_to_quarter(ticknum) {
    return double.parse(ticknum.toString()) / this.ticks_per_quarternote;
  }

  /// Add notes to the MIDIFile object

  /// :param track: The track to which the note is added.
  /// :param channel: the MIDI channel to assign to the note. [Integer, 0-15]
  /// :param pitch: the MIDI pitch number [Integer, 0-127].
  /// :param time: the time at which the note sounds. The value can be either
  ///     quarter notes [Float], or ticks [Integer]. Ticks may be specified by
  ///     passing eventtime_is_ticks=True to the MIDIFile constructor.
  ///     The default is quarter notes.
  /// :param duration: the duration of the note. Like the time argument, the
  ///     value can be either quarter notes [Float], or ticks [Integer].
  /// :param volume: the volume (velocity) of the note. [Integer, 0-127].
  /// :param annotation: Arbitrary data to attach to the note.

  /// The ``annotation`` parameter attaches arbitrary data to the note. This
  /// is not used in the code, but can be useful anyway. As an example,
  /// I have created a project that uses MIDIFile to write
  /// `csound <http:///csound.github.io/>`_ orchestra files directly from the
  /// class ``EventList``.

  addNote(track, channel, pitch, time, duration, volume, [annotation]) {
    if (this.header.numeric_format == 1) {
      track += 1;
    }

    this.tracks[track].addNoteByNumber(
          channel,
          pitch,
          this.time_to_ticks(time),
          this.time_to_ticks(duration),
          volume,
          annotation: annotation,
          insertion_order: this.event_counter,
        );
    this.event_counter += 1;
  }

  /// Name a track.

  /// :param track: The track to which the name is assigned.
  /// :param time: The time (in beats) at which the track name event is
  ///     placed.  In general this should probably be time 0 (the beginning
  ///     of the track).
  /// :param trackName: The name to assign to the track [String]

  addTrackName(track, time, trackName) {
    if (this.header.numeric_format == 1) {
      track += 1;
    }

    this.tracks[track].addTrackName(this.time_to_ticks(time), trackName,
        insertion_order: this.event_counter);
    this.event_counter += 1;
  }
// *
  ///         Add a time signature event.

  ///         :param track: The track to which the signature is assigned. Note that
  ///             in a format 1 file this parameter is ignored and the event is
  ///             written to the tempo track
  ///         :param time: The time (in beats) at which the event is placed.
  ///             In general this should probably be time 0 (the beginning of the
  ///             track).
  ///         :param numerator: The numerator of the time signature. [Int]
  ///         :param denominator: The denominator of the time signature, expressed as
  ///             a power of two (see below). [Int]
  ///         :param clocks_per_tick: The number of MIDI clock ticks per metronome
  ///             click (see below).
  ///         :param notes_per_quarter: The number of annotated 32nd notes in a MIDI
  ///             quarter note. This is almost always 8 (the default), but some
  ///             sequencers allow this value to be changed. Unless you know that
  ///             your sequencing software supports it, this should be left at its
  ///             default value.

  ///         The data format for this event is a little obscure.

  ///         The ``denominator`` should be specified as a power of 2, with
  ///         a half note being one, a quarter note being two, and eight note
  ///         being three, etc. Thus, for example, a 4/4 time signature would
  ///         have a ``numerator`` of 4 and a ``denominator`` of 2. A 7/8 time
  ///         signature would be a ``numerator`` of 7 and a ``denominator``
  ///         of 3.

  ///         The ``clocks_per_tick`` argument specifies the number of clock
  ///         ticks per metronome click. By definition there are 24 ticks in
  ///         a quarter note, so a metronome click per quarter note would be
  ///         24. A click every third eighth note would be 3 * 12 = 36.

  ///         The ``notes_per_quarter`` value is also a little confusing. It
  ///         specifies the number of 32nd notes in a MIDI quarter note. Usually
  ///         there are 8 32nd notes in a quarter note (8/32 = 1/4), so
  ///         the default value is 8. However, one can change this value if
  ///         needed. Setting it to 16, for example, would cause the music to
  ///         play at double speed, as there would be 16/32 (or what could be
  ///         considered *two* quarter notes for every one MIDI quarter note.

  ///         Note that both the ``clocks_per_tick`` and the
  ///         ``notes_per_quarter`` are specified in terms of quarter notes,
  ///         even is the score is not a quarter-note based score (i.e.,
  ///         even if the denominator is not ``4``). So if you're working with a
  ///         time signature of, say, 6/8, one still needs to specify the clocks
  ///         per quarter note.

  addTimeSignature(track, time, numerator, denominator, clocks_per_tick,
      {notes_per_quarter = 8}) {
    if (this.header.numeric_format == 1) {
      track = 0;
    }

    this.tracks[track].addTimeSignature(this.time_to_ticks(time), numerator,
        denominator, clocks_per_tick, notes_per_quarter,
        insertion_order: this.event_counter);
    this.event_counter += 1;
  }

  /// Add notes to the MIDIFile object

  /// :param track: The track to which the tempo event  is added. Note that
  ///     in a format 1 file this parameter is ignored and the tempo is
  ///     written to the tempo track
  /// :param time: The time (in beats) at which tempo event is placed
  /// :param tempo: The tempo, in Beats per Minute. [Integer]

  addTempo(track, time, tempo) {
    if (this.header.numeric_format == 1) {
      track = 0;
    }

    this.tracks[track].addTempo(this.time_to_ticks(time), tempo,
        insertion_order: this.event_counter);
    this.event_counter += 1;
  }

  /// Add a Key Signature to a track

  /// :param track: The track to which this should be added
  /// :param time: The time at which the signature should be placed
  /// :param accidentals: The number of accidentals in the key signature
  /// :param accidental_type: The type of accidental
  /// :param mode: The mode of the scale

  /// The easiest way to use this function is to make sure that the symbolic
  /// constants for accidental_type and mode are imported. By doing this:

  /// .. code::

  ///     from midiutil.MidiFile import *

  /// one gets the following constants defined:

  /// * ``SHARPS``
  /// * ``FLATS``
  /// * ``MAJOR``
  /// * ``MINOR``

  /// So, for example, if one wanted to create a key signature for a minor
  /// scale with three sharps:

  /// .. code::

  ///     MyMIDI.addKeySignature(0, 0, 3, SHARPS, MINOR)

  addKeySignature(track, time, accidentals, accidental_type, mode,
      {insertion_order = 0}) {
    if (this.header.numeric_format == 1) {
      track = 0; // User reported that this is needed.
    }

    this.tracks[track].addKeySignature(
        this.time_to_ticks(time), accidentals, accidental_type, mode,
        insertion_order: this.event_counter);
    this.event_counter += 1;
  }

  ///Add a MIDI program change event.

  ///:param tracknum: The zero-based track number to which program change event is added.
  ///:param channel: the MIDI channel to assign to the event.  [Integer, 0-15]
  /// :param time: The time (in beats) at which the program change event is  placed [double].
  /// :param program: the program number. [Integer, 0-127].

  addProgramChange(tracknum, channel, time, program) {
    if (this.header.numeric_format == 1) {
      tracknum += 1;
    }

    this.tracks[tracknum].addProgramChange(
        channel, this.time_to_ticks(time), program,
        insertion_order: this.event_counter);
    this.event_counter += 1;
  }

  /// Add a channel control event

  /// :param track: The track to which the event is added.
  /// :param channel: the MIDI channel to assign to the event.[Integer, 0-15]
  /// :param time: The time (in beats) at which the event is placed [double].
  /// :param controller_number: The controller ID of the event.
  /// :param parameter: The event's parameter, the meaning of which varies by event type.

  addControllerEvent(track, channel, time, controller_number, parameter) {
    if (this.header.numeric_format == 1) {
      track += 1;
    }

    this.tracks[track].addControllerEvent(
        channel, this.time_to_ticks(time), controller_number, parameter,
        insertion_order: this.event_counter); // noqa: E128
    this.event_counter += 1;
  }

  /// Write the MIDI File.

  /// param fileHandle: A file handle that has been opened for binary
  /// writing.

  writeFile(File fileHandle) {
    this.header.writeFile(fileHandle);

    // Close the tracks and have them create the MIDI event data structures.
    this.close();

    // Write the MIDI Events to file.

    List.generate(this.numTracks, (i) {
      this.tracks[i].writeTrack(fileHandle);
    });
  }

  /// Close the MIDIFile for further writing.

  /// To close the File for events, we must close the tracks, adjust the time
  /// to be zero-origined, and have the tracks write to their MIDI Stream
  /// data structure.

  close() {
    if (this.closed) return;

    List.generate(this.numTracks, (i) {
      this.tracks[i].closeTrack();
      //  We want things like program changes to come before notes when
      //  they are at the same time, so we sort the MIDI events by both
      //  their start time and a secondary ordinality defined for each kind
      //  of event.
      this.tracks[i].MIDIEventList = sortEvents(this.tracks[i].MIDIEventList);
    });

    var origin = this.findOrigin();

    List.generate(this.numTracks, (i) {
      this.tracks[i].adjustTimeAndOrigin(origin, this.adjust_origin);
      this.tracks[i].writeMIDIStream();
    });

    this.closed = true;
  }

  /// Find the earliest time in the file's tracks.append.

  findOrigin() {
    var origin = 100000000; // A little silly, but we'll assume big enough

    // Note: This code assumes that the MIDIEventList has been sorted, so this
    // should be insured before it is called. It is probably a poor design to do
    // TODO: -- Consider making this less efficient but more robust by not
    //          assuming the list to be sorted.

    for (var track in this.tracks) {
      if (track.MIDIEventList.length > 0) {
        if (track.MIDIEventList[0].tick < origin) {
          origin = track.MIDIEventList[0].tick;
        }
      }
    }

    return origin;
  }
}
