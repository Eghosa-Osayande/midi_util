import 'generic_event.dart';
import 'utils.dart';

/// A class that encapsulates a tempo meta-event
class Tempo extends GenericEvent {
  String evtname = 'Tempo';

  int sec_sort_order = 3;

  late int tempo;

  Tempo(tick, tempo, [insertion_order = 0]) : super(tick, insertion_order) {
    this.tempo = (60000000 ~/ tempo);
  }

  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (this.evtname == other.evtname &&
        this.tick == other.tick &&
        this.tempo == other.tempo);
  }

  @override
  int get hashCode {
    return super.hashCode;
  }

  /// Return a bytestring representation of the event, in the format required for
  ///     writing into a standard midi file.

  ///       Standard MIDI File Format says:

  ///      FF 51 03 tttttt Set Tempo (in microseconds per MIDI quarter-note)
  ///      This event indicates a tempo change. Another way of putting
  ///      "microseconds per quarter-note" is "24ths of a microsecond per MIDI
  ///      clock". Representing tempos as time per beat instead of beat per time
  ///      allows absolutely exact long-term synchronisation with a time-based
  ///      sync protocol such as SMPTE time code or MIDI time code. The amount
  ///      of accuracy provided by this tempo resolution allows a four-minute
  ///      piece at 120 beats per minute to be accurate within 500 usec at the
  ///      end of the piece. Ideally, these events should only occur where MIDI
  ///      clocks would be located -- this convention is intended to guarantee,
  ///      or at least increase the likelihood, of compatibility with other
  ///      synchronisation devices so that a time signature/tempo map stored in
  ///      this format may easily be transferred to another device.

  ///      Six identical lower-case letters such as tttttt refer to a 24-bit value, stored
  ///      most-significant-byte first. The notation len refers to the

  serialize(previous_event_tick) {
    List<int> midibytes = [];
    var code = 0xFF;
    var subcode = 0x51;
    var fourbite = unsignedLong(this.tempo); // big-endian uint32
    var threebite = fourbite.sublist(1); //Just discard the MSB
    List varTime = writeVarLength((this.tick - previous_event_tick).toInt());

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }
    midibytes.add(code);
    midibytes.add(subcode);
    midibytes.add(0x03); //length in bytes of 24-bit tempo;
    midibytes.addAll(threebite);
    return midibytes;
  }
}
