module Audio.Atoms.Adder where

import Audio.MainTypes exposing (AudioNode(Adder), AdderF, Input, initialiseDynamicBaseProps, InputsDict)
import Lib.MutableArray as MutableArray
import Dict

add : AdderF
add floats = MutableArray.sum floats   -- perhaps you could make a different function that averaged or tailed off logarithmically or something


-- sine : (Args uiModel) -> (AudioNode uiModel)
-- sine args =
--   Oscillator
--     sinWave
--     { userId = args.id
--     , autoId = Nothing
--     , inputs = Dict.fromList
--       [ ("frequency", args.frequency)
--       , ("frequencyOffset", args.frequencyOffset)
--       , ("phaseOffset", args.phaseOffset)
--       ]
--     }
--     (initialiseDynamicBaseProps ())
--     (initialiseOscillatorProps ())


-- adderDefaults

namedAdder : String -> List (Input uiModel) -> AudioNode uiModel
namedAdder name inputs =
  let
    -- we must convert List Inputs to a Dict to match the interface for BaseProps
    name' = if (name == "") then Nothing else (Just name)
    inputsDict =
      inputs
      |> List.indexedMap (\indexInt value -> (toString(indexInt), value))
      |> Dict.fromList
  in
    Adder
      add
      { userId = name'
      , autoId = Nothing
      , inputs = inputsDict
      }
      (initialiseDynamicBaseProps ())


adder : List (Input uiModel) -> AudioNode uiModel
adder inputs =
  namedAdder "" inputs

-- namedAdd : String -> List Input -> AudioNode
-- namedAdd id inputs =
--   Adder
--     { id = id
--     , inputs = inputs
--     , state =
--         { outputValue = 0.0 }
--     }
