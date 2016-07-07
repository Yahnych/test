

module Header exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Defaults exposing (..)
--import Markdown

{-
import Material
import Material.Scheme
import Material.Button as Button
import Material.Tooltip as Tooltip
import Material.Options exposing (css)
-}

-- MODEL

type alias Model = 
  { logo : String
  --, mdl : Material.Model
  , markdown : String
  }


init : Model
init = 
  { logo = Defaults.imagesLocation ++ "logoTVO_WritersDesk.png"
  --, mdl = Material.model
  , markdown = ""
  }


-- UPDATE

type Msg 
  = NoOp
  {-
  = MDL Material.Msg
  | Download
  | Pdf
  | UpdateMarkdown String
  -}

{-
port download : (String, String) -> Cmd msg

port pdf : (String, String) -> Cmd msg
-}

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    {-
    Pdf ->
      let
        fileName = 
          Defaults.projectTitle ++ ".doc"
      in
      model ! [ pdf (Defaults.projectTitle, model.markdown) ]

    Download ->
      let
        fileName = 
          Defaults.projectTitle ++ ".doc"
      in
      model ! [ download (fileName, model.markdown) ]
      --model ! []

    UpdateMarkdown markdown' ->
      { model | markdown = markdown' }
      ! []

    MDL msg ->
      Material.update MDL msg model

    -}
    NoOp ->
      model ! []


-- VIEW

{-
type alias Mdl = 
  Material.Model 
-}

view : Model -> Html Msg
view model =
  div []
    [ img [ src model.logo ] []
    {-
    , Button.render MDL [0] model.mdl
        [ Button.onClick Download 
        , Tooltip.attach MDL [3]
        , css "float" "right"
        ]
        [ text "word" ]
    , Tooltip.render MDL [3] model.mdl
        [ Tooltip.bottom
        , Tooltip.large
        ]
        [ text "Download to edit in Microsoft Word" ]
    , Button.render MDL [1] model.mdl
        [ Button.onClick Pdf
        , Tooltip.attach MDL [4] 
        , css "float" "right"
        ]
        [ text "pdf" ]
    , Tooltip.render MDL [4] model.mdl
        [ Tooltip.bottom
        , Tooltip.large
        ]
        [ text "Open as PDF to print or save" ]
    -}
    ]
  --|> Material.Scheme.top


