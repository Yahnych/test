module WritingAdvice exposing (init, update, view) --where

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Questions exposing (..)
import String
import Data exposing (..)


-- MODEL

type alias Model = 
  { questions : Questions.Model 
  }


init : (Model, Cmd Msg)
init =
  { questions = Questions.init
  }
  ![]


-- UPDATE

type Msg
  = UpdateQuestions Questions.Msg
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    UpdateQuestions msg ->
      { model | questions = Questions.update msg model.questions } 
      ![]
    
    NoOp ->
      model 
      ![]


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
      , "background-image" => "url(images/paper.png)" 
      , "-webkit-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "-moz-box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      , "box-shadow" => "-3px 0px 20px 0px rgba(50, 50, 50, 0.4)"
      ]
    titleStyle =
      style
      [ "font-size" => "3.5em"
      , "font-family" => "SuisseIntl-Thin"
      , "padding-top" => "0.5em"
      ]


  in 
  div [ class "mdl-grid", mainContainerStyle ]
    [ div 
       [ class "mdl-cell mdl-cell--6-col", questionContainerStyle ]
       [ h1 [ titleStyle ] [ text model.questions.title ]
       , App.map UpdateQuestions (Questions.view model.questions)
       ]
    , div 
       [ class "mdl-cell mdl-cell--6-col", essayContainerStyle ] 
       [ essayView model.questions ]
    ]
     {-
      App.map UpdateQuestions (Questions.view model.questions)
    , essayView model.questions
     -}

-- `essayView` is the view for the right side of the app which is the compiled essay
essayView model = 
  let
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
  div [ ] 
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
        Data.Quotation ->
          style
          [ "font-style" => "italic"
          , "display" => "block"
          , "padding-left" => "5em"
          , "padding-right" => "5em"
          , "padding-bottom" => "1em"
          ]

        Data.AuthorOfQuotation ->
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
