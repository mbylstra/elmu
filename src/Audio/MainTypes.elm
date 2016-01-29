module Audio.MainTypes where

import Dict exposing(Dict)

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input = ID String | Value Float | Default | GUI String | Node AudioNode -- or it could be an AudioNode! Maybe?
    -- We could also consider conveniences like whether the unit is in hz, dbs, amps, or a "note" like C3
    -- eg: type NoteValue = A0 | B0 | C0 | D0 | E0 | F0 | G0 | A1 | A2 | etc
    -- eg : type Input = Note NoteValue | MidiNote Int |
    -- consider making ID NodeID instead, or just Node
    -- How do we get inputs from
     -- for now just make a dict, and put a dict key in.
     -- Or make a special node that connects to an exaternal value (?)
         -- the good thing about "External" is that you can tap into the signal for debugging easily.
             -- and maybe apply a smoothing func to the inputs?

type AudioNode =
    Oscillator
        { id : String
        , func : OscillatorF
        , inputs: OscillatorInputs
        , state :
            { phase: Float
            , outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | Gain
        { id : String
        , func : GainF
        , inputs: {signal: Input, gain: Input}
        , state :
            { outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | FeedforwardProcessor
        { id : String
        , input : Input
        , func : FeedforwardProcessorF -- this is the "update"
        , state :  -- this is the "model"
            { outputValue : Float
            , prevValues : List Float
            }
        }
    | Add
        { id : String
        , inputs : List Input
        , state :
            { outputValue : Float
            }
        }
    | Multiply 
        { id : String
        , inputs : List Input
        , state :
            { outputValue : Float
            }
        }
    -- | ExternalInput
    --     { id : String
    --     , input : String -- A dict key. Yeah, this needs a big rethink!
    --     , state :
    --         { outputValue : Float
    --         }
    --     }
    | Destination
        { id : String
        , input: Input
        , state :
            { outputValue : Float
            }
        }


-- Update funcs
type alias ProcessorF = TimeFloat -> ValueFloat -> ValueFloat
type alias FeedforwardProcessorF = Float -> List ValueFloat -> ValueFloat

type alias ValueFloat = Float
type alias TimeFloat = Float
type alias FrequencyFloat = Float
type alias PhaseOffsetFloat = Float
type alias OutputFloat = Float
type alias PhaseFloat = Float
type alias FrequencyOffsetFloat = Float

type alias OscillatorF =
    FrequencyFloat
    -> FrequencyOffsetFloat
    -> PhaseOffsetFloat
    -> TimeFloat
    -> (OutputFloat, PhaseFloat)
type alias GainF = Float -> Float -> Float

type alias OscillatorInputs =
    { frequency : Input
    , frequencyOffset : Input
    , phaseOffset : Input
    }

-- aliases for readability
type alias ListGraph = List AudioNode
type alias DictGraph = Dict String AudioNode

type alias ExternalInputState =
    { xWindowFraction : Float
    , yWindowFraction : Float
    , audioOn : Bool
    }
type alias ExternalState =
    { time : Float
    , externalInputState : ExternalInputState
    }
