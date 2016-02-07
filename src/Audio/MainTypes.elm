module Audio.MainTypes where

-- import Dict exposing(Dict)
import Lib.MutableDict exposing (MutableDict)

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input idType uiModel
  = ID idType
  | Value Float
  | Default
  | UI (uiModel -> Float)
  | Node (AudioNode idType uiModel)




    -- or it could be an AudioNode! Maybe?
    -- We could also consider conveniences like whether the unit is in hz, dbs, amps, or a "note" like C3
    -- eg: type NoteValue = A0 | B0 | C0 | D0 | E0 | F0 | G0 | A1 | A2 | etc
    -- eg : type Input = Note NoteValue | MidiNote Int |
    -- consider making ID NodeID instead, or just Node
    -- How do we get inputs from
     -- for now just make a dict, and put a dict key in.
     -- Or make a special node that connects to an exaternal value (?)
         -- the good thing about "External" is that you can tap into the signal for debugging easily.
             -- and maybe apply a smoothing func to the inputs?



-- It could be argued that having nested records is completely pointless if you're
-- not using extendable records. It will only lower performance, and make updating
-- records a massive pain in the arse. The only real benefit is slightly
-- better readability and namespacing (but I doubt we'd have clashes,
-- and the compiler helps with this anytway. You can alwas break things up
-- visually

type AudioNode idType uiModel =
    Oscillator
        { id : Maybe idType
        , inputs: OscillatorInputs idType uiModel
        , func : OscillatorF
        , state :
            { phase: Float
            , outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | Gain
        { id : Maybe idType
        , func : GainF
        , inputs: {signal: Input idType uiModel, gain: Input idType uiModel}
        , state :
            { outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
            }
        }
    | FeedforwardProcessor
        { id : Maybe idType
        , input : Input idType uiModel
        , func : FeedforwardProcessorF -- this is the "update"
        , state :  -- this is the "model"
            { outputValue : Float
            , prevValues : List Float
            }
        }
    | Add
        { id : Maybe idType
        , inputs : List (Input idType uiModel)
        , state :
            { outputValue : Float
            }
        }
    | Multiply
        { id : Maybe idType
        , inputs : List (Input idType uiModel)
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

type alias Destination idType uiModel =
  { input : Input idType uiModel
  , state :
      { outputValue : Float }
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

type alias OscillatorInputs idType uiModel=
    { frequency : Input idType uiModel
    , frequencyOffset : Input idType uiModel
    , phaseOffset : Input idType uiModel
    }

-- aliases for readability

type alias ExternalInputState =
    { xWindowFraction : Float
    , yWindowFraction : Float
    , audioOn : Bool
    }
type alias ExternalState =
    { time : Float
    , externalInputState : ExternalInputState
    }




type alias ListGraph idType uiModel = List (AudioNode idType uiModel)
type alias DictGraph idType uiModel = MutableDict idType (AudioNode idType uiModel)
