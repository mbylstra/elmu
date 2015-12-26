module Orchestrator where

--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Dict exposing (Dict)
import ElmTest exposing (..)


--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import AudioNodes exposing
    ( squareWave
    , simpleLowPassFilter
    , sawWave
    , OscillatorType(Square, Saw, Triangle)
    , oscillator
    )


--------------------------------------------------------------------------------
-- TYPE DEFINITIONS
--------------------------------------------------------------------------------

type Input = ID String   -- or it could be an AudioNode!

type AudioNode =
    Generator
        { id : String
        , function : GeneratorF
        , state :
            { processed : Bool
            , outputValue : Float
            }
        }
    | FeedforwardProcessor
        { id : String
        , input : Input
        , function : FeedforwardProcessorF -- this is the "update"
        , state :  -- this is the "model"
            { processed : Bool
            , outputValue : Float
            , prevValues : List Float
            }
        }
    | Mixer
        { id : String
        , inputs : List Input
        , state :
            { processed : Bool
            , outputValue : Float
            }
        }
    | Destination
        { id : String
        , input: Input
        , state :
            { processed : Bool
            , outputValue : Float
            }
        }

-- Update functions
type alias GeneratorF = TimeFloat -> ValueFloat
type alias ProcessorF = TimeFloat -> ValueFloat -> ValueFloat
type alias FeedforwardProcessorF = Float -> List ValueFloat -> ValueFloat

-- aliases for readability
type alias ValueFloat = Float
type alias TimeFloat = Float
type alias ListGraph = List AudioNode
type alias DictGraph = Dict String AudioNode



--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------


updateGraph graph time =
     updateGraphNode graph time (getDestinationNode graph)

{- updateGraph graph time =
    (graph, time) -}


updateGraphNode : DictGraph -> TimeFloat -> AudioNode -> (DictGraph, Float)
updateGraphNode graph time node =
    case node of
        Generator props ->
            let
                newValue = props.function time
                newNode = updateNodeValue node newValue
            in
                (replaceGraphNode newNode graph, newValue)

        FeedforwardProcessor props ->
            case getInputNodes node graph of
                Just [inputNode] ->
                    let
                        (newGraph, inputValue) = updateGraphNode graph time inputNode
                        newValue = props.function inputValue props.state.prevValues
                        newNode = updateNodeValue node newValue
                    in
                        (replaceGraphNode newNode newGraph, newValue)
                Just inputNodes ->
                    Debug.crash("multiple inputs not supported yet")
                Nothing ->
                    Debug.crash("no input nodes!")


        Destination props ->
            case getInputNodes node graph of
                Just [inputNode] ->
                    let
                        (newGraph, inputValue) = updateGraphNode graph time inputNode
                        newNode = updateNodeValue node inputValue
                    in
                        (replaceGraphNode newNode newGraph, inputValue)
                Just inputNodes ->
                    Debug.crash("multiple inputs not supported yet")
                Nothing ->
                    Debug.crash("no input nodes!")

        _ -> Debug.crash("updateGraphNode not supported yet")



getInputNodes : AudioNode -> DictGraph -> Maybe (List AudioNode)
getInputNodes node graph =
    let
        getInputNode' : Input -> AudioNode
        getInputNode' input =
            case input of
                ID id ->
                    case (Dict.get id graph) of
                        Just node -> node
                        Nothing -> Debug.crash("Can't find node")

        getInputNodes' : List Input -> List AudioNode
        getInputNodes' inputs =
            List.map getInputNode' inputs
    in
        case node of
            FeedforwardProcessor props ->
                Just [getInputNode' props.input]
            Destination props ->
                Just [getInputNode' props.input]
            Mixer props ->
                Just <| getInputNodes' props.inputs
            _ ->
                Nothing



updateNodeValue : AudioNode -> Float -> AudioNode
updateNodeValue node newValue =
    case node of
        Generator props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Generator  { props | state = newState }
        Mixer props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Mixer { props | state = newState }
        FeedforwardProcessor props ->
            let
                oldState = props.state
                newPrevValues = rotateList props.state.outputValue props.state.prevValues
                newState =
                    { oldState |
                      outputValue = newValue
                    , prevValues = newPrevValues
                    }
            in
                FeedforwardProcessor { props | state = newState }
        Destination props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = newValue }
            in
                Destination { props | state = newState }


toDict : ListGraph -> DictGraph
toDict listGraph =
    let
        createTuple node =
            case node of
                Destination props ->
                    (props.id, node)
                Generator props ->
                    (props.id, node)
                FeedforwardProcessor props ->
                    (props.id, node)
                Mixer props ->
                    (props.id, node)
        tuples = List.map createTuple listGraph
    in
        Dict.fromList tuples


getDestinationNode : DictGraph -> AudioNode
getDestinationNode graph =
    let
        nodes = Dict.values graph
        isDestinationNode node =
            case node of
                Destination _ ->
                    True
                _ ->
                    False
        destinationNodes = List.filter isDestinationNode nodes
    in
        case List.head destinationNodes of
            Just node
                -> node
            _
                -> Debug.crash("There aren't any nodes of type Destination!")


replaceGraphNode : AudioNode -> DictGraph -> DictGraph
replaceGraphNode node graph =
    Dict.insert (getNodeId node) node graph


getNodeId : AudioNode -> String
getNodeId node =
    case node of
        Destination props -> props.id
        Generator props -> props.id
        FeedforwardProcessor props -> props.id
        Mixer props -> props.id



-- rotateArray : Array -> Array

--------------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------------

-- A

squareA =
    Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { processed = False, outputValue = 0.0  }
        }

destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { processed = False, outputValue = 0.0 }
        }

squareAT1 =
    Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { processed = False, outputValue = 1.0  }
        }

destinationAT1 =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { processed = False, outputValue = 1.0 }
        }

testGraph : ListGraph
testGraph =
    [ squareA
    , destinationA
    ]

testDictGraph : DictGraph
testDictGraph = toDict testGraph

-- B

squareB =
    Generator
        { id = "squareB"
        , function = squareWave
        , state =
            { processed = False, outputValue = 0.0  }
        }


lowpassB =
    FeedforwardProcessor
        { id = "lowpassB"
        , input = ID "squareB"
        , function = simpleLowPassFilter
        , state =
            { processed = False
            , outputValue = 0.0
            , prevValues = [0.0, 0.0, 0.0]
            }
        }

destinationB =
    Destination
        { id = "destinationB"
        , input = ID "lowpassB"
        , state =
            { processed = False, outputValue = 0.0 }
        }

{- squareAT1 =
    Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { outputValue = Just 1.0  }
        }

destinationAT1 =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = Just 1.0 }
        } -}

testGraphB : ListGraph
testGraphB =
    [ squareB
    , lowpassB
    , destinationB
    ]

testDictGraphB = toDict testGraphB




feetless : List a -> List a
feetless list =
    List.take ((List.length list) - 1) list


rotateList : a -> List a -> List a
rotateList value list  =
  [value] ++ feetless list

tests : Test
tests =
    suite "A Test Suite"
        [
{-           test "getInputNodes"
            (assertEqual
                (Just [squareA])
                (getInputNodes  destinationA testDictGraph)
            )
        , test "getInputNodes"
            (assertEqual
                Nothing
                (getInputNodes squareA testDictGraph)
            )
        , test "getNextSample"
            (assertEqual
                (toDict [squareAT1, destinationAT1], 1.0)
                (updateGraph testDictGraph 0.0)
            ) -}
          test "rotateList"
            (assertEqual
                [4, 3, 2]
                (rotateList 4 [3, 2, 1])
            )
        , test "getNextSample"
            (assertEqual
                (toDict [squareAT1, destinationAT1], 1.0)
                (updateGraph testDictGraphB 0.0)
            )
        ]


{- (Dict.fromList
    [ ("destination", Destination
        { id = "destination"
        , input = ID "square1"
        , state = { outputValue = Nothing }
        }
       )
    , ( "square1", Generator
        { id = "square1",
        , $function = <function>,
        , state = { outputValue = Just -1 }
        }
        )
    ]
    , -1
) -}

main =
    elementRunner tests
