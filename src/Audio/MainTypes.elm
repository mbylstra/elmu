module Audio.MainTypes where

import Dict exposing(Dict)
-- import Lib.MutableDict exposing (MutableDict)

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input ui
  = ID String -- a user supplied id
  | Value Float
  | Default -- Not needed now that we discovered using records as defaults. DELETEME
  | UI (ui -> Float) -- A user supplied function that maps from a user supplied model to a value
  | Node (AudioNode ui)
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



type alias BaseProps ui =
  { userId : Maybe String
  , autoId : Maybe Int
  , inputs : Dict String (Input ui)
  , outputValue : Float
  }

type alias OscillatorProps = { phase: Float, func: OscillatorF }

type alias DummyProps = { func: DummyF }

type AudioNode ui
  = Oscillator (BaseProps ui, OscillatorProps)
  | Dummy (BaseProps ui, DummyProps)

type alias AudioNodes ui = List (AudioNode ui)


-- Can we remove the unions, and have just one data type?
-- you can make inputs a dict, and state could be some ungodly dict or matrix,
-- but the main problem is the func: This would get really ugly - it would
-- have to take a list of strings as an argument or something, at which
-- point, what is the advantage of functional programming?? At least with
-- js you can use an object for named arguments. Also, the actual (for example)
-- sine function would necessarily need to take in a list of strings,

type alias InputsDict ui = Dict String (Input ui)
  -- These need to be converted to NodeBase's.
  -- | Gain
  --     { id : Maybe idType
  --     , func : GainF
  --     , inputs: {signal: Input ui, gain: Input ui}
  --     , state :
  --         { outputValue : Float -- do we really need this? Is it just for feedback? Doesn't really hurt to keep as we need inputs anyway.
  --         }
  --     }
  -- | FeedforwardProcessor
  --     { id : Maybe idType
  --     , input : Input ui
  --     , func : FeedforwardProcessorF -- this is the "update"
  --     , state :  -- this is the "model"
  --         { outputValue : Float
  --         , prevValues : List Float
  --         }
  --     }
  -- | Add
  --     { id : Maybe idType
  --     , inputs : List (Input ui)
  --     , state :
  --         { outputValue : Float
  --         }
  --     }
  -- | Multiply
  --     { id : Maybe idType
  --     , inputs : List (Input ui)
  --     , state :
  --         { outputValue : Float
  --         }
  --     }


type alias Destination ui =
  { input : Input ui
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

type alias DummyF = Float

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




type alias ListGraph ui = List (AudioNode ui)
-- type alias DictGraph ui = MutableDict (AudioNode ui)
-- type alias DictGraph ui = MutableDict String (AudioNode ui)
type alias DictGraph ui = Dict Int (AudioNode ui)


-- updateBaseProps : (BaseodeProps r ui -> BaseNodeProps r ui) -> AudioNode ui -> AudioNode ui
-- updateBaseProps updateFunction node =
--   case node of
--     Oscillator props ->
--       Oscillator (updateFunction props)
--     _ ->
--       Debug.crash ""



-- HELPER FUNCTIONS ------------------------------------------------------------



updateBaseProps : (BaseProps ui -> (BaseProps ui, a)) -> AudioNode ui -> (AudioNode ui, a)
updateBaseProps updateFunc audioNode =
    case audioNode of
      -- Oscillator (baseProps, specific) ->
      --   let
      --     (newBaseProps, extra) = updateFunc baseProps
      --   in
      --     Oscillator (updateFunc base, specific)
      Dummy (baseProps, specific) ->
        let
          (newBaseProps, extra) = updateFunc baseProps
        in
          (Dummy (newBaseProps, specific), extra)
      _ -> Debug.crash("todo")
      -- Dummy (base, specific) -> Dummy (updateFunc base, specific)
      -- Dummy ->
      --   pass


applyToBaseProps : (BaseProps ui -> a) -> AudioNode ui -> a
applyToBaseProps func instrument =
  case instrument of
    Dummy (baseProps, _) -> func baseProps
    _ -> Debug.crash "TODO"
