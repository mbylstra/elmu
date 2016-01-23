module Piano (piano, pianoSignal) where

import Html exposing (..)
import Html.Attributes exposing(..)
import Html.Events exposing(onMouseDown, Options)



pianoMailbox : Signal.Mailbox Float
pianoMailbox =  Signal.mailbox 60.0

pianoSignal : Signal Float
pianoSignal = pianoMailbox.signal

type KeyType = Black | White

pianoKey : KeyType -> Float -> Html
pianoKey keyType pitch  =
  case keyType of
    Black ->
      div [ class "black-key-wrapper"]
        [ div
          [ class "black-key"
          , onMouseDown pianoMailbox.address pitch
          ]
          []
        ]
    White ->
      div
        [ class "white-key"
        , onMouseDown pianoMailbox.address pitch
        ]
        []

pianoOctave : Float -> List Html.Html
pianoOctave cPitch =
  [ pianoKey White cPitch
  , pianoKey Black (cPitch + 1.0)
  , pianoKey White (cPitch + 2.0)
  , pianoKey Black (cPitch + 3.0)
  , pianoKey White (cPitch + 4.0)
  , pianoKey White (cPitch + 5.0)
  , pianoKey Black (cPitch + 6.0)
  , pianoKey White (cPitch + 7.0)
  , pianoKey Black (cPitch + 8.0)
  , pianoKey White (cPitch + 9.0)
  , pianoKey Black (cPitch + 10.0)
  , pianoKey White (cPitch + 11.0)
  ]

piano : Int -> Float -> Html.Html
piano numOctaves bottomPitch =
  let
    bottomPitches =
      List.map (\n -> bottomPitch + (toFloat n)*12.0) [1..numOctaves]
    pianoOctaves =
      List.concatMap (\octaveBottomPitch -> pianoOctave octaveBottomPitch ) bottomPitches
  in
    div [class "piano"]
        pianoOctaves
