module Audio.MainTypes where

import Dict exposing(Dict)
-- import Lib.MutableDict exposing (MutableDict)
import Lib.StringKeyMutableDict exposing (StringKeyMutableDict)
import Lib.GenericMutableDict as GenericMutableDict exposing (GenericMutableDict)

--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input ui
  = ID String -- a user supplied id
  | Value Float
  | Default -- Not needed now that we discovered using records as defaults. DELETEME
  | UI (ui -> Float) -- A user supplied function that maps from a user supplied model to a value
  | Node (AudioNode ui)
  | AutoID String  -- These ids are generated automatically when nested nodes are flattened by the Orchestrator
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



type alias ConstantBaseProps ui =
  { userId : Maybe String
  , autoId : Maybe String
  , inputs : Dict String (Input ui)
  }

type alias DynamicBaseProps = GenericMutableDict
  -- this will just contain "outputValue" for now (do we even use that? well, we will soon enough)

initialiseDynamicBaseProps : () -> GenericMutableDict
initialiseDynamicBaseProps () = GenericMutableDict.fromList [("outputValue", 0.0)]

  -- pretty annoying how you can't put it in the type definition!
  -- , outputValue : Float // this needs to be taken outputValue
-- once you get rid of userId.

-- Note, if none of these need to be updated during the audio loop, then maybe we can get away with putting
-- them inside the GenericMutableDict as a key:
-- So the GMD would look like (image it's record)
--  { baseProps: ConstantBaseProps
--  , outputValue : Float
--  , nodeProps : **something specific to the node**
--
-- It all has to go into the one GenericMutableDict, because we can't update a tuple.
-- But what if we have



-- doSomethingWithNode node =
--   case node of
--     Oscillator baseProps oscProps
--       let
--         _ = GenericMutableDict.update "phase" 0.1 oscProps  -- I actually thing the "_ =" is good, because it makes it clear that a mutation is happening.
--       in
--         node -- we can just return the original node, because node.oscProps still references the same js obj that has been updated in place!!
--           -- so the only difference, is that we don't have to reconstruct the node when returning it!



type alias DummyProps = { func: DummyF }


type AudioNode ui
  = Oscillator OscillatorF (ConstantBaseProps ui) DynamicBaseProps OscillatorProps
  | Destination (ConstantBaseProps ui) DynamicBaseProps
  | Dummy (ConstantBaseProps ui) DummyProps

type alias AudioNodes ui = List (AudioNode ui)


type alias OscillatorProps = GenericMutableDict
initialiseOscillatorProps : () -> GenericMutableDict
initialiseOscillatorProps () = GenericMutableDict.fromList [("phase", 0.0)]

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

type alias OscillatorF
    =  FrequencyFloat
    -> FrequencyOffsetFloat
    -> PhaseOffsetFloat
    -> PhaseFloat
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
-- type alias DictGraph ui = Dict String (AudioNode ui)
type alias DictGraph ui = StringKeyMutableDict (AudioNode ui)


-- updateConstantBaseProps : (BaseodeProps r ui -> BaseNodeProps r ui) -> AudioNode ui -> AudioNode ui
-- updateConstantBaseProps updateFunction node =
--   case node of
--     Oscillator props ->
--       Oscillator (updateFunction props)
--     _ ->
--       Debug.crash ""



-- HELPER FUNCTIONS ------------------------------------------------------------



updateConstantBasePropsCollectExtra : (ConstantBaseProps ui -> (ConstantBaseProps ui, a)) -> AudioNode ui -> (AudioNode ui, a)
updateConstantBasePropsCollectExtra updateFunc audioNode =
    case audioNode of
      Dummy baseProps b ->
        let
          (newConstantBaseProps, extra) = updateFunc baseProps
        in
          (Dummy newConstantBaseProps b, extra)
      Oscillator f baseProps b c ->
        let
          (newConstantBaseProps, extra) = updateFunc baseProps
        in
          (Oscillator f newConstantBaseProps b c, extra)
      Destination baseProps b  ->
        let
          (newConstantBaseProps, extra) = updateFunc baseProps
        in
          (Destination newConstantBaseProps b, extra)

updateConstantBaseProps : (ConstantBaseProps ui -> ConstantBaseProps ui) -> AudioNode ui -> AudioNode ui
updateConstantBaseProps updateFunc audioNode =
    case audioNode of
      Dummy baseProps b ->
        Dummy (updateFunc baseProps) b
      Oscillator f baseProps b c ->
        Oscillator f (updateFunc baseProps) b c
      Destination baseProps b ->
        Destination (updateFunc baseProps) b

applyToConstantBaseProps : (ConstantBaseProps ui -> a) -> AudioNode ui -> a
applyToConstantBaseProps func node =
  case node of
    Dummy baseProps _ -> func baseProps
    Oscillator _ baseProps _ _ -> func baseProps
    Destination baseProps _ -> func baseProps


getConstantBaseProps : AudioNode ui -> ConstantBaseProps ui
getConstantBaseProps node =
  applyToConstantBaseProps identity node

getNodeAutoId : AudioNode ui -> String
getNodeAutoId node =
  Maybe.withDefault "Nothing" (applyToConstantBaseProps .autoId node)
