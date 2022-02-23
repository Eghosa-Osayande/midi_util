import 'dart:typed_data';

import 'generic_event.dart';

List<int> unsignedLong(int value) {
  // struct.pack('>L', file_format)
  var r = Uint8List(4)..buffer.asInt32List()[0] = value;
  return r.reversed.toList();
}

List<int> unsignedShort(int value) {
  // struct.pack('>H', file_format)
  var r = Uint8List(2)..buffer.asInt16List()[0] = value;
  return r.reversed.toList();
}

/// Accept an integer, and serialize it as a MIDI file variable length quantity

/// Some numbers in MTrk chunks are represented in a form called a variable-
/// length quantity.  These numbers are represented in a sequence of bytes,
/// each byte holding seven bits of the number, and ordered most significant
/// bits first. All bytes in the sequence except the last have bit 7 set,
/// and the last byte has bit 7 clear.  This form allows smaller numbers to
/// be stored in fewer bytes.  For example, if the number is between 0 and
/// 127, it is thus represented exactly as one byte.  A number between 128
/// and 16383 uses two bytes, and so on.

/// Examples:
/// Number  VLQ
/// 128     81 00
/// 8192    C0 00
/// 16383   FF 7F
/// 16384   81 80 00

List writeVarLength(int i) {
  if (i == 0) {
    return [0];
  }

  List vlbytes = [];
  int hibit = 0x00; // low-order byte has high bit cleared.
  while (i > 0) {
    vlbytes.add(((i & 0x7f) | hibit) & 0xff);
    i >>= 7;
    hibit = 0x80;
  }

  vlbytes = vlbytes.reversed
      .toList(); // put most-significant byte first, least significant last
  return vlbytes;
}

sortEvents(List<GenericEvent> eventList) {
  eventList.sort((a, b) {
    return a.tick.compareTo(b.tick);
  });

  Set<int> setOfTicks = {};
  Set<int> setOfSortOrder = {};

  for (var event in eventList) {
    setOfTicks.add(event.tick);
    setOfSortOrder.add(event.sec_sort_order);
  }

  for (int tick in setOfTicks) {
    var first = eventList.indexWhere((element) => element.tick == tick);
    var last = eventList.lastIndexWhere((element) => element.tick == tick);
    if (first != last) {
      List<GenericEvent> secondLayer = eventList.sublist(first, last + 1);
      secondLayer.sort((a, b) {
        return a.sec_sort_order.compareTo(b.sec_sort_order);
      });
      eventList.replaceRange(first, last + 1, secondLayer);
    }
  }
  for (int tick in setOfTicks) {
    var first = eventList.indexWhere((element) =>
        (element.tick == tick) && (element.sec_sort_order == tick));
    var last = eventList.lastIndexWhere((element) =>
        (element.tick == tick) && (element.sec_sort_order == tick));
    if (first != last) {
      List<GenericEvent> thirdLayer = eventList.sublist(first, last + 1);
      thirdLayer.sort((a, b) {
        return a.insertion_order.compareTo(b.insertion_order);
      });
      eventList.replaceRange(first, last + 1, thirdLayer);
    }
  }
  return eventList;
}
