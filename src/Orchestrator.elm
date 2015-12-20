module Orchestrator where

import Dict exposing (Dict)

import AudioNodes exposing (sawWave, squareWave, simpleLowPassFilter)

type alias ValueFloat = Float
type alias TimeFloat = Float

type alias GeneratorF = TimeFloat -> ValueFloat
type alias ProcessorF = TimeFloat -> ValueFloat -> ValueFloat
type alias FeedforwardProcessorF = Float -> List ValueFloat -> ValueFloat


type Input = ID String   -- or it could be an AudioNode!

type alias OutputValue = Maybe Float



type alias Positioned a =
  { a | x : Float, y : Float }

type AudioNode =
    Generator
        { id : String
        , function : GeneratorF
        , state :
            { outputValue : OutputValue  }
        }
    | FeedforwardProcessor
        { id : String
        , input : Input
        , function : FeedforwardProcessorF -- this is the "update"
        , state :  -- this is the "model"
            { outputValue : OutputValue
            , prevValues : List Float
            }
        }
    | Mixer
        { id : String
        , inputs : List Input
        , state : { outputValue : OutputValue }
        }
    | Destination
        { id : String
        -- no function is required, we just take the value of the input
        -- it's kind of silly that you could have multiple destinations
        -- though. But this could have the destination id? (or dynamically
        -- get from available ids, in the case of multiple outs?)
        , input: Input
        , state:
            { outputValue: OutputValue }
        }



type alias ListGraph = List AudioNode

type alias DictGraph = Dict String AudioNode


-- why not use initialiser functions, and initialize the state there?
-- so the graph you build is always actual state


-- IDEA: use user supplied union type for node ids.
----- problems: can't use dict. Can not dynamically add new nodes!




type alias NodeState =
    { outputValue : ValueFloat
    , prevInputValues : List ValueFloat
    }

-- updateNodeState : AudioNode -> NodeState -> TimeFloat -> ValueFloat -> NodeState
-- updateNodeState node nodeState currentTime inputValue =
--     case node of
--         Generator props ->
--             let
--                 newValue = props.function currentTime
--             in
--                 { nodeState | outputValue = newValue }

--         FeedforwardProcessor props ->
--             let
--                 newValue = props.function inputValue nodeState.prevInputValues
--             in
--                 { outputValue = newValue
--                 , prevInputValues = [inputValue]
--                 }


-- updateGraphState
-- after updating the state of the entire graph, you just
-- get the output value of the node that's connected to Destination




-- updateGraphState graphState =
--     let
--         nodeGraphDict : Dict String AudioNode
--         nodeGraphDict = Dict.fromList graphState
--         destinationNode = getDestinationNode nodeGraphDict
--         nextNode = getInputNode destinationNode nodeGraphDict
--     in
--         -- maybe we need to be building a stack here?
--         case nextNode of
--             Generator data ->

--             _ ->
--                 graphstate





-- lets build a DAG, and if we hit any nodes that connect to any nodes already in the tree, then we create a new
-- node with a special type (FeedbackNode (?)), and initialise it with the previous value of the node that
-- it wants to point to. At the same time we should build a list of ids, so we know which
-- nodes are already in the tree, and so we can easily look up the previous value of a node
-- I guess we need to think about mixers??
--    mixers are fine (just a regular tree),
--    but splitters?
--        we can totally ignore paths that don't reach an output node (nice and efficient!)
--        and then splitters work on the same principle as feedback: if already computed, then
--        get previous value
--            Will this introduce a slight delay?
--                I guess so, but in reality in an anologue circuit there's going to be little delays
--                between signal paths
--                    But are those delays audible?
-- once we have the tree it should be reasonably easy to generate the output audio. We
-- need a (depth first traversal?) algorithm and update each node as we go along.
-- We can emulate this by applying a function to each node of a tree (surely
-- there's an example of this in elm?)
--    but it's trickier than that as the value must be based on the parent node,
--    so a tree reduce function would be more relevant. Eg: child node = parent node val + 1
--    It's an alg for getting tree depth!!







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
