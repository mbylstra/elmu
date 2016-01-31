type NodeInstance = Sin1 | Sin2


type Input id guiModel
  = NodeID id
  | GUI (guiModel -> Float)

type AudioNode id guiModel
  = Oscillator
      { value : Float
      , frequency : (Input id guiModel)
      }
  | Add Input Input

-- So id is for naming and connecting nodes

type alias GuiModel =
  { attack : Float
  , decay: Float
  }

getAttack : GuiModel -> Float
getAttack model = model.attack


audioNode1 : AudioNode NodeInstance GuiModel
audioNode1 = Oscillator { value = 1.0, frequency = NodeID Sin1 }

audioNode2 : AudioNode NodeInstance GuiModel
audioNode2 = Oscillator { value = 1.0, frequency = GUI getAttack}
--
-- audioNode2 = NodeType1 { value = 1.0, input = Sin1 }



-- doSomethingWithAudioNode : AudioNode a -> Bool
-- doSomethingWithAudioNode audioNode =    -- interesting, so AudioNode must be a function that takes id as an argument, but it's just not at all clear from the type signature
--   case audioNode of
--     Oscillator id value ->
--       True
--     Destination value ->
--       True
