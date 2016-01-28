-- {
--     id: "carrier",                  // Name this unit generator "carrier," exposing it as an input to the synth.
--     ugen: "flock.ugen.sinOsc",      // Sine oscillator ugen.
--     freq: 440,                      // Give it a frequency of 440 Hz, or the A above middle C.
--     mul: {                          // Modulate the amplitude of this ugen with another ugen.
--         id: "mod",                      // Name this one "mod"
--         ugen: "flock.ugen.sinOsc",      // Also of type Sine Oscillator
--         freq: 1.0                       // Give it a frequency of 1 Hz, or one wobble per second.
--     }
-- }

import Audio.Atoms.Sine as Sine exposing (sine, sineDefaults)
-- no need to create a destination if it's just a tree graph
import Audio.MainTypes exposing (AudioNode,Input(Value, Node))



treeGraph : AudioNode
treeGraph =
  sine
    { sineDefaults
    | frequency = Value 440.0   -- the record default do kind of suck a bit, might as well stick to abbrevs like amp and freq
    , phaseOffset = Node (sine { sineDefaults | frequency = Value 1.0})
    }
