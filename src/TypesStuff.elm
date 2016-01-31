-- STUFF FOR DECOUPLED AUDIO
--------------------------------------------------------------------------------


type Input idType guiModel
  = ID idType
  | GUI (guiModel -> Float)
  | Value Float

type alias OscillatorArgs idType guiModel =
      { id : Maybe idType
      , value : Float
      , frequency : Input idType guiModel
      }

type AudioNode idType guiModel
  = Oscillator    -- can not use o
      { id : Maybe idType
      , value : Float
      , frequency : Input idType guiModel
      }
      -- { id : Maybe idType
      -- , value : Float
      -- , frequency : (Input idType guiModel)
      -- }
  -- | Add Input Input

type alias NodeList idType guiModel = List (AudioNode idType guiModel)



-- So, defaults are where we're getting pretty messed up!
-- I think the issue is that seeing as Oscillator takes in user supplied
-- args, there's no way we can provide a default, so the user
-- must supplie the default :( This sucks. But let's see what happens?

-- oscDefaults : OscillatorArgs
-- oscDefaults : { frequency : Input a b, id : Maybe c, value : Float }
oscDefaults : OscillatorArgs idType guiModel
oscDefaults =
  { id = Nothing
  , value = 0.0
  , frequency = Value 0.0
  }


getId : (AudioNode idType guiModel) -> Maybe idType
getId node =
  case node of
    Oscillator node'->
      node'.id
    -- we must fill this out for all node types, unless we use extensible records!


getNode : (NodeList idType guiModel) -> idType -> Result String (AudioNode idType guiModel)
getNode nodeList id =
  let
    nodes = List.filter (\node -> (getId node == Just id)) nodeList
  in
    case nodes of
      [node] ->
        Ok node
      [] ->
        Err ("Could not find ID " ++ (toString id))
      nodes ->
        Err ("There are multiple nodes with ID " ++ (toString id))

-- oscillator : OscillatorArgs (idType guiModel) -> (AudioNode idType guiModel)
-- oscillator : OscillatorArgs (idType guiModel) ->
oscillator : (OscillatorArgs idType guiModel) -> (AudioNode idType guiModel)
oscillator args =
  Oscillator args



-- STUFF FOR GUI MODULE
--------------------------------------------------------------------------------
type alias GuiModel =
  { attack : Float
  , decay: Float
  }

getAttack : GuiModel -> Float
getAttack model = model.attack

-- STUFF FOR MAIN MODULE
--------------------------------------------------------------------------------

type NodeID = Sin1 | Sin2

audioNode1 : AudioNode NodeID GuiModel
audioNode1 = Oscillator
  { id = Just Sin1
  , value = 1.0
  , frequency = ID Sin2
  }


-- this time using defaults

audioNode2 : AudioNode NodeID GuiModel
audioNode2 = Oscillator
  { id = Just Sin1
  , value = 1.0
  , frequency = ID Sin2
  }


audioNodes : NodeList NodeID GuiModel
audioNodes = [audioNode1]


osc3 : AudioNode NodeID GuiModel
osc3 = oscillator oscDefaults

x : Result String (AudioNode NodeID GuiModel)
x = getNode audioNodes Sin1





--
-- audioNode2 = NodeType1 { value = 1.0, input = Sin1 }



-- doSomethingWithAudioNode : AudioNode a -> Bool
-- doSomethingWithAudioNode audioNode =    -- interesting, so AudioNode must be a function that takes id as an argument, but it's just not at all clear from the type signature
--   case audioNode of
--     Oscillator id value ->
--       True
--     Destination value ->
--       True
