/// TICKSPERQUARTERNOTE is the number of "ticks" (time measurement in the MIDI file) that
/// corresponds to one quarter note. This number is somewhat arbitrary, but should
/// be chosen to provide adequate temporal resolution.
const int TICKSPERQUARTERNOTE = 960;

Map controllerEventTypes = {'pan': 0x0a};

/// Accidental type
const int MAJOR = 0;

///Accidental type
const int MINOR = 1;

///C
const int SHARPS = 1;

///Accidentals
const int FLATS = -1;

class AccidentalType {
  static int SHARPS = 1;
  static int FLATS = -1;
}

class AccidentalMode {
  static int MAJOR = 0;
  static int MINOR = 1;
}
