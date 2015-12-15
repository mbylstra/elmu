-- a list of records

import Dict exposing (Dict)

import ReactiveAudio exposing (sawWave, squareWave, simpleLowPassFilter)

type alias ValueFloat = Float
type alias TimeFloat = Float

type alias GeneratorF = TimeFloat -> ValueFloat
type alias ProcessorF = TimeFloat -> ValueFloat -> ValueFloat
type alias FeedforwardProcessorF = Float -> List ValueFloat -> ValueFloat


type Input = ID String   -- or it could be an AudioNode!

type alias OutputValue = Maybe Float

type AudioNode =
    Generator
        { function: GeneratorF
        , state =
            { outputValue : OutputValue  }
        }
    | FeedforwardProcessor
        { input: Input
        , function: FeedforwardProcessorF -- this is the "update"
        , state =  -- this is the "model"
            { outputValue: OutputValue
            , prevValues = List Float
            }
        }
    | Destination
        -- no function is required, we just take the value of the input
        -- it's kind of silly that you could have multiple destinations
        -- though. But this could have the destination id? (or dynamically
        -- get from available ids, in the case of multiple outs?)
        { input: Input
        , state:
            { outputValue: OutputValue }
        }



type alias NodeGraph = List (String, AudioNode)


-- why not use initialiser functions, and initialize the state there?
-- so the graph you build is always actual state


-- IDEA: use user supplied union type for node ids.
----- problems: can't use dict. Can not dynamically add new nodes!

testGraph : NodeGraph
testGraph =
    [
        ( "square1"
        , Generator
            { function = squareWave
            , state =
                { outputValue = Nothing  }
            }
        )
    ,
        ( "lowpass"
        , FeedforwardProcessor
            { input = ID "square1"
            , function = simpleLowPassFilter
            , state =
                { outputValue = Nothing
                , prevValues = [0.0]
                }
            }
        )
        ( "destination"
        , Destination { input = ID "lowpass" }
        )
    ]


type alias NodeState =
    { outputValue : ValueFloat
    , prevInputValues : List ValueFloat
    }

updateNodeState : AudioNode -> NodeState -> TimeFloat -> ValueFloat -> NodeState
updateNodeState node nodeState currentTime inputValue =
    case node of
        Generator props ->
            let
                newValue = props.function currentTime
            in
                { nodeState | outputValue = newValue }

        FeedforwardProcessor props ->
            let
                newValue = props.function inputValue nodeState.prevInputValues
            in
                { outputValue = newValue
                , prevInputValues = [inputValue]
                }


-- updateGraphState
-- after updating the state of the entire graph, you just
-- get the output value of the node that's connected to Destination

-- updateGraphState

-- I guess we need a graph structure?
    -- is that even POSSIBLE with immutable data structures?
        -- well, it is actually quite possible with dicts and string ids
            -- i guess you start from destination, and work backwards and build a stack structure?
                -- mixers might be tough! so start with basic path


                -- maybe other way round works best? Because then we can make destination a special value

-- generateInitialGraphState (nodes, lastNode) =
--     let
--         tuples = List.map (\node -> (node.id, node)) nodes
--         nodesDict = Dict.fromList tuples


-- using strings for input names seems a bit rough!
-- you could use records though
