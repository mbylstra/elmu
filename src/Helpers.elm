module Helpers where

import Dict
import List

import Audio.MainTypes exposing (..)

prefixDict :  String -> Dict.Dict comparable a -> Dict.Dict comparable a
prefixDict prefix d =
  d
  |> Dict.toList
  |> List.map (\(k, v) -> (prefix ++ "k", v))
  |> Dict.fromList



-- toDict : ListGraph idType uiModel -> DictGraph idType uiModel
toDict listGraph =
    let
        createTuple node =
            case node of
                Destination props ->
                    (props.id, node)
                -- Oscillator props ->
                --     (props.id, node)
                -- FeedforwardProcessor props ->
                --     (props.id, node)
                -- Add props ->
                --     (props.id, node)
                -- Gain props ->
                --     (props.id, node)
                -- Multiply _ ->
                --     Debug.crash "Multiply not supported"
                _ ->
                    Debug.crash "todo"
        tuples = List.map createTuple listGraph
    in
        Dict.fromList tuples
