module Helpers where

import List

-- import Audio.MainTypes exposing (..)
-- import Lib.MutableDict as MutableDict exposing (MutableDict, fromList)

import Dict

prefixDict :  String -> Dict.Dict comparable a -> Dict.Dict comparable a
prefixDict prefix d =
  d
  |> Dict.toList
  |> List.map (\(k, v) -> (prefix ++ "k", v))
  |> Dict.fromList



-- createTuple : AudioNode idType uiModel -> Maybe (idType, AudioNode idType uiModel)
-- createTuple node =
--   case node of
--     Oscillator props ->
--       case props.id of
--         Just id ->
--           Just (id, node)
--         Nothing ->
--           Nothing
--     -- FeedforwardProcessor props ->
--     --     (props.id, node)
--     -- Add props ->
--     --     (props.id, node)
--     -- Gain props ->
--     --     (props.id, node)
--     -- Multiply _ ->
--     --     Debug.crash "Multiply not supported"
--     _ ->
--         Debug.crash "todo"
--
-- -- toDict : ListGraph idType uiModel -> DictGraph idType uiModel
-- -- toDict : List (AudioNode a b) -> Dict.Dict a (AudioNode a b)
-- -- toDict : List (AudioNode a b) -> Dict.Dict a (AudioNode a b)

-- type alias DictGraph idType uiModel = Dict idType (AudioNode idType uiModel)

-- toMutableDict : ListGraph idType uiModel -> MutableDict idType (AudioNode idType uiModel)
-- toMutableDict listGraph =
--     let
--         -- createTuple node =
--         --     case node of
--         --         Oscillator props ->
--         --             (props.id, node)
--         --         -- FeedforwardProcessor props ->
--         --         --     (props.id, node)
--         --         -- Add props ->
--         --         --     (props.id, node)
--         --         -- Gain props ->
--         --         --     (props.id, node)
--         --         -- Multiply _ ->
--         --         --     Debug.crash "Multiply not supported"
--         --         _ ->
--         --             Debug.crash "todo"
--         -- validTuples =
--         -- tuples : List (Maybe (idType, AudioNode idType uiModel))
--         tuples = List.map createTuple listGraph
--
--         -- validTuples : List (idType, AudioNode idType uiModel)
--         validTuples = List.filterMap identity tuples
--           -- listGraph
--           -- |> List.map createTuple
--           -- |> List.filterMap identity
--     in
--         -- Dict.fromList validTuples
--         MutableDict.fromList validTuples
