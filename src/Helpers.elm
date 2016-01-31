module Helpers where

import Dict
import List

prefixDict :  String -> Dict.Dict comparable a -> Dict.Dict comparable a
prefixDict prefix d =
  d
  |> Dict.toList
  |> List.map (\(k, v) -> (prefix ++ "k", v))
  |> Dict.fromList
