port module WritingAdvice exposing (init, update, view, subscriptions) --where

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Questions exposing (..)
import Essay exposing (..)
import Markdown
import Header exposing (..)
import Defaults


-- MODEL

type alias Model = 
  { questions : Questions.Model
  , essay : Essay.Model
  , header : Header.Model
  }


init : (Model, Cmd Msg)
init =
  let 
    questions' =
      Questions.init
  in
  { questions = questions'
  , essay = Essay.init ""
  , header = Header.init
  }
  ![]


-- UPDATE

type Msg
  = UpdateQuestions Questions.Msg
  | UpdateHeader Header.Msg
  | UpdateHtmlEssay Essay.Msg
  | UpdateMarkdown --Questions.Model
  | LoadSavedData String
  | NoOp


-- A port to save the data
port save : String -> Cmd msg


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    {-
    UpdateQuestions msg ->
      { model | questions = questions' msg } 
      ![ snd(update (UpdateMarkdown (questions' msg)) model) ]

    UpdateMarkdown questions ->
      { model | essay = Essay.update (Essay.CreateMarkdown questions) model.essay }
      ![]
    -}
    UpdateQuestions msg ->
      let
        model' = { model | questions = Questions.update msg model.questions } 
      in
        update UpdateMarkdown model'

    UpdateMarkdown ->
      let 
        model' = 
          { model 
              | essay = Essay.update (Essay.UpdateMarkdown model.questions) model.essay 
          }
        
        essay' =
          .essay model'

        markdown' =
          .markdown essay'
      in
      model' ![ save markdown' ]

    LoadSavedData loadedData ->
      { model | essay = Essay.init loadedData }
      ![]

    UpdateHeader msg ->
      { model | header = Header.update msg model.header }
      ![]

    UpdateHtmlEssay msg ->
      { model | essay = Essay.update msg model.essay }
      ![]
    
    NoOp ->
      model 
      ![]


-- SUBSCRIPTIONS

port load : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model = 
  load LoadSavedData


-- VIEW

(=>) = (,)

view : Model -> Html Msg
view model =
  let
    mainContainerStyle =
      style
      [ "margin" => "0px"
      , "padding" => "0px"
      , "width" => "100vw"
      , "height" => "100vh"
      ]
    questionContainerStyle =
      style
      [ "padding" => "2vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "aliceBlue" 
      ]
    essayContainerStyle =
      style
      [ "padding" => "5vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "seaGreen"
      , "background-image" => ("url(" ++ Defaults.imagesLocation ++ "paper.png)") 
      , "-webkit-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "-moz-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      ]
    titleStyle =
      style
      [ "font-size" => "3.5em"
      , "font-family" => Defaults.titleFont
      , "padding-top" => "0.5em"
      ]


  in 
  div [ Html.Attributes.class "mdl-grid", mainContainerStyle ]
    [ div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
       [ App.map UpdateHeader (Header.view model.header)
       , h1 [ titleStyle ] [ text model.questions.title ]
       , App.map UpdateQuestions (Questions.view model.questions)
       ]
    , div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
       [ App.map UpdateHtmlEssay (Essay.view model.questions) 
       , Markdown.toHtml [] model.essay.markdown
       ]
    ]

