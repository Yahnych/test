module WritingAdvice exposing (init, update, view) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Data exposing (..)
import String
import Markdown


-- MODEL

type alias Model = 
  { title : String
  , instructions : String
  , questions : List Question
  , field : String
  , previousField : String
  , numberOfParagraphs : Int
  --, answer : String
  --, essay : Essay

  }

init : (Model, Cmd Msg)
init =
  let
    createQuestion id' question =
      { question = question.question
      , answer = ""
      , completed = False
      , editing = False
      , id = id'
      , paragraphId = question.paragraphId
      , rows = question.rows
      , maxlength = question.maxlength
      , format = question.format
      }

    numberOfParagraphs' =
      let
        paragraphIds =
          List.map (\question -> question.paragraphId) Data.questions
      in 
        List.maximum paragraphIds |> Maybe.withDefault 0


  in 
  { title = Data.title
  , instructions = Data.instructions 
  , questions = List.indexedMap createQuestion Data.questions
  , field = ""
  , previousField = ""
  , numberOfParagraphs = numberOfParagraphs'
  } ![]


-- Question
type alias Question =
  { question : String
  , answer : String
  , completed : Bool
  , editing : Bool
  , id : Int
  , paragraphId : Int
  , rows : Int
  , maxlength : Int
  , format : Data.Format
  }

-- Sentence
type alias Sentence =
  { content : String
  , completed : Bool
  , editing : Bool
  --, id : Int
  }

-- Paragraph 
type alias Paragraph =
  { sentences : List Sentence
  --, id : Int
  }

-- Essay
type alias Essay =
  { paragraphs : List Paragraph
  }


-- UPDATE

type Msg
  = UpdateFieldOnInput String
  | UpdateFieldOnFocus Question
  | AddAnswer Question 
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    
    -- Update the model's `field` property each time the user
    -- types into an input field
    UpdateFieldOnInput string ->
      { model | field = string } ![]

    -- When the user selects and input field, Set the model's `field` 
    -- property to whatever the curren value of that input field is 
    UpdateFieldOnFocus question ->
      { model | field = question.answer } ![]

    -- Update the question's `answer` property with the model's current
    -- field value, and update the model's list of questions
    AddAnswer question ->
      let
        questions' currentQuestion =
          if currentQuestion.id == question.id then
            { currentQuestion 
              | answer = model.field
              , completed = True 
            }
          else
            currentQuestion
      in
        { model
            | questions = List.map questions' model.questions 
        } ![]
    
    NoOp ->
      model ![]


-- A function to check whether the user has pressed the Enter key (code 13).
-- If so, the Add message is returned
onEnter : msg -> msg -> Attribute msg
onEnter fail success =
  let
    tagger code =
      if code == 13 then success
      else fail
  in
    on "keyup" (Json.map tagger keyCode)


-- VIEW

css : String -> Html Msg
css path =
  node "link" [ rel "stylesheet", href path ] []


-- VIEW

(=>) = (,)

view : Model -> Html Msg
view model =
  let
    mainContainer =
      [ "margin" => "0px"
      , "padding" => "0px"
      , "width" => "100vw"
      , "height" => "100vh"
      ]
  in 
  div [ class "mdl-grid", style mainContainer]
    [ questionsView model
    , essayView model
    ]

-- `questionsView` is the view for the left side of the app, which 
-- includes all the questions
questionsView model =
  let
    questionContainer =
      [ "padding" => "2vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "aliceBlue" 
      ]

    textfieldStyle = 
      style
      [ "width" => "200%"
      , "font-family" => "LibreBaskerville-Regular, serif"
      , "font-size" => "1em"
      , "line-height" => "1.5em"
      , "padding" => "1em"
      ]

    questionStyle =
      style
      [ "font-size" => "1.2em"
      ]

    getMaxLength maxlength =
      if maxlength /= 0 then
        maxlength
      else
        500

    setAutoFocus question =
      if question.id == 0 then
        True
      else
        False

    questions question =
      li []
      [ Markdown.toHtml [ questionStyle ] question.question 
      , div [ class "mdl-textfield mdl-js-textfield" ] 
        [ textarea 
          [ on "input" (Json.map UpdateFieldOnInput targetValue)
          , onEnter NoOp (AddAnswer question)
          , onBlur (AddAnswer question)
          , onFocus (UpdateFieldOnFocus question)
          , class "mdl-textfield__input"
          , rows question.rows
          , textfieldStyle
          , maxlength <| getMaxLength question.maxlength
          , autofocus <| setAutoFocus question
          ] 
          []
        ]
      ]

    answers item =
      div []
      [ p [ ] [ text (toString(item.id + 1) ++ ". " ++ item.answer) ]
      ]

    titleStyle =
      style
      [ "font-size" => "3.5em"
      , "font-family" => "SuisseIntl-Thin"
      , "padding-top" => "0.5em"
      ]

  in
  div [ class "mdl-cell mdl-cell--6-col", style questionContainer ]
    [ img [ src "images/logoTVO_WritersDesk.png" ] [ ]
    , h1 [ titleStyle ] [ text model.title ]
    , ol [ ] (List.map questions model.questions)

    -- Diagnostic
    {-
    , p [] [ text ("Paragraphs: " ++ toString(model.numberOfParagraphs))]
    , p [] [ text model.field ]
    , div [] (List.map answers model.questions)
    -}
    ]


-- `essayView` is the view for the right side of the app which is the compiled essay
essayView model = 
  let
    essay =
      [ "padding" => "5vh 5vw 5vh 5vw"
      , "overflow" => "hidden"
      , "overflow-y" => "auto"
      , "overflow-x" => "auto"
      --, "background-color" => "seaGreen"
      , "background-image" => "url(images/paper.png)" 
      , "-webkit-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "-moz-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      ]

    instructionStyle =
      style
      [ "text-align" => "center"
      , "font-size" => "1.2em"
      , "opacity" => "0.6"
      ]

    -- Find only the questions that have been answered
    answeredQuestions =
      List.filter (\question -> not (String.isEmpty question.answer)) model.questions

    -- If any of the questions have been answered, display the paragraphs.
    -- Otherwise, display the instruction text
    essayContent =
      if List.length answeredQuestions /= 0 then
        div [] (List.map (paragraphView model) [0 .. model.numberOfParagraphs])
      else
        div [ instructionStyle ] [ text <| "(" ++ model.instructions ++ ")"  ]
  in
  div [ class "mdl-cell mdl-cell--6-col", style essay ] 
    [ titleView model
    , essayContent
    ]


-- The title view
titleView model =
  let
    titleStyle = 
      style
      [ "font-size" => "1.5em"
      , "font-family" => "LibreBaskerville-Regular, serif"
      , "text-align" => "center"
      , "padding-bottom" => "1em"
      ]
  in
    h1 [ titleStyle ] [ text model.title ]

-- The paragraph view
paragraphView model paragraphId =
  let
  
    -- Find only the questions that have been answered
    answeredQuestions =
      List.filter (\question -> not (String.isEmpty question.answer)) model.questions

    -- Display only the answered questions that belong to this paragraph. This is determined
    -- by the `paragraphId` that the user assigned in the `Data` file 
    sentencesBelongingToParagraph paragraphId =
      List.filter (\question -> question.paragraphId == paragraphId ) answeredQuestions

    -- Create the paragraph by mapping the sentences that belong to the 
    -- current paragraph
    paragraph =
      (List.map sentenceView (sentencesBelongingToParagraph paragraphId))

    paragraphStyle =
      style 
      [ "text-indent" => "3em"
      , "line-height" =>  "2em" 
      , "font-size" => "1em"
      , "font-family" => "LibreBaskerville-Regular, serif"
      ]

  in
  p [ paragraphStyle ]  paragraph
  

-- The sentence view
sentenceView question = 
  let

    sentenceStyle =
      case question.format of 
        Quotation ->
          style
          [ "font-style" => "italic"
          , "display" => "block"
          , "padding-left" => "5em"
          , "padding-right" => "5em"
          , "padding-bottom" => "1em"
          ]

        AuthorOfQuotation ->
          style
          [ "display" => "block"
          , "text-align" => "right"
          , "padding-right" => "5em"
          , "padding-bottom" => "1em"
          , "font-style" => "italic"
          ]

        _ ->
          style
          [ "font-style" => "normal"
          ]

    addFinalPeriod answer = 
      if String.endsWith "." answer then
        answer
      else
        answer ++ "."

    addSpaceBetweenSentences answer =
      answer ++ " "

    trimExtraWhitespace answer =
      -- String.trim answer
      (String.join " " << String.words) answer

    removeSpaceBeforePeriod answer =
      (String.join "." << List.map String.trimRight << String.split ".") answer

    capitalizeFirstCharacter answer =
      let
        firstCharacter = String.left 1 answer
        remainingString = String.dropLeft 1 answer
        capitalLetter = String.toUpper firstCharacter
        capitalizedSentence = String.concat [ capitalLetter, remainingString ]
      in
        capitalizedSentence

    addPossibleQuotes answer = 
      case question.format of
        Quotation -> 
          "“" ++ answer ++ "”"
        _ ->
          answer

    formatAuthorOfQuotation answer =
      case question.format of
        AuthorOfQuotation -> 
          "— " ++ answer
        _ ->
          answer



    format answer =
      trimExtraWhitespace answer
      |> addFinalPeriod
      |> removeSpaceBeforePeriod
      |> capitalizeFirstCharacter
      |> addPossibleQuotes
      |> formatAuthorOfQuotation
      |> addSpaceBetweenSentences


  in
  span [ sentenceStyle ] [ text <| format question.answer ]
