import 'generic_event.dart';
import 'utils.dart';

/// A class that encapsulates a Time Signature.
class TimeSignature extends GenericEvent {
  String evtname = 'TimeSignature';
  int sec_sort_order = 0;

  int numerator;
  int denominator;
  int clocks_per_tick;
  int notes_per_quarter;

  TimeSignature(tick, this.numerator, this.denominator, this.clocks_per_tick,
      this.notes_per_quarter,
      [insertion_order = 0])
      : super(tick, insertion_order);

  ///Return a bytestring representation of the event, in the format required for
  ///    writing into a standard midi file.
  serialize(previous_event_tick) {
    List<int> midibytes = [];
    var code = 0xFF;
    var subcode = 0x58;
    List varTime = writeVarLength((this.tick - previous_event_tick).toInt());

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }
    midibytes.add(code);
    midibytes.add(subcode);
    midibytes.add(0x04);
    midibytes.add(this.numerator);
    midibytes.add(this.denominator);
    midibytes.add(this.clocks_per_tick);
    // 32nd notes per quarter note
    midibytes.add(this.notes_per_quarter);
    return midibytes;
  }
}
