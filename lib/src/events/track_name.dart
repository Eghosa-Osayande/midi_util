
import 'generic_event.dart';
import 'utils.dart';


/// A class that encapsulates a track name event.
class TrackName extends GenericEvent {

    
    

  String evtname = 'TrackName';
  int sec_sort_order = 0;

  dynamic trackName;

  TrackName(tick, this.trackName, [insertion_order = 0])
      : super(tick, insertion_order);
  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (this.evtname == other.evtname &&
        this.tick == other.tick &&
        this.trackName == other.trackName);
  }

  @override
  int get hashCode {
    return super.hashCode;
  }


  /// Return a bytestring representation of the event, in the format required for
  /// writing into a standard midi file.
        
  serialize(previous_event_tick) {
    
    List<int>  midibytes = [];
    List varTime = writeVarLength((this.tick - previous_event_tick).toInt());

    for (var timeByte in varTime) {
      midibytes.add(timeByte);
    }
    midibytes.add(0xFF);
    midibytes.add(0x03);
    var dataLength = this.trackName.toString().length;
    var dataLengthVar = writeVarLength(dataLength);
    for (var i in dataLengthVar) {
      midibytes.add(i);
    }

    midibytes.addAll(this.trackName.toString().codeUnits);
    return midibytes;
  }
}
