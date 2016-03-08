import Html exposing (div, button, text, node, h2, p)
import StartApp.Simple as StartApp
import Gui.GridInput.Grid as Grid

main =
  StartApp.start { model = Grid.init 10 10, view = view, update = Grid.update }


styleNode cssString =
  node "style" [] [ text cssString ]



-- div : List Attribute -> List Html -> Html
-- div attributes children =
--     node "div" attributes children

view action model =
  div []
    [ styleNode """
        @import url(https://fonts.googleapis.com/css?family=Montserrat:700,400);
        body {
          padding: 40px;
          font-family: 'Montserrat', Arial, serif; font-weight: 400; 
        }
        h2 {
          font-family: 'Montserrat', Arial, serif; font-weight: 700;
        }
        .grid {
          display: flex;
          width: 500px;
          height: 500px;
          background-image: url("town.jpg");
          background-repeat: no-repeat;
          background-position: -50px -50px;
          border: 2px solid black;
        }
        .cell {
          width: 50px;
          height: 50px;
          /* border: 1px solid white; */
        }
        .cell.active {
          background-color: rgba(255, 0, 0, 0.4);
        }
      """
    , h2 [] [ text "PAINT THE TOWN RED"]
    , Grid.view action model
    , p [] [ text "Don't stop until it's completely red!"]
    ]
