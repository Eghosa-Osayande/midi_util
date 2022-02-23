import 'generic_event.dart';
import 'utils.dart';

/// A class that encapsulates a controller event.

class ControllerEvent extends GenericEvent {
  String evtname = 'ControllerEvent';
  int midi_status = 0xB0; // 0x9x is Note On
  int sec_sort_order = 1;

  dynamic parameter;
  dynamic controller_number;
  int channel;

  ControllerEvent(this.channel, tick, this.controller_number, this.parameter,
      [insertion_order = 0])
      : super(tick, insertion_order);
  @override
  bool operator ==(Object other) {
    return false;
  }

  @override
  int get hashCode {
    return super.hashCode;
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
    midibytes.add(this.controller_number);
    midibytes.add(this.parameter);

    return midibytes;
  }
}
