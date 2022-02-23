import 'generic_event.dart';
import 'utils.dart';

// A class that encapsulates a note on event

class NoteOn extends GenericEvent {
  String evtname = 'NoteOn';
  int midi_status = 0x90; // 0x9x is Note On
  int sec_sort_order = 3;
  int pitch;
  int duration;
  int volume;
  int channel;
  dynamic annotation;

  NoteOn(this.channel, this.pitch, tick, this.duration, this.volume,
      this.annotation,
      [insertion_order = 0])
      : super(tick, insertion_order);
  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (evtname == other.evtname &&
        tick == other.tick &&
        pitch == other.pitch &&
        channel == other.channel);
  }

  @override
  int get hashCode {
    return super.hashCode;
  }

  @override
  String toString() {
    return 'NoteOn $pitch at tick $tick duration $duration ch $channel vel $volume';
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
