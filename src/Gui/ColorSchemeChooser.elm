module Gui.ColorSchemeChooser where

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick, onMouseLeave, onMouseEnter)
import Random exposing (Seed)
import Array exposing (Array)
import Maybe exposing (withDefault)

import Gui.ColorScheme as ColorScheme exposing (ColorScheme)
import Lib.ColorExtra exposing (toCssRgb)


-- MODEL

randomInt : Int -> Seed -> (Int, Seed)
randomInt n seed =
  Random.generate (Random.int 0 n) seed


type alias Model =
  { colorSchemes : Array ColorScheme
  , current : ColorScheme
  , previewing : Maybe ColorScheme
  , seed : Seed
  , popupOpen : Bool
  }


init : Seed -> ColorScheme -> Model
init seed colorScheme =
  { colorSchemes = Array.fromList [colorScheme]
  , current = colorScheme
  , previewing = Nothing
  , seed = seed
  , popupOpen = False
  }

setColorSchemes : Model -> Array ColorScheme -> Model
setColorSchemes model colorSchemes =
  { model | colorSchemes = colorSchemes }

getColorScheme : Model -> ColorScheme
getColorScheme model =
  case model.previewing of
    Just cs -> cs
    Nothing -> model.current

-- UPDATE

type alias Index = Int
type Action
  = SelectRandom
  | OpenPopup
  | ClosePopup
  | PreviewColorScheme Index
  | StopPreviewingColorScheme

update : Action -> Model -> Model
update action model =
  case action |> Debug.log "action" of
    SelectRandom ->
      let
        (index, seed) = randomInt (Array.length model.colorSchemes) model.seed
        -- _ = Debug.log "SelectRandom" model
      in
        { model |
            current = withDefault model.current (Array.get index model.colorSchemes)
          , previewing = Nothing
          , seed = seed
        }
    OpenPopup ->
      { model | popupOpen = True }
    ClosePopup ->
      let
        _ = Debug.log "ClosePopup" True
      in
        { model | popupOpen = False }
    PreviewColorScheme index ->
        { model | previewing = Array.get index model.colorSchemes }
    StopPreviewingColorScheme ->
        { model | previewing = Nothing }

-- VIEW

colorSchemeView : Signal.Address Action -> Int -> ColorScheme -> Html
colorSchemeView address index colorScheme =
  let
    fields =
      [ .windowBackground
      , .pianoBlacks
      , .pianoWhites
      , .knobBackground
      , .knobForeground
      , .controlPanelBackground
      , .controlPanelBorders
      ]
    colors = List.map (\field -> field colorScheme) fields
    colorView color =
      div
        [ style [("background-color", (toCssRgb color)) ]
        , onMouseEnter address (PreviewColorScheme index)
        , onMouseLeave address (StopPreviewingColorScheme)
        ]
        []
  in
    div
      [ class "color-scheme-colors"]
      (List.map colorView colors)

view : Signal.Address Action -> Model -> Html
view address model =
  let
    popup =
      if model.popupOpen then [popupView address model] else []
  in
    div [ class "color-scheme-chooser"]
      (
        [ div
          [ class "current-color-scheme"
          , onClick address OpenPopup
          ]
          [ colorSchemeView address 0 model.current ]
        ]
        ++ popup
      )

popupView : Signal.Address Action -> Model -> Html
popupView address model =
  let
    colorSchemes = Array.toList (Array.indexedMap (colorSchemeView address) model.colorSchemes)
  in
    div
      [ class  "color-scheme-popup"
      , onMouseLeave address ClosePopup
      ]
      ( colorSchemes ++
        [ div
          [ class "random-color-button no-select"
          , onClick address SelectRandom
          ]
          [ text "⚀ ⚁ ⚂ ⚃ ⚄ ⚅"]
        ]
      )
