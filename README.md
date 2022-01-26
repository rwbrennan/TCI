## WHAT IS IT?

Identifying threshold concepts (Meyer and Land, 2003) in undergraduate curricula has proven to be challenging. Although the term ‘threshold concept’ is new and unfamiliar to many educators, once grasped, it is generally understood from personal learning experience and observations of student learning. Arguably, the main challenge with identifying threshold concepts relates to educators attempts to identify threshold concepts in isolation: i.e., attempts to identify a threshold concept that they have long-since mastered and may consider as second nature.

To address this difficulty, Cousins (2008) proposed broadening the conversation on threshold concepts to include the individuals who are encountering the troublesome knowledge (students) and those who understand the connections between the elements of the curriculum (curriculum designers). This collaborative process of ‘transactional curriculum inquiry’ (TCI) was expanded by Barradell (2013) to include practitioners, which is particularly relevant to professional programs such as undergraduate engineering.

This agent-based model (ABM) is a participatory simulation that will allow instructors, students, curriculum designers, and professional engineers to interact with an undergraduate engineering curriculum to identify threshold concepts and understand their relationships within the curriculum. Effectively, the ABM will serve as a tool to conduct consensus methodology research (Waggoner _et al._, 2016). Although other approaches such as nominal group process, consensus development panel, or Delphi technique could be used, they are tailored for relatively small panels of 8 to 12 experts: our intention is to engage a large and diverse group of stakeholders in this process.

## HOW IT WORKS

The course instructor and students interact with the same model, but from a different perspective. The general approach that will be followed is based on Novak’s steps for building concept maps (Novak, 1984):

1. Identify a focus question that addresses the problem, issues, or knowledge domain to map, and identify 10-20 concepts that are pertinent to the question.
2. Rank order the concepts. The broadest and most inclusive idea at the top of the map. Sub-concepts are placed under broader concepts.
3. Cluster the concepts by grouping sub-concepts under general concepts.
4. Link the concepts by lines. Label the lines with one or a few linking words.

The _instructor_ interacts with the model through the HubNet server, and starts the process by creating the focus question and the initial concepts. Students interact with the model through the HubNet client. Each individual student will see a representation of the concept map as it develops, and will have the ability to interact with elements of the model. For example, by moving concepts to different locations on their interface, they will influence the rank order of the concept (concepts higher on the world view are more general than those below) and the clustering of concepts (based on concepts’ proximity to other concepts). As well, students will have the ability to add elements to the model (e.g., new concepts, links between concepts).

The instructor will step students through the process of developing the concept map and will encourage discussion on the concept map as it develops. The ABM will use the input from the student clients to build a ‘consensus’ concept map. For example, position of the concepts in individual student maps will serve as weightings for the final position
of the concepts in the instructor (server) concept map. As well, concepts that show considerable disagreement with respect to rank order or clustering will be highlighted in the instructor concept map, providing further opportunity for discussion.

## HOW TO USE IT

To setup the activity, the instructor creates an input file, 'Input-Parameters.txt', that contains the concepts that will be used to develop the concept map. Each concept can contain multiple words and should be separated by a carriage return.

Once the Input-Parameters.txt file is created, press SETUP to read the concepts into the ABM. The concepts will be arranged randomly in the world view: a margins slider is provided to limit the area in the world view where concepts are placed (_i.e._, to avoid placing concepts at the edge of the world view).

To start the activity press the GO button.  Ask students to login using the HubNet client or you can test the activity locally by pressing the LOCAL button in the HubNet Control Center. To see the view in the client interface check the Mirror 2D view on clients checkbox.  

Once logged in, the students (clients) can follow the steps proposed by Novak (1984) to build the concept map:

1. _Focus Question & Concepts_: This step is completed by the instructor during the setup.
2. _Rank Order_: Student can click on a concept and drag it to a new location on the world view.
3. _Cluster_: Student can click on a concept and drag it to a new location on the world view.
4. _Link_: _in development_

## REFERENCES

Barradell, S. (2013). The identification of threshold concepts: A review of theoretical complexities and methodological challenges. _Higher Education_, 65(2), 265–276. doi: 10.1007/s10734-012-9542-3

Cousins, G. (2008). _Researching Learning in Higher Education_. Routledge.

Meyer, J., & Land, R. (2003). _Threshold concepts and troublesome knowledge: linkages to ways of thinking and practicing within the disciples_ (Tech. Rep.). Edinburgh: ETL Project Occasional Report 4.

Novak, J. D. (1984). _Learning how to learn_. New York: Cambridge University Press.

Waggoner, J., Carline, J. D., & Durning, S. J. (2016). Is there a consensus on consensus methodology? descriptions and recommendations for future consensus research. _Academic medicine_, 91(5), 663–668.
