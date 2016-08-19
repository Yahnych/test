port module EssayBuilder exposing (init, update, view, subscriptions) --where

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Questions exposing (..)
import Essay exposing (..)
import Header exposing (..)
import Defaults
import Json.Encode
import Json.Decode exposing ((:=))
import Json.Decode.Pipeline
import Format
import Data

import Material
-- import Material.Grid exposing (grid, cell, size, Device(..))


-- MODEL

type alias Model = 
  { questions : Questions.Model
  , essay : Essay.Model
  , header : Header.Model
  , ieVersionNumber : Int
  , mdl : Material.Model
  }


init : (Model, Cmd Msg)
init =
  let 
    questions' =
      Questions.init

    model' = 
      { questions = questions'
      , essay = Essay.init questions'.content ""
      , header = Header.init
      , ieVersionNumber = 0
      , mdl = Material.model
      }
  in
    model' ! [ checkIeVersion model'.ieVersionNumber ]
    

-- UPDATE

type Msg
  = UpdateQuestions Questions.Msg
  | UpdateHeader Header.Msg
  | UpdateHtmlEssay Essay.Msg
  | UpdateMarkdown --Questions.Model
  -- | LoadSavedData String
  | SetQuestions Questions.Content
  | CheckIE Int
  | MDL (Material.Msg Msg)
  | NoOp


-- A port to save the data
-- port save : String -> Cmd msg
-- port save : Questions.Model -> Cmd msg
port save : Json.Encode.Value -> Cmd msg

-- A port to capture the version of IE
port checkIeVersion : Int -> Cmd msg


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of

    MDL msg' ->
      Material.update msg' model

    CheckIE versionNumber ->
      let
        essay = model.essay
        essay' =
          { essay
             | ieVersionNumber = versionNumber
          }

      in
      { model 
          | ieVersionNumber = versionNumber
          , essay = essay'
      }
      ! []

    UpdateQuestions msg ->
      let
        (questions', questionsFx) 
          = Questions.update msg model.questions

        model' 
          = { model | questions = questions' } 
        
        -- We have to recurrsively call `update` before mapping
        -- the child modules effects
        (model'', fx'') = update UpdateMarkdown model'
      in
        model'' ! [ Cmd.map UpdateQuestions questionsFx, fx'' ]

    UpdateMarkdown ->
      let 
        (essay', essayFx) = 
          Essay.update (Essay.UpdateMarkdown model.questions.content) model.essay
        
        {-
        (header', headerFx) = 
          Header.update (Header.UpdateMarkdown essay'.markdown) model.header
        -}

        model' = 
          { model 
              | essay = essay'
              --, header = header' 
          }
        
      in
        update (UpdateHtmlEssay <| Essay.UpdateEssay model'.questions.content) model'

    UpdateHtmlEssay msg ->
      let
        (essay', essayFx) = 
          Essay.update msg model.essay

        model' = { model | essay = essay' }
      in
        model' ! 
          [ sendToStorage model'.questions.content 
          , Cmd.map UpdateHtmlEssay essayFx
          ]
    
    UpdateHeader msg ->
      let
        (header', fx) = Header.update msg model.header
      in
      { model | header = header' }
      ![ Cmd.map UpdateHeader fx ]

    SetQuestions questionsContent ->
      let
        questionsModel' currentQuestionsModel =
          { currentQuestionsModel
              | content = questionsContent  --content'
          }

        model' = 
          { model 
              | questions = questionsModel' model.questions 
              , essay = Essay.init questionsContent ""
          }
      in
        model' ![]

    NoOp ->
      model 
      ![]


-- JSON ENCODING AND DECODING


-- Encoding

encodeJson : Model -> Json.Encode.Value
encodeJson model =
  Json.Encode.object
    [ ("questions", encodeQuestion model.questions.content) ]


encodeQuestion : Questions.Content -> Json.Encode.Value
encodeQuestion model =
  Json.Encode.object
    [ ("title", Json.Encode.string model.title)
    , ("instructions", Json.Encode.string model.instructions)
    , ("questions", Json.Encode.list (List.map encodeQuestions model.questions))
    , ("questionGroups", Json.Encode.list (List.map encodeQuestionGroups model.questionGroups))
    , ("numberOfParagraphs", Json.Encode.int model.numberOfParagraphs)
    , ("percentageComplete", Json.Encode.int model.percentageComplete)
    , ("selectedGroupPercentageComplete", Json.Encode.int model.selectedGroupPercentageComplete)
    , ("completionMessage", Json.Encode.string model.completionMessage)
    ]


encodeQuestions : Questions.Question -> Json.Encode.Value
encodeQuestions model = 
  Json.Encode.object
    [ ("question", Json.Encode.string model.question)
    , ("answer", Json.Encode.string model.answer)
    , ("completed", Json.Encode.bool model.completed)
    , ("editing", Json.Encode.bool model.editing)
    , ("id", Json.Encode.int model.id)
    , ("paragraphId", Json.Encode.int model.paragraphId)
    , ("groupId", Json.Encode.int model.groupId)
    , ("rows", Json.Encode.int model.rows)
    , ("maxlength", Json.Encode.int model.maxlength)
    , ("format", encodeFormatStyle model.format)
    ]

encodeQuestionGroups : Data.QuestionGroup -> Json.Encode.Value
encodeQuestionGroups model = 
  Json.Encode.object
    [ ("title", Json.Encode.string model.title)
    , ("description", Json.Encode.string model.description)
    , ("navigationHeading", Json.Encode.string model.navigationHeading)
    , ("groupId", Json.Encode.int model.groupId)
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

    Format.Title ->
      Json.Encode.string "Title"

-- Decoding

decodeQuestionsModel : Json.Decode.Value -> Result String Questions.Content
decodeQuestionsModel questionsModelJson =
  Json.Decode.decodeValue questionsModelDecoder questionsModelJson

 
questionsModelDecoder : Json.Decode.Decoder Questions.Content
--questionsModelDecoder : Json.Decode.Decoder (Material.Model -> Questions.Model)
questionsModelDecoder =
  Json.Decode.object8 Questions.Content
    ("title" := Json.Decode.string)
    ("instructions" := Json.Decode.string)
    ("questions" := Json.Decode.list questionsDecoder)
    ("questionGroups" := Json.Decode.list questionGroupsDecoder)
    ("numberOfParagraphs" := Json.Decode.int)
    ("percentageComplete" := Json.Decode.int)
    ("selectedGroupPercentageComplete" := Json.Decode.int)
    ("completionMessage" := Json.Decode.string)


questionGroupsDecoder : Json.Decode.Decoder Data.QuestionGroup
questionGroupsDecoder =
  Json.Decode.Pipeline.decode Data.QuestionGroup
    |> Json.Decode.Pipeline.required "title" Json.Decode.string
    |> Json.Decode.Pipeline.required "description" Json.Decode.string
    |> Json.Decode.Pipeline.required "navigationHeading" Json.Decode.string 
    |> Json.Decode.Pipeline.required "groupId" Json.Decode.int


questionsDecoder : Json.Decode.Decoder Questions.Question
questionsDecoder =
  Json.Decode.Pipeline.decode Questions.Question
    |> Json.Decode.Pipeline.required "question" Json.Decode.string
    |> Json.Decode.Pipeline.required "answer" Json.Decode.string
    |> Json.Decode.Pipeline.required "completed" Json.Decode.bool 
    |> Json.Decode.Pipeline.required "editing" Json.Decode.bool
    |> Json.Decode.Pipeline.required "id" Json.Decode.int
    |> Json.Decode.Pipeline.required "paragraphId" Json.Decode.int
    |> Json.Decode.Pipeline.required "groupId" Json.Decode.int
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

        "Title" ->
          Result.Ok Format.Title

        _ -> Result.Err ("Not a valid FormatStyle: " ++ string)  
  in
    Json.Decode.customDecoder Json.Decode.string decodeToFormatStyle



-- Load and save functions

loadFromStorage : Json.Decode.Value -> Msg
loadFromStorage questionsModelJson =
  case (decodeQuestionsModel questionsModelJson) of
    Ok model -> 
      SetQuestions model
      --SetQuestions model.questions.content

    _ ->
      NoOp


sendToStorage : Questions.Content -> Cmd Msg
sendToStorage model =
  encodeQuestion model |> save

-- SUBSCRIPTIONS

--port load : (String -> msg) -> Sub msg
port load : (Json.Decode.Value -> msg) -> Sub msg

--Capture the incoming IE version number
port ieVersion : (Int -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model = 
  Sub.batch
    [ ieVersion CheckIE 
    , load loadFromStorage
    ]


-- VIEW

(=>) : a -> b -> ( a, b )
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
      --"overflow" => "hidden"
      , "overflow-y" => "auto"
      --, "overflow-x" => "auto"
      , "position" => "relative"
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
      [ "font-size" => "2.5em"
      , "font-family" => Defaults.titleFont
      --, "padding-top" => "0.2em"
      , "padding-top" => "0.3em"
      , "padding-bottom" => "0em"
      --, "position" => "fixed"
      ]

    spacerStyle =
      style
      [ "height" => "6em"
      ]


  in 
    div [ Html.Attributes.class "mdl-grid", mainContainerStyle, id "test" ]
     [ div 
         [ Html.Attributes.id "questionsContainer", Html.Attributes.class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
         [ App.map UpdateHeader (Header.view model.header)
         , h1 [ titleStyle ] [ text model.questions.content.title ]
         , App.map UpdateQuestions (Questions.view model.questions)

         -- This spacer div is an unfortunate cross-platform hack to add default
         -- padding at the bottom of the questions box 
         , div [ spacerStyle ] []
         ]
      , div 
         [ Html.Attributes.class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
         [ App.map UpdateHtmlEssay (Essay.view model.essay) 
         --, Markdown.toHtml [] model.essay.markdown
         ]
     ]
  {-
  div [ Html.Attributes.class "mdl-grid", mainContainerStyle ]
   [ div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
       [ App.map UpdateHeader (Header.view model.header)
       , h1 [ titleStyle ] [ text model.questions.content.title ]
       , App.map UpdateQuestions (Questions.view model.questions)

       -- This spacer div is an unfortunate cross-platform hack to add default
       -- padding at the bottom of the questions box 
       , div [ spacerStyle ] []
       ]
    , div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
       [ App.map UpdateHtmlEssay (Essay.view model.essay) 
       --, Markdown.toHtml [] model.essay.markdown
       ]
   ]
  -}
  {-
  div [ Html.Attributes.class "mdl-grid", mainContainerStyle ]
    [ div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
       [ -- App.map UpdateHeader (Header.view model.header)
       -- h1 [ titleStyle ] [ text model.questions.content.title ]
       --, App.map UpdateQuestions (Questions.view model.questions)
       App.map UpdateQuestions (Questions.tabView model.questions)

       -- This spacer div is an unfortunate cross-platform hack to add default
       -- padding at the bottom of the questions box 
       , div [ spacerStyle ] []
       ]
    , div 
       [ Html.Attributes.class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
       [ App.map UpdateHtmlEssay (Essay.view model.essay) 
       --, Markdown.toHtml [] model.essay.markdown
       ]
    ]
  -}
  {-
     div 
       []
       [ -- App.map UpdateHeader (Header.view model.header)
       -- h1 [ titleStyle ] [ text model.questions.content.title ]
       --, App.map UpdateQuestions (Questions.view model.questions)
       App.map UpdateQuestions (Questions.tabView model.questions)

       -- This spacer div is an unfortunate cross-platform hack to add default
       -- padding at the bottom of the questions box 
       --, div [ spacerStyle ] []
       ]
  -}
  {-
    grid []
    [ cell [ Material.Grid.size All 6 ]
      [ div [ questionContainerStyle ]
        [ App.map UpdateHeader (Header.view model.header)
        , h1 [ titleStyle ] [ text model.questions.content.title ]
        , App.map UpdateQuestions (Questions.view model.questions)

        -- This spacer div is an unfortunate cross-platform hack to add default
        -- padding at the bottom of the questions box 
         , div [ spacerStyle ] []
        ] 
      ]
    , cell [ Material.Grid.size All 6 ]
      [ div [ essayContainerStyle ]
        [ App.map UpdateHtmlEssay (Essay.view model.essay)
        ]
      ]
    ]
  -}
