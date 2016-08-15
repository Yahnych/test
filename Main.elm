import Html.App as Html
import EssayBuilder exposing (init, view, update, subscriptions)
--import Questions exposing (init, view, update)


-- APP

main : Program Never
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


