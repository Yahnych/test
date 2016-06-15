module Essay exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Questions
import Format
import Markdown


-- MODEL

type alias Model = 
  { markdown : String
  } 


init : Model
init = 
  { markdown = ""
  } 


-- UPDATE

type Msg 
  = UpdateMarkdown Questions.Model
  | NoOp


update: Msg -> Model -> Model
update message model = 
  case message of 
    UpdateMarkdown questions ->
      { model | markdown = createMarkdown questions }

    NoOp ->
      model


-- HELPER FUNCTIONS

-- Find only the questions that have been answered
answeredQuestions : Questions.Model -> List Questions.Question
answeredQuestions model =
  List.filter (\question -> not (String.isEmpty question.answer)) model.questions


-- Display only the answered questions that belong to this paragraph. This is determined
-- by the `paragraphId` that the user assigned in the `Data` file 
sentencesBelongingToParagraph : Questions.Model -> Int -> List Questions.Question
sentencesBelongingToParagraph model paragraphId =
  List.filter (\question -> question.paragraphId == paragraphId) (answeredQuestions model)


-- FORMATTING
-- The specific way in which this essay should be formatted

format : Questions.Question -> String
format question =
  Format.trimExtraWhitespace question.answer
  |> Format.addFinalPeriod
  |> Format.removeSpaceBeforePeriod
  |> Format.capitalizeFirstCharacter
  |> (Format.addPossibleQuotes question.format)
  |> (Format.formatAuthorOfQuotation question.format)
  |> Format.addSpaceBetweenSentences


-- MARKDOWN

-- Generates the markdown file based on the currently answered questions

createMarkdown : Questions.Model -> String
createMarkdown model =
  let 
    paragraphBreak =
  """ 

  """

    indent = "&ensp;&ensp;&ensp;&ensp;&ensp;"

    title =
      "#" ++ model.title ++ paragraphBreak

    essayContent =
      List.map (paragraphFormat model) [0 .. model.numberOfParagraphs]
      |> String.concat

    paragraphFormat model paragraphId =
      let
        completeParagraph =
          List.map sentenceFormat (sentencesBelongingToParagraph model paragraphId)

        firstSentence =
          List.head completeParagraph 
          |> Maybe.withDefault ""
          |> String.append indent


        restOfParagraph =
          List.tail completeParagraph 
          |> Maybe.withDefault [""]
          |> String.concat

      in
      if List.length completeParagraph /= 0 then 
        firstSentence ++ restOfParagraph ++ paragraphBreak
      else 
        ""

  
      -- Create the paragraph by mapping the sentences that belong to the 
      -- current paragraph
      -- List.map sentenceFormat (sentencesBelongingToParagraph model paragraphId)
      -- |> String.concat
      -- |> (++) paragraphBreak

    sentenceFormat question =
      format question

  in
    title ++ essayContent


-- VIEW

(=>) : a -> b -> ( a, b )
(=>) = (,)


view : Questions.Model -> Html Msg
view model = 
  let
    instructionStyle =
      style
      [ "text-align" => "center"
      , "font-size" => "1.2em"
      , "opacity" => "0.6"
      ]

    -- If any of the questions have been answered, display the paragraphs.
    -- Otherwise, display the instruction text
    essayContent =
      if List.length (answeredQuestions model) /= 0 then
        div [] (List.map (paragraphView model) [0 .. model.numberOfParagraphs])
      else
        div [ instructionStyle ] [ text <| "(" ++ model.instructions ++ ")"  ]
  in
  div [ ] 
    [ titleView model
    , essayContent
    ]


-- The title view
titleView : Questions.Model -> Html a
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
paragraphView : Questions.Model -> Int -> Html Msg
paragraphView model paragraphId =
  let
  
    -- Create the paragraph by mapping the sentences that belong to the 
    -- current paragraph
    paragraph =
      (List.map sentenceView (sentencesBelongingToParagraph model paragraphId))

    paragraphStyle =
      style 
      [ "text-indent" => "3em"
      , "line-height" =>  "2em" 
      , "font-size" => "1em"
      , "font-family" => "LibreBaskerville-Regular, serif"
      ]

  in
  p [ paragraphStyle ] paragraph
  

-- The sentence view
sentenceView : Questions.Question -> Html Msg
sentenceView question = 
  let

    sentenceStyle =
      case question.format of 
        Format.Quotation ->
          style
          [ "font-style" => "italic"
          , "display" => "block"
          , "padding-left" => "5em"
          , "padding-right" => "5em"
          , "padding-bottom" => "1em"
          ]

        Format.AuthorOfQuotation ->
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
          , "display" => "inline"
          ]
  in
  -- span [ sentenceStyle ] [ Markdown.toHtml [] (format question) ]
  Markdown.toHtml [ sentenceStyle, class "formattedSentence" ] (format question)
  -- span [ sentenceStyle ] [ text <| format question ]
