import 'generic_event.dart';
import 'utils.dart';

/// A class that encapsulates a program change event.

class ProgramChange extends GenericEvent {
  String evtname = 'ProgramChange';
  int midi_status = 0xc0; // 0x9x is Note On
  int sec_sort_order = 1;

  int programNumber;
  int channel;

  ProgramChange(this.channel, tick, this.programNumber, [insertion_order = 0])
      : super(tick, insertion_order);
  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (evtname == other.evtname &&
        tick == other.tick &&
        this.programNumber == other.programNumber &&
        channel == other.channel);
  }

  @override
  int get hashCode {
    return super.hashCode;
  }

  serialize(previous_event_tick) {
    /// Return a bytestring representation of the event, in the format required for
    /// writing into a standard midi file.

    List<int> midibytes = [];
    int code = this.midi_status | this.channel;
    List varTime = writeVarLength(this.tick);

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }
    midibytes.add(code);
    midibytes.add(this.programNumber);

    return midibytes;
  }
}
