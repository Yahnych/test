import Html exposing (..)
import Html.App as Html
import WritingAdvice exposing (init, view, update)


-- APP

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }


