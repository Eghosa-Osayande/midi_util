import 'generic_event.dart';
import 'utils.dart';

// A class that encapsulates a Note Off event

class NoteOff extends GenericEvent {
  String evtname = 'NoteOff';
  int midi_status = 0x80; // 0x8x is Note Off
  int sec_sort_order = 2; // must be less than that of NoteOn
  // If two events happen at the same time, the secondary sort key is
  // ``sec_sort_order``. Thus a class of events can be processed earlier than
  // another. One place this is used in the code is to make sure that note
  // off events are processed before note on events.
  int pitch;
  int volume;
  int channel;
  dynamic annotation;

  NoteOff(this.channel, this.pitch, tick, this.volume, this.annotation,
      [insertion_order = 0])
      : super(tick, insertion_order);

  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (this.evtname == other.evtname &&
        this.tick == other.tick &&
        this.pitch == other.pitch &&
        this.channel == other.channel);
  }

  @override
  int get hashCode {
    return super.hashCode;
  }

  @override
  String toString() {
    return 'NoteOff $pitch at tick $tick ch $channel vel $volume';
  }

  /// Return a bytestring representation of the event, in the format required for
  /// writing into a standard midi file.

  serialize(previous_event_tick) {
    List<int> midibytes = [];
    int code = this.midi_status | this.channel;
    List varTime = writeVarLength((this.tick - previous_event_tick).toInt());

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }
    midibytes.add(code);
    midibytes.add(this.pitch);
    midibytes.add(this.volume);

    return midibytes;
  }
}
