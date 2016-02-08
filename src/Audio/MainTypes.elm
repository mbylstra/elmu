module Audio.MainTypes where

-- import Dict exposing(Dict)
import Lib.MutableDict exposing (MutableDict)

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input idType uiModel
  = ID idType -- a user supplied ID type. Could be a tagged union, for type safety.
  | Value Float
  | Default -- Not needed now that we discovered using records as defaults. DELETEME
  | UI (uiModel -> Float) -- A user supplied function that maps from a user supplied model to a value
  | Node (AudioNode idType uiModel)
  | AutoID Int  -- These ids are generated automatically when nested nodes are flattened by the Orchestrator
    -- hmm, we have a big problem now. The DictGraph key can now be either a user supplied key or
    -- an Auto ID. We could make another union type, but that would make dict lookup slow and
    -- annoying to implement. So, the really dodgy solution is to make both AutoID and ID to
    -- get converted to a string. We prefix AutoID's with '__' to "namespace" them




    -- or it could be an AudioNode! Maybe?
      -- Yes. We've done this now!
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

type alias Identifiable r idType =
  { r | userId : Maybe idType, autoId : Int }

-- type alias Identifiable r idType =
--   { r | autoId : Int, id : Maybe idType }

-- type alias OscillatorR idType = Identifiable { score: Int } idType

type AudioNode idType uiModel =
  Oscillator
    (Identifiable
      -- inputs
      { frequency : Input idType uiModel
      , frequencyOffset : Input idType uiModel
      , phaseOffset : Input idType uiModel
      -- state
      , phase: Float
      , outputValue : Float
      }
      idType
    )

  -- These need to be converted to Identifiable's.
  -- | Gain
  --     { id : Maybe idType
  --     , func : GainF
  --     , inputs: {signal: Input idType uiModel, gain: Input idType uiModel}
  --     , state :
  --         { outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
  --         }
  --     }
  -- | FeedforwardProcessor
  --     { id : Maybe idType
  --     , input : Input idType uiModel
  --     , func : FeedforwardProcessorF -- this is the "update"
  --     , state :  -- this is the "model"
  --         { outputValue : Float
  --         , prevValues : List Float
  --         }
  --     }
  -- | Add
  --     { id : Maybe idType
  --     , inputs : List (Input idType uiModel)
  --     , state :
  --         { outputValue : Float
  --         }
  --     }
  -- | Multiply
  --     { id : Maybe idType
  --     , inputs : List (Input idType uiModel)
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
-- type alias DictGraph idType uiModel = MutableDict idType (AudioNode idType uiModel)
type alias DictGraph idType uiModel = MutableDict String (AudioNode idType uiModel)
