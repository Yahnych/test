port module WritingAdvice exposing (init, update, view, subscriptions) --where

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Questions exposing (..)
import Essay exposing (..)
import Markdown
import Header exposing (..)
import Defaults
import Json.Encode
import Json.Decode exposing ((:=))
import Json.Decode.Pipeline
import Format


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
  | SetQuestions Questions.Model
  | NoOp


-- A port to save the data
-- port save : String -> Cmd msg
-- port save : Questions.Model -> Cmd msg
port save : Json.Encode.Value -> Cmd msg


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
        
      in
      -- model' ![ save markdown' ]
      -- model' ![ save model'.essay.markdown ]
      model' ![ sendToStorage model'.questions ]

    LoadSavedData loadedData ->
      { model | essay = Essay.init loadedData }
      ![]

    SetQuestions questionsModel ->
      -- { model | questions = questionsModel }
      model
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


-- JSON ENCODING AND DECODING


-- Encoding

encodeJson : Model -> Json.Encode.Value
encodeJson model =
  Json.Encode.object
    [ ("questions", encodeQuestion model.questions) ]


encodeQuestion : Questions.Model -> Json.Encode.Value
encodeQuestion model =
  Json.Encode.object
    [ ("title", Json.Encode.string model.title)
    , ("instructions", Json.Encode.string model.instructions)
    , ("questions", Json.Encode.list (List.map encodeQuestions model.questions))
    , ("field", Json.Encode.string model.field)
    , ("numberOfParagraphs", Json.Encode.int model.numberOfParagraphs)
    ]


encodeQuestions : Questions.Question -> Json.Encode.Value
encodeQuestions model = 
  Json.Encode.object
    [ ("question", Json.Encode.string model.question)
    , ("answer", Json.Encode.string model.answer)
    , ("completed", Json.Encode.bool model.completed)
    , ("editing", Json.Encode.bool model.editing)
    , ("id", Json.Encode.int model.id)
    , ("paragraphId", Json.Encode.int model.id)
    , ("rows", Json.Encode.int model.rows)
    , ("maxlength", Json.Encode.int model.maxlength)
    , ("format", encodeFormatStyle model.format)
    ]

encodeFormatStyle : Format.FormatStyle -> Json.Encode.Value
encodeFormatStyle formatStyle =
  case formatStyle of
    Format.Normal ->
      Json.Encode.string "Normal"

    Format.Quotation ->
      Json.Encode.string "Quotation"

    Format.AuthorOfQuotation ->
      Json.Encode.string "AuthorOfQuotation"


-- Decoding

decodeQuestionsModel : Json.Decode.Value -> Result String Questions.Model
decodeQuestionsModel questionsModelJson =
  Json.Decode.decodeValue questionsModelDecoder questionsModelJson


questionsModelDecoder : Json.Decode.Decoder Questions.Model
questionsModelDecoder =
  Json.Decode.object5 Questions.Model
    ("title" := Json.Decode.string)
    ("instructions" := Json.Decode.string)
    ("questions" := Json.Decode.list questionsDecoder)
    ("field" := Json.Decode.string)
    ("numberOfParagraphs" := Json.Decode.int)


questionsDecoder : Json.Decode.Decoder Questions.Question
questionsDecoder =
  Json.Decode.Pipeline.decode Questions.Question
    |> Json.Decode.Pipeline.required "question" Json.Decode.string
    |> Json.Decode.Pipeline.required "answer" Json.Decode.string
    |> Json.Decode.Pipeline.required "completed" Json.Decode.bool 
    |> Json.Decode.Pipeline.required "editing" Json.Decode.bool
    |> Json.Decode.Pipeline.required "id" Json.Decode.int
    |> Json.Decode.Pipeline.required "paragraphId" Json.Decode.int
    |> Json.Decode.Pipeline.required "rows" Json.Decode.int
    |> Json.Decode.Pipeline.required "maxlength" Json.Decode.int
    |> Json.Decode.Pipeline.required "format" formatStyleDecoder


formatStyleDecoder : Json.Decode.Decoder Format.FormatStyle
formatStyleDecoder =
  let
    decodeToFormatStyle string =
      case string of 
        "Normal" -> 
          Result.Ok Format.Normal

        "Quotation" ->
          Result.Ok Format.Quotation

        "AuthorOfQuotation" ->
          Result.Ok Format.AuthorOfQuotation

        _ -> Result.Err ("Not a valid FormatStyle: " ++ string)  
  in
    Json.Decode.customDecoder Json.Decode.string decodeToFormatStyle



-- Load and save functions

loadFromStorage : Json.Decode.Value -> Msg
loadFromStorage questionsModelJson =
  case (decodeQuestionsModel questionsModelJson) of
    Ok model -> 
      SetQuestions model

    _ -> 
      NoOp


sendToStorage : Questions.Model -> Cmd Msg
sendToStorage model =
  encodeQuestion model |> save

-- SUBSCRIPTIONS

--port load : (String -> msg) -> Sub msg
port load : (Json.Decode.Value -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model = 
  --load LoadSavedData
  load loadFromStorage


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

