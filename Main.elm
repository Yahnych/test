import Html exposing (..)
import Html.App as Html
import WritingAdvice exposing (init, view, update, subscriptions)
--import Questions exposing (init, view, update)


-- APP

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


