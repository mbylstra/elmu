module Lib.ListExtra (unsafeHead) where

unsafeHead : List a -> a
unsafeHead l =
  case List.head l of
    Just x -> x
    Nothing -> Debug.crash "unsafeHead was called on an empty list!"
