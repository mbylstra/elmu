module AudioNodeTree where


--------------------------------------------------------------------------------
-- EXTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

import Dict exposing (Dict)
import ElmTest exposing (..)

--------------------------------------------------------------------------------
-- INTERNAL DEPENDENCIES
--------------------------------------------------------------------------------

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



--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

updateGraph : DictGraph -> TimeFloat -> (DictGraph, Float)
updateGraph graph time =
    let
        _ = Debug.log("updateGraph start")
    in
        updateGraphNode graph time (getDestinationNode graph)


updateGraphNode : DictGraph -> TimeFloat -> AudioNode -> (DictGraph, Float)
updateGraphNode graph time node =
    let
        _ = Debug.log("updateGraphNode start")

    in
        case node of
            Generator props ->
                let
                    _ = Debug.log("updating generator")
                    newValue = props.function time
                    newNode = updateNodeValue node newValue
                in
                    (replaceGraphNode newNode graph, newValue)

            FeedforwardProcessor props ->
                case getInputNodes node graph of
                    Just [intputNode] ->
                        let
                            (newGraph, inputValue) = updateGraphNode graph time node
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
                            _ = Debug.log("updating Destination")
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
        _ ->
            Debug.crash("updateNodeValue not supported yet")


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




--------------------------------------------------------------------------------
-- TESTS
--------------------------------------------------------------------------------

{- dummyAudioNode1 =
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
        } -}



-- dummyAudioNode3 =
--     Generator
--         { function = squareWave
--         , state =
--             { outputValue = Nothing  }
--         }

squareA =
    Generator
        { id = "squareA"
        , function = squareWave
        , state =
            { outputValue = Nothing  }
        }

destinationA =
    Destination
        { id = "destinationA"
        , input = ID "squareA"
        , state =
            { outputValue = Nothing }
        }

lowpassA =
    FeedforwardProcessor
        { id = "lowpassA"
        , input = ID "squareA"
        , function = simpleLowPassFilter
        , state =
            { outputValue = Nothing
            , prevValues = [0.0]
            }
        }

squareAT1 =
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
        }

testGraph : ListGraph
testGraph =
    [ squareA
    , destinationA
    ]

testDictGraph : DictGraph
testDictGraph = toDict testGraph

tests : Test
tests =
    suite "A Test Suite"
        [ test "getInputNodes"
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
