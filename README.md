## WHAT IS IT?

Identifying threshold concepts (Meyer and Land, 2003) in undergraduate curricula has proven to be challenging. Although the term ‘threshold concept’ is new and unfamiliar to many educators, once grasped, it is generally understood from personal learning experience and observations of student learning. Arguably, the main challenge with identifying threshold concepts relates to educators attempts to identify threshold concepts in isolation: i.e., attempts to identify a threshold concept that they have long-since mastered and may consider as second nature.

To address this difficulty, Cousins (2008) proposed broadening the conversation on threshold concepts to include the individuals who are encountering the troublesome knowledge (students) and those who understand the connections between the elements of the curriculum (curriculum designers). This collaborative process of ‘transactional curriculum inquiry’ (TCI) was expanded by Barradell (2013) to include practitioners, which is particularly relevant to professional programs such as undergraduate engineering.

This agent-based model (ABM) is a participatory simulation that will allow instructors, students, curriculum designers, and professional engineers to interact with an undergraduate engineering curriculum to identify threshold concepts and understand their relationships within the curriculum. Effectively, the ABM will serve as a tool to conduct consensus methodology research (Waggoner _et al._, 2016). Although other approaches such as nominal group process, consensus development panel, or Delphi technique could be used, they are tailored for relatively small panels of 8 to 12 experts: our intention is to engage a large and diverse group of stakeholders in this process.

## HOW IT WORKS

The course instructor and students interact with the same model, but from a different perspective. The general approach that will be followed is based on Novak’s steps for building concept maps (Novak, 1984):

1. Identify a focus question that addresses the problem, issues, or knowledge domain to
map, and identify 10-20 concepts that are pertinent to the question.
2. Rank order the concepts. The broadest and most inclusive idea at the top of the map.
Sub-concepts are placed under broader concepts.
3. Cluster the concepts by grouping sub-concepts under general concepts.
4. Link the concepts by lines. Label the lines with one or a few linking words.

The _instructor_ interacts with the model through the HubNet server, and starts the process by creating the focus question and the initial concepts. Students interact with the model through the HubNet client. Each individual student will see a representation of the concept map as it develops, and will have the ability to interact with elements of the model. For example, by moving concepts to different locations on their interface, students influence the rank order of the concept (concepts higher on the world view are more general than those below) and the clustering of concepts (based on concepts’ proximity to other concepts). As well, students have the ability to add elements to the model (e.g., new concepts, links between concepts).

The instructor steps students through the process of developing the concept map and  encouragea discussion on the concept map as it develops. The ABM uses input from the student clients to build a ‘consensus’ concept map. For example, position of the concepts in individual student maps serve as weightings for the final position
of the concepts in the instructor (server) concept map. As well, concepts that show considerable disagreement with respect to rank order or clustering are highlighted in the instructor concept map, providing further opportunity for discussion.

## HOW TO USE IT

To setup the activity, the instructor creates an input file, 'Input-Parameters.txt', that contains the concept question and the concepts that will be used to develop the concept map. The structure of 'Input-Parameters.txt' is as follows:

1. Concept Question
2. Concept #1
3. Concept #2
4. ...

When SETUP is pressed, the levels (defined using the _Levels_ slider, shown by grey horizontal bars) and the concepts are placed on the screen.  The concepts are arranged vertically on the world view in the order that they are listed in Input-Parameters.txt. As well, they are listed in the output area (under 'Concept List:'). The number of levels can be changed by clicking "Clear Grid", selecting a new number of levels, then clicking "Draw Grid".

* Instructor (server) View: The concepts are listed vertically in the centre of the world view.
* Student (client) View: Initially, the individual student concepts are hidden; once the student clicks on the world view, concepts are listed vertically to the right of the world view.

To start the activity press the GO button.  Ask students to login using the HubNet client. The instructor may also test the activity locally by pressing the LOCAL button in the HubNet Control Center. To see the view in the client interface check the Mirror 2D view on clients checkbox.  

The instructor concepts ("class concepts") show the class consensus for each concept: i.e.,

* _position_ is determined by the mean xcor and ycor of the corresponding student concepts
* _colour_ is determined by the standard deviation of the ycor (level) of the corresponding student concepts (green represents in agreement ... red represents significant disagreement).

To enable the "consensus tracking" for the class concepts, select the _Track_ slider (there must be at least two clients to enable this feature). Once tracking is enabled, the consensus data can be recorded by selecting _Start Recording_.

The instructor can view the student concepts by clicking on a class concept. For example, if one of the class concepts shows some disagreement (e.g., it is orange or red), the instructor can click on the concept and see all of the student concepts associated with that concept to determine where the disagreement lies. The _Cluster_ slider is used determine how the level of disagreement is represented:

* _Cluster_ Off: The standard deviation of student concept ycor is used (i.e., vertical disagreement). This position should be used for the 'Rank Order' step.
* _Cluster_ On: The standard deviation of student concept xcor is used (i.e., horizontal disagreement). This position should be used for the 'Cluster' step.

As well, the instructor can monitor the degree of student 'level consensus' (rank order agreement) and 'cluster consensus' (horizontal or cluster agreement) using the _Level Consensus_ and the _Cluster Consensus_ plots.

Once logged in, the students (clients) can follow the steps proposed by Novak (1984) to build the concept map:

1. _Focus Question & Concepts_: This step is completed by the instructor during the setup.
2. _Rank Order_: For this step, students should be asked to drag the concepts to the level bars. The horizontal (left to right) order is not important at this point - students should only concentrate on the vertical order: i.e., The broadest and most inclusive concepts at the top of the map; sub-concepts are placed under broader concepts (Novak, 1984). The _Cluster_ switch should be in the 'Off' position for this step so that a vertical (rank order) level of consensus is reflected by the class concept colours.
3. _Cluster_: For this step, students should be asked to cluster the concepts by grouping sub-concepts under general concepts (i.e., consider the horizontal order at this point). The _Cluster_ slider should be moved to the 'On' position this step so that a horizontal level of consensus is reflected by the class concept colours.
4. _Link_: For this step, the instructor can clear the grid (click the _Clear Grid_ button), then ask the students to create the links between the concepts. To create links, student select a _From-Concept_ and a _To-Concept_ from using the choosers on the client interface. The choosers use the concept number and display the concept in the _FromConcept_ and _ToConcept_ monitors respectively. Student should next type a proposition into the _Proposition_ input (Enter/Return must be pressed to read the proposition). Once the 'from' and 'to' concepts are selected and the proposition is entered, the student should click _Create-Link_. To see the link, the student must click anywhere on the world view. To remove a linke, the appropriate _From-Concept_ and _To-Concept_ chooser should be selected, then the _Remove-Link_ button can be pressed.

## NEXT STEPS

### Links
Links can be created by students (clients) using the interface. Possible improvements:

* See if it is possible to have the links appear as soon as the "create link" button is pressed (currently, the world view needs to be clicked to get this to work). This may require an execute-overrides command that sends the hubnet-message-source.
* I would be interesting to see if the links can be created by a "drag-and-click" type approach.

### Server Interface Links
It will be useful to have a means of comparing consensus on the formation of links.

* Could a similar system to the instructor (server) concepts be used? For example, the instructor (server) links would appear as the most predominant link (e.g., if 3/4 students have a link from concept 1 to concept 2, the instructor link will be shown from concept 1 to concept 2). The link could then be coloured based on the degree of agreement. A mouse click could be used to show all links (this could be differentiated from the current function with a selector).
* Alternatively, a simpler approach may be to just show all links, but colour them based on the degree of consensus.

```
;; identify the number of students
length hubnet-client-list
;; count the number of links between concepts
count links with [from-concept = 1 and to-concept = 2]
;; create links between concepts on instructor view
;; color based on the degree of consensus (proportion of total students)
```

### Instructor (Server) Functions
I would be useful to have some controls on the instructor (server) interface for data monitoring and collection.

* buttons could be added to allow the instructor to scroll back and forward in time with the consensus plots.

### Student (Client) Functions
It may be useful to allow students or the instructor to add additional concepts to the world view (see "How to Use it" above).

### Metrics
Some features should be added that provide some insight into the _evolution_ of the concept map over time.

* An instructor view plot that tracks the _degree of consensus_. Currently, two plots have been created that show the standard deviation of the concept positions _vs._ time. 'scroll back' and 'scroll forwar' buttons could be placed under the plot to allow the instructor to look back at consensus.
* The _degree of consensus_ can also be collected for the individual concepts for external analysis.
* The Rapid Miner tool is worth exploring for data analysis.
* An indication of which concepts are the most _troublesome_. This metric will have to be defined: e.g., based on the Std Dev, based on the length of time to reach consensus. This metric is important with respect to the notion of identifying _threshold concepts_.

### Code block example:
Here is an example of how to show a code block in the Info tab:

```
ask students with [ concept-no = 2 ] [set hidden? FALSE]
```

## REFERENCES

Barradell, S. (2013). The identification of threshold concepts: A review of theoretical complexities and methodological challenges. _Higher Education_, 65(2), 265–276. doi: 10.1007/s10734-012-9542-3

Cousins, G. (2008). _Researching Learning in Higher Education_. Routledge.

Meyer, J., & Land, R. (2003). _Threshold concepts and troublesome knowledge: linkages to ways of thinking and practicing within the disciples_ (Tech. Rep.). Edinburgh: ETL Project Occasional Report 4.

Novak, J. D. (1984). _Learning how to learn_. New York: Cambridge University Press.

Waggoner, J., Carline, J. D., & Durning, S. J. (2016). Is there a consensus on consensus
methodology? descriptions and recommendations for future consensus research. _Academic
medicine_, 91(5), 663–668.

## COPYRIGHT AND LICENSE

Copyright 2022 Robert W. Brennan.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
<!-- 2021 -->
