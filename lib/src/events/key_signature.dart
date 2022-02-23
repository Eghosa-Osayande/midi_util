import 'generic_event.dart';
import 'utils.dart';

/// A class that encapsulates a key signature event

class KeySignature extends GenericEvent {
  String evtname = 'KeySignature';
  int sec_sort_order = 1;

  int accidentals;
  int accidental_type;
  int mode;

  KeySignature(tick, this.accidentals, this.accidental_type, this.mode,
      [insertion_order = 0])
      : super(tick, insertion_order);

  ///Return a bytestring representation of the event, in the format required for
  /// writing into a standard midi file.

  serialize(previous_event_tick) {
    List<int> midibytes = [];

    var code = 0xFF;
    var subcode = 0x59;
    var event_subtype = 0x02;
    List varTime = writeVarLength((this.tick - previous_event_tick).toInt());

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }

    midibytes.add(code);
    midibytes.add(subcode);
    midibytes.add(event_subtype);
    midibytes.add(this.accidentals * this.accidental_type);
    midibytes.add(this.mode);

    return midibytes;
  }
}
