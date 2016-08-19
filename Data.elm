module Data exposing (..) --where

import Format exposing (..)

{-
My only suggested change at this time is to change question #4 to:
“What is the title of the work you have excerpted and who is its author?”
-}

type alias Question = 
  { question : String
  , paragraphId : Int
  , groupId : Int
  , rows : Int
  , maxlength : Int
  , format : Format.FormatStyle
  }


title : String
title = "Resilience in Land Claim Struggles"


instructions : String
instructions = 
  """
Answer the questions on the left to build your essay.
  """

completionMessage : String
completionMessage =
  """
Now that you have a rough outline of your essay, it needs to be revised.  Use the following checklist to review and revise your essay. 
(Revise your essay by updating your answers to the questions above.) 

1. Introduction paragraph
  - Is the topic of your essay clearly stated and explained?
  - Does the introductory paragraph outline and explain the topics that will be discussed in the essay? 
  - Does the thesis statement states all of the arguments that will be made in the essay. 

2. Body paragraphs
  - Does each paragraph have a clear topic sentence that relates to the main idea of the essay?
  - Does each body paragraph include three sets of point/proof/explanation which directly support the topic sentence of the paragraph?
  - Does each body paragraph have a concluding sentence that restates the argument made in the paragraph and concludes the paragraph in a memorable and meaningful way?

3. Conclusion paragraph
  - Is the argument of the essay restated differently than it was in the thesis statement of the introduction?
  - Are the supporting points succinctly summarized?
  - Can the argument and points made in the essay be applied to a broader, meaningful, and relevant context?
  - Does the paragraph leave an impression on the reader through interesting and thought-provoking statements?

4. All paragraphs
  - Is the first line of each paragraph indented?
  - Are all sentences complete?
  - Does each sentence begin with a capital letter?
  - Does each sentence begin with a punctuation mark?
  - Is each sentence free of spelling and grammatical errors?
  - When read aloud, do all sentences make sense?
  - Are Transition words are used to connect ideas (e.g., firstly, secondly, thirdly, thus, therefore etc.)

Once you can say “yes” to all of the above statements and you have finished revising your essay, save the final draft.
  """

type alias QuestionGroup = 
  { title : String
  , description : String
  , navigationHeading : String
  , groupId : Int
  }

questionGroups : List QuestionGroup
questionGroups =
  [
    { title = "Paragraph 1: Introduction"
    , description = ""
    , navigationHeading = "One"
    , groupId = 0
    }
  ,
    { title = "Paragraph 2: How the Inuit showed resilience in the Nunavut land claim"
    , description = ""
    , navigationHeading = "Two"
    , groupId = 1
    }
  ,
    { title = "Paragraph 3: How the Tsilhqot’in showed resilience in their land claim in British Columbia"
    , description = ""
    , navigationHeading = "Three"
    , groupId = 2
    }
  ,
    { title = "Paragraph 4: How the Métis showed resilience in their land claim in Manitoba"
    , description = ""
    , navigationHeading = "Four"
    , groupId = 3
    }
  ,
    { title = "Paragraph 5: Conclusion"
    , description = ""
    , navigationHeading = "Five"
    , groupId = 4
    }
  ]

questions : List Question
questions =
  [ 
    -- Paragraph 1

    { question = 
        """
What is the general topic of your essay?  
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Why are land claims an important or interesting topic?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What specific land claims will you discuss in this essay?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is resilience? Why is resilience important for Indigenous peoples? 
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is your thesis statement?
        """
    , paragraphId = 0
    , groupId = 0
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 2

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?  
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point? 
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 1
    , groupId = 1
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 3

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 2
    , groupId = 2
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 4

    { question = 
        """
What is your argument (what statement are you going to prove in this paragraph)?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the first point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this first point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the second point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this second point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What is the third point you will make to prove your argument in this paragraph?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What proof do you have to support this third point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What explanation can you provide to substantiate the proof that supports this point?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
How can you summarize all the elements of the argument that you just presented?
        """
    , paragraphId = 3
    , groupId = 3
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,

    -- Paragraph 4

    { question = 
        """
What is the overall argument of your essay?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
Can you provide a summary of the main points you presented in the essay?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
What have you learned about the resilience of Indigenous peoples?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ,
    { question = 
        """
In what ways does the topic of this essay relate to the broader issues that Indigenous peoples face in Canada?
        """
    , paragraphId = 4
    , groupId = 4
    , rows = 3
    , maxlength = 0
    , format = Format.Normal
    }
  ]