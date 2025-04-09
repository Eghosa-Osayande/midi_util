import 'dart:io';
import 'dart:typed_data';

import 'events/utils.dart';

///Class to encapsulate the MIDI header structure.

/// This class encapsulates a MIDI header structure. It isn't used for much,
/// but it will create the appropriately packed identifier string that all
/// MIDI files should contain. It is used by the MIDIFile class to create a
/// complete and well formed MIDI pattern.
class MIDIHeader extends Object {
  static List<int> get headerString => [77, 84, 104, 100];
  static List<int> get headerSize => unsignedLong(6);
  // Format 1 = multi-track file
  late List<int> formatnum;
  late int numeric_format;
  late List<int> numTracks;
  late List<int> ticks_per_quarternote;

  MIDIHeader(int numTracks, int file_format, int ticks_per_quarternote) {
    this.formatnum = unsignedShort(file_format);
    this.numeric_format = file_format;
    this.numTracks = unsignedShort(numTracks);
    this.ticks_per_quarternote = unsignedShort(ticks_per_quarternote);
  }

  writeFile(File fileHandle) {
    fileHandle.writeAsBytesSync(MIDIHeader.headerString);
    fileHandle.writeAsBytesSync(MIDIHeader.headerSize, mode: FileMode.append);
    fileHandle.writeAsBytesSync(this.formatnum, mode: FileMode.append);
    fileHandle.writeAsBytesSync(this.numTracks, mode: FileMode.append);
    fileHandle.writeAsBytesSync(this.ticks_per_quarternote,
        mode: FileMode.append);

    // print([formatnum]);

    // print([numTracks]);
    // print([ticks_per_quarternote]);
    // print(' ');
  }

  static (MIDIHeader, int) fromMIDIBytes(Uint8List bytes) {
    int offset = MIDIHeader.headerString.length + MIDIHeader.headerSize.length;

    final formatNum = unsignedShortToInt(bytes, offset);

    offset += 2;
    final numTracks = unsignedShortToInt(bytes, offset);

    offset += 2;
    final ticks_per_quarternote = unsignedShortToInt(bytes, offset);

    offset += 2;

    return (MIDIHeader(numTracks, formatNum, ticks_per_quarternote), offset);
  }
}
