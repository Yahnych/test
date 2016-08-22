port module Essay exposing (..) --where

import Html exposing (..)
import Html.Attributes exposing (..)
import String
import String.Extra
import Questions
import Format
import Markdown
import Defaults

import Material
import Material.Button as Button
import Material.Tooltip as Tooltip
import Material.Options exposing (css)


-- MODEL

type alias Model = 
  { markdown : String
  , questions : Questions.Content
  , ieVersionNumber : Int
  , mdl : Material.Model
  } 


init : Questions.Content -> String -> Model
init questions' markdown' = 
  { markdown = markdown'
  , questions = questions'
  , ieVersionNumber = 0
  , mdl = Material.model
  } 


-- UPDATE

type Msg 
  = MDL (Material.Msg Msg)
  | Download
  | Pdf
  | UpdateMarkdown Questions.Content
  | UpdateEssay Questions.Content
  | NoOp


port download : (String, String) -> Cmd msg

port pdf : (String, String) -> Cmd msg


update: Msg -> Model -> (Model, Cmd Msg)
update message model = 
  case message of 
    MDL msg' ->
      Material.update msg' model

    Pdf ->
      let
        fileName = 
          Defaults.projectTitle ++ ".pdf"
      in
      model ! [ pdf (Defaults.projectTitle, model.markdown) ]

    Download ->
      let
        fileName = 
          Defaults.projectTitle ++ ".doc"
      in
      model ! [ download (fileName, model.markdown) ]

    UpdateMarkdown questions ->
      { model | markdown = createMarkdown questions }
      ! []

    UpdateEssay questions' ->
      { model | questions = questions' }
      ! []

    NoOp ->
      model
      ! []


-- HELPER FUNCTIONS

-- Find only the questions that have been answered
answeredQuestions : Questions.Content -> List Questions.Question
answeredQuestions model =
  --List.filter (\question -> not (String.isEmpty question.answer)) model.questions
  List.filter (\question -> not (String.isEmpty question.answer)) (questionsWithoutTitle model)


-- Don't include any questions that have their `Format` set to `Title`. `Title` questions should just be
-- used for the title of the essay or project
questionsWithoutTitle : Questions.Content -> List Questions.Question
questionsWithoutTitle model =
  List.filter (\question -> question.format /= Format.Title ) model.questions


-- Display only the answered questions that belong to this paragraph. This is determined
-- by the `paragraphId` that the user assigned in the `Data` file 
sentencesBelongingToParagraph : Questions.Content -> Int -> List Questions.Question
sentencesBelongingToParagraph model paragraphId =
  List.filter (\question -> question.paragraphId == paragraphId) (answeredQuestions model)


firstQuestion : Questions.Content -> Questions.Question
firstQuestion content =
  List.head content.questions 
  |> Maybe.withDefault 
    { question = ""
    , answer = "This is a test"
    , completed = False
    , editing = False
    , id = 0
    , paragraphId = 0
    , rows = 0
    , maxlength = 0
    , format = Format.Normal
    }


firstAnswer : Questions.Content -> String
firstAnswer content =
  .answer (firstQuestion content)


firstAnswerCompleted : Questions.Content -> Bool
firstAnswerCompleted content = 
  .completed <| firstQuestion content


firstAnswerIsTitle : Questions.Content -> Bool
firstAnswerIsTitle content =
  (.format <| firstQuestion content) == Format.Title

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
createMarkdown : Questions.Content -> String
createMarkdown content =
  let 
    paragraphBreak =
  """ 

  """

    indent = "&ensp;&ensp;&ensp;&ensp;&ensp;"
  
    {-
    firstAnswerCompleted = 
      .completed <| firstQuestion content

    firstAnswerIsTitle =
      (.format <| firstQuestion content) == Format.Title
    -}

    title =
      if (firstAnswerCompleted content) && (firstAnswerIsTitle content)  then
        "# " ++ (Format.formatTitle (firstAnswer content)) ++ paragraphBreak
      else
        "# " ++ content.title ++ paragraphBreak

    essayContent =
      List.map paragraphFormat [0 .. content.numberOfParagraphs ]
      |> String.concat

    paragraphFormat paragraphId =
      let
        completeParagraph =
          List.map sentenceFormat <| sentencesBelongingToParagraph content paragraphId

        firstSentence =
          List.head completeParagraph 
          |> Maybe.withDefault ""
          |> String.append indent

        restOfParagraph =
          List.tail completeParagraph 
          |> Maybe.withDefault [""]
          |> String.concat

        currentQuestion =  
          List.filter (\question -> paragraphId == question.id) (answeredQuestions content)
          |> List.head
          |> Maybe.withDefault (firstQuestion content) 

        question =
          currentQuestion.question

        formattedQuestion =
          "**" ++ (toString <| paragraphId + 1) ++ ". " ++ question ++ "**"

      in
      if List.length completeParagraph /= 0 then 
        paragraphBreak ++ formattedQuestion ++ paragraphBreak ++ firstSentence ++ restOfParagraph ++ "<br><br><br>"
      else 
        ""

  
      -- Create the paragraph by mapping the sentences that belong to the 
      -- current paragraph
      -- List.map sentenceFormat (sentencesBelongingToParagraph content paragraphId)
      -- |> String.concat
      -- |> (++) paragraphBreak

    sentenceFormat question =
      format question

  in
 -- Build the essay markdown string
    title ++ essayContent

    -- Strip any HTML tags that might have been accidentally copied
    -- into the text fields 
    |> String.Extra.stripTags

-- VIEW

(=>) : a -> b -> ( a, b )
(=>) = (,)

type alias Mdl = 
  Material.Model 

view : Model -> Html Msg
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
      if List.length (answeredQuestions model.questions) /= 0 then
        --div [] (List.map (paragraphView model) [0 .. model.questions.numberOfParagraphs])
        ol [] (List.map (shortAnswerView model) [0 .. model.questions.numberOfParagraphs])
        --div [] (List.map (shortAnswerView model) [0 .. (List.length <| answeredQuestions model.questions) - 2])
      else
        div [ instructionStyle ] [ text <| "(" ++ model.questions.instructions ++ ")"  ]
  in
  div [ id "essay" ] 
    [ mdlView model
    , titleView model
    , essayContent
    ]
  {-
  div [ id "essay" ] 
    [ Markdown.toHtml [] model.markdown 
    ]
  -}

mdlView model =
    let
    buttonContainerStyle =
      -- Don't display Word or PDF buttons on IE, because they don't work
      -- This commented version of the if statement allows them to work for versions of
      -- IE greater than 11... but in my testing (August 2016) that didn't work either :(
      -- if model.ieVersionNumber == 0 || model.ieVersionNumber > 11 then
      if model.ieVersionNumber == 0 then
        style 
          [ "width" => "100%"
          , "height" => "50px"
          --, "display" => "block"
          , "clear" => "both"
          --, "background-color" => "aliceBlue"
          ]
      else
        style 
          [ "display" => "none" 
          ]

    in 

    div [ buttonContainerStyle ]
    [ Button.render MDL [0] model.mdl
        [ Button.onClick Download 
        , Button.ripple
        , Tooltip.attach MDL [3]
        , css "float" "right"
        ]
        [ text "word" ]
    , Tooltip.render MDL [3] model.mdl
        [ Tooltip.bottom
        , Tooltip.large
        ]
        [ text "Edit or save in Microsoft Word" ]
    , Button.render MDL [1] model.mdl
        [ Button.onClick Pdf
        , Button.ripple
        , Tooltip.attach MDL [4] 
        , css "float" "right"
        ]
        [ text "pdf" ]
    , Tooltip.render MDL [4] model.mdl
        [ Tooltip.bottom
        , Tooltip.large
        ]
        [ text "Open as PDF to print or save" ]
    ]
  --|> Material.Scheme.top

-- The title view
titleView : Model -> Html Msg
titleView model =
  let
    titleStyle = 
      style
      [ "font-size" => "1.5em"
      , "font-family" => "LibreBaskerville-Regular, serif"
      , "text-align" => "center"
      , "padding-bottom" => "1em"
      ]

    -- Display the first answer as the title if it's been completed and its format style is Title.
    -- Otherwise, display the title of the project
    title =
      if (firstAnswerCompleted model.questions) && (firstAnswerIsTitle model.questions) then
        h1 [ titleStyle ] [ text <| Format.formatTitle (firstAnswer model.questions) ]
      else
        h1 [ titleStyle ] [ text model.questions.title ]
  in
    title


-- The short answer view
shortAnswerView : Model -> Int -> Html Msg
shortAnswerView model paragraphId =
  let
  
    -- Create the paragraph by mapping the sentences that belong to the 
    -- current paragraph
    answer =
      --(List.map sentenceView (sentencesBelongingToParagraph model.questions paragraphId))
      (List.map sentenceView (sentencesBelongingToParagraph model.questions paragraphId))

    currentQuestion =  
      List.filter (\question -> paragraphId == question.id) (answeredQuestions model.questions)
      |> List.head
      |> Maybe.withDefault (firstQuestion model.questions) 

    question =
      currentQuestion.question

    answerStyle =
      style 
      [ "text-indent" => "3em"
      , "line-height" =>  "2em" 
      , "font-size" => "1em"
      , "font-family" => Defaults.essayFont
      , "padding-top" => "1em"
      ]

    questionStyle =
      style
      [ "font-weight" => "bold"
      ]

    --Only display the short answer if the question has been completed and
    -- the `paragraphId` matched the `currentQuestion.id`
    shortAnswerContainerStyle =
      if currentQuestion.completed == True && paragraphId == currentQuestion.id then
        style
        [ "display" => "block"
        , "padding-bottom" => "3.5em"
        ]
      else
        style
        [ "display" => "none"
        ]

  in
  li [ shortAnswerContainerStyle ]
  [ p [ questionStyle ] [ text (toString(paragraphId + 1) ++ ". " ++ question) ]
  , p [ answerStyle ] answer
  ]


-- The paragraph view
paragraphView : Model -> Int -> Html Msg
paragraphView model paragraphId =
  let
  
    -- Create the paragraph by mapping the sentences that belong to the 
    -- current paragraph
    paragraph =
      --(List.map sentenceView (sentencesBelongingToParagraph model.questions paragraphId))
      (List.map sentenceView (sentencesBelongingToParagraph model.questions paragraphId))

    paragraphStyle =
      style 
      [ "text-indent" => "3em"
      , "line-height" =>  "2em" 
      , "font-size" => "1em"
      , "font-family" => Defaults.essayFont
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


-- DIAGNOSTIC

{-
createMarkdown : Questions.Model -> String
createMarkdown model =
  let

    answersBelongingToParagraph paragraphId =
      --List.map (\question -> question.answer) ((questionsBelongingToParagraph paragraphId) model.questions)
      List.map (\question -> question.answer) (questionsBelongingToParagraph paragraphId)
      |> String.concat
    
    questionsBelongingToParagraph paragraphId =
      List.filter (\question -> question.paragraphId == paragraphId) model.questions
      -- |> String.concat

    paragraph paragraphId =
      --List.map (answersBelongingToParagraph paragraphId) model.questions
      answersBelongingToParagraph paragraphId
      --|> String.concat

    paragraphs =
      List.map paragraph [ 0 .. model.numberOfParagraphs ] 
      |> String.concat

  in
    paragraphs
-} 

