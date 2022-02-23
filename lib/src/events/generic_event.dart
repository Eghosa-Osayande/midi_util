

/// Base class for midievents.
class GenericEvent {
  late String evtname;
  int sec_sort_order = 0;
  int insertion_order;
  int tick;
  late int pitch;
  late int channel;
  late int tempo;
  late int programNumber;
  late dynamic trackName;

  GenericEvent(this.tick, this.insertion_order);

  @override
  bool operator ==(Object other) {
    GenericEvent o = other as GenericEvent;
    return (evtname == other.evtname && tick == other.tick);
  }

  @override
  int get hashCode {
    var a = tick;
    a = (a + 0x7ed55d16) + (a << 12);
    a = (a ^ 0xc761c23c) ^ (a >> 19);
    a = (a + 0x165667b1) + (a << 5);
    a = (a + 0xd3a2646c) ^ (a << 9);
    a = (a + 0xfd7046c5) + (a << 3);
    a = (a ^ 0xb55a4f09) ^ (a >> 16);
    return a;
  }

  List<int> serialize(previous_event_tick) {
    return [];
  }
}
