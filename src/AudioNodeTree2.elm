module AudioNodeTree where

import Dict exposing (Dict)
import String
import Graphics.Element exposing (Element, show)
import ElmTest exposing (..)

import Orchestrator exposing
    ( AudioNode (Generator, FeedforwardProcessor, Destination, Mixer)
    , ListGraph
    , Input (ID)
    , DictGraph
    , TimeFloat
    )
import AudioNodes exposing
    ( squareWave
    , simpleLowPassFilter
    , sawWave
    , OscillatorType(Square, Saw, Triangle)
    , oscillator
    )

-- I don't actually think we need the tree structure, as we
-- already have the graph!

{- type alias TreeNodeValue =
    { children: List AudioNodeTree
    , audioNode: AudioNode
    }


type AudioNodeTree
    = TreeNode TreeNodeValue
    | Leaf AudioNode -}


dummyAudioNode1 =
    Generator
        { id = "square1"
        , function = oscillator Saw 440.0
        , state =
            { outputValue = Nothing  }
        }

dummyAudioNode2 =
    FeedforwardProcessor
        { id = "lowpass"
        , input = ID "square1"
        , function = simpleLowPassFilter
        , state =
            { outputValue = Nothing
            , prevValues = [0.0]
            }
        }

-- dummyAudioNode3 =
--     Generator
--         { function = squareWave
--         , state =
--             { outputValue = Nothing  }
--         }



testGraph : ListGraph
testGraph =
    [ Generator
        { id = "square1"
        , function = squareWave
        , state =
            { outputValue = Nothing  }
        }
    , FeedforwardProcessor
        { id = "lowpass"
        , input = ID "square1"
        , function = simpleLowPassFilter
        , state =
            { outputValue = Nothing
            , prevValues = [0.0]
            }
        }
    , Destination
        { id = "destination"
        , input = ID "lowpass"
        , state =
            { outputValue = Nothing }
        }
    ]






{- updateGraph : DictGraph -> TimeFloat -> (DictGraph, Float)
updateGraph graph time =
    let
        destinationNode = getDestinationNode graph
    in
        updateGraphNode graph time destinationNode -}


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
                [intputNode] ->
                    let
                        (newGraph, inputValue) = updateGraphNode graph time node
                        newValue = props.function inputValue props.state.prevValues
                        newNode = updateNodeValue node newValue
                    in
                        (replaceGraphNode newNode graph, newValue)
                _ ->
                    Debug.crash("multiple inputs not supported yet")
        _ -> Debug.crash("not supported yet")



getInputNodes : AudioNode -> DictGraph -> List AudioNode
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
                [getInputNode' props.input]
            Destination props ->
                [getInputNode' props.input]
            Mixer props ->
                getInputNodes' props.inputs
            _ ->
                Debug.crash("does not have an input node")



updateNodeValue : AudioNode -> Float -> AudioNode
updateNodeValue node newValue =
    case node of
        Generator props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = Just newValue }
            in
                Generator  { props | state = newState }
        Mixer props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = Just newValue }
            in
                Mixer { props | state = newState }
        Destination props ->
            let
                oldState = props.state
                newState = { oldState | outputValue = Just newValue }
            in
                Destination { props | state = newState }
{-         Generator props ->
            func node
        FeedforwardProcessor props ->
            func node -}
        _ ->
            Debug.crash("not supported yet")


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

{- tests : Test
tests =
    suite "A Test Suite"
        , test "getNextSample" (assertEqual 1.3 (getNextSample 2340.432 testTree2))
        ]

main : Element
main =
    elementRunner tests -}
