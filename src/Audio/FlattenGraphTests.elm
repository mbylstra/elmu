--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


import Audio.Atoms.Adder exposing (namedAdder)
import Audio.Atoms.Sine  exposing (sine, sineDefaults)
import Audio.Atoms.Destination  exposing (destination)
import Audio.MainTypes exposing (Input(Node, Value))
import Audio.FlattenGraph exposing (flattenGraph, convertUserIdInputs, flattenNodeList)
import ElmTest exposing (..)
import Graphics.Element
import PrettyDebug

-- args1 : {accNodes:List (AudioNode ui), lastId:Int, input: Input ui}
-- args1 = {accNodes=[], lastId=0, input=Value 0.0}

-- oscillator1 = Oscillator
-- oscillator1 : AudioNode ui
--   { userId = Just "osc1"
--   , autoId = Nothing
--   , inputs = Dict.fromList
--     [("frequency", Value 440.0)
--     ,("frequencyOffset", Value 0.0)
--     ,("phaseOffset", Value 0.0)
--     ]
--   , outputValue = 0.0
--   , phase = 0.0
--   , func = sinWave
--   }


-- dummy1 = sine

testNodes1 =
  [ namedAdder "output"
    [ Node <| sine { sineDefaults | frequency = Value 440.0 }
    , Node <| sine { sineDefaults | frequency = Value 880.0 }
    -- , Node <| sine { sineDefaults | frequency = Value 220.0 }
    ]
  , destination "output"
  ]

-- dummy1 : AudioNode ui
-- dummy1 = Dummy
--   ( { userId = Just "dummy1"
--     , autoId = Nothing
--     , inputs = Dict.fromList
--       [("inputA", Value 440.0)]
--     , outputValue = 0.0
--     }
--   , { func = 0.0 }
--   )
-- --
-- --
-- -- -- dummy 3 points to dummy 4, dummy 2 points to dummy 3
-- --
-- dummy2 : AudioNode ui
-- dummy2 = Dummy
--   ( { userId = Just "dummy2"
--     , autoId = Nothing
--     , inputs = Dict.fromList
--       [ ( "inputA"
--         , Node
--           ( Dummy
--             ( { userId = Just "dummy3"
--               , autoId = Nothing
--               , inputs = Dict.fromList
--                 [ ( "inputA"
--                   , Node
--                     ( Dummy
--                       ( { userId = Just "dummy4"
--                         , autoId = Nothing
--                         , inputs = Dict.fromList
--                           [ ( "inputA"
--                             , ID "dummy1"
--                             )
--                           ]
--                         , outputValue = 0.0
--                         }
--                       , { func = 0.0 }
--                       )
--                     )
--                   )
--                 ]
--               , outputValue = 0.0
--               }
--             , { func = 0.0 }
--             )
--           )
--         )
--       ]
--     , outputValue = 0.0
--     }
--   , { func = 0.0 }
--   )
--
tests : Test
tests =
  suite ""
      [
        -- test ""
        --   (assertEqual
        --     (flattenInputLower
        --       {accNodes=[], lastId=0, input=(Value 0.0)}
        --     )
        --     Nothing
        --   )
--       -- , test ""
--       --     (assertEqual
--       --       1
--       --       (
--       --         let
--       --           result = flattenInputLower
--       --             { accNodes=[]
--       --             , lastId=0
--       --             , input= Node dummy1
--       --             }
--       --         in
--       --           result
--       --             |> Maybe.withDefault (0, 0, [])
--       --             |> snd
--       --             |> List.length
--       --       )
--       --     )
--       , test ""
--           (assertEqual
--             3
--             (
--               let
--                 result = flattenNode dummy2 0 []
--               in
--                 result
--                   |> \{lastId, nodes} -> nodes
--                   |> List.length
--             )
--           )
        test ""
          (assertEqual
            4
            (
              let
                result =
                  testNodes1
                  |> flattenNodeList
                  |> convertUserIdInputs
                _ = PrettyDebug.log "result" result
              in
                List.length result
                -- result
                --   |> \{lastId, nodes} -> nodes
                --   |> List.length
            )
          )
      ]
--
main : Graphics.Element.Element
main =
    elementRunner tests


-- why was only the the second one converted? It was pulled out, but the input wasn't updated
-- perhaps due to the automatic input names??
-- result: [
-- Oscillator <function> { userId = Nothing, autoId = Just "1", inputs = Dict.fromList [("frequency",Value 440),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 },
-- Oscillator <function> { userId = Nothing, autoId = Just "2", inputs = Dict.fromList [("frequency",Value 880),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 },
-- Adder <function> { userId = Just "output", autoId = Just "3", inputs = Dict.fromList
--   [ ("0", Node (Oscillator <function> { userId = Nothing, autoId = Nothing, inputs = Dict.fromList [("frequency",Value 440),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 }))
--   , ("1", AutoID "2")
--   ]
--   } { outputValue = 0 },
-- Destination { userId = Nothing, autoId = Just "4", inputs = Dict.fromList [("A",AutoID "3")] } { outputValue = 0 }]

-- result: [Dummy { userId = Just "dummy1", autoId = Just NaN, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy4", autoId = Just NaN, inputs = Dict.fromList [("inputA",Value 1)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy3", autoId = Just NaN, inputs = Dict.fromList [("inputA",AutoID NaN)], outputValue = 0, func = 0 },Dummy { userId = Just "dummy2", autoId = Just NaN, inputs = Dict.fromList [("inputA",AutoID NaN)], outputValue = 0, func = 0 }]


-- result:
-- [Dummy { userId = Just "dummy1", autoId = Just 1, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy4", autoId = Just 2, inputs = Dict.fromList [("inputA",Value 1)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy3", autoId = Just 3, inputs = Dict.fromList [("inputA",AutoID 2)], outputValue = 0, func = 0 },
-- Dummy { userId = Just "dummy2", autoId = Just 4, inputs = Dict.fromList [("inputA",AutoID 3)], outputValue = 0, func = 0 }]



-- [Dummy (({ userId = Just "dummy1", autoId = Just 1, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy4", autoId = Just 2, inputs = Dict.fromList [("inputA",Value 1)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy3", autoId = Just 3, inputs = Dict.fromList [("inputA",AutoID 2)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy2", autoId = Just 4, inputs = Dict.fromList [("inputA",AutoID 3)], outputValue = 0 },{ func = 0 }))]



-- [Dummy (({ userId = Just "dummy1", autoId = Just 1, inputs = Dict.fromList [("inputA",Value 440)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy4", autoId = Just 2, inputs = Dict.fromList [("inputA",AutoID 1)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy3", autoId = Just 3, inputs = Dict.fromList [("inputA",AutoID 2)], outputValue = 0 },{ func = 0 })),
-- Dummy (({ userId = Just "dummy2", autoId = Just 4, inputs = Dict.fromList [("inputA",AutoID 3)], outputValue = 0 },{ func = 0 }))]



-- result: [
-- Oscillator <function> { userId = Nothing, autoId = Just "1", inputs = Dict.fromList [("frequency",Value 440),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 },
-- Oscillator <function> { userId = Nothing, autoId = Just "2", inputs = Dict.fromList [("frequency",Value 880),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 },
-- Adder <function> { userId = Just "output", autoId = Just "3", inputs = Dict.fromList [("0",Node (Oscillator <function> { userId = Nothing, autoId = Nothing, inputs = Dict.fromList [("frequency",Value 440),("frequencyOffset",Value 0),("phaseOffset",Value 0)] } { outputValue = 0 } { phase = 0 })),("1",AutoID "2")] } { outputValue = 0 },Destination { userId = Nothing, autoId = Just "4", inputs = Dict.fromList [("A",AutoID "3")] } { outputValue = 0 }]
