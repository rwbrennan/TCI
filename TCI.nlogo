;; create a breed of turtles that the students control through the clients
;; there will be one student turtle for each client.
breed [ students student ]
breed [ classes class ]
directed-link-breed [student-links student-link]
directed-link-breed [class-links class-link]

globals
[
;  selected        ;; identifies the student concept to be moved (REMOVE once linked code is corrected)
  s-index          ;; student index in s-selected list
  s-selected       ;; student concept selected list
;  linked
  c-selected       ;; identifies student concepts in instructor view
  concepts         ;; number of concepts
  concept          ;; concept list
  c-record         ;; if TRUE, save consensus data
  plot-increment   ;; variable used to scroll the interaction diagram
]

students-own
[
  user-id     ;; Students choose a user name when they log in. Whenever the server receives a
              ;; message from the student associated with this turtle hubnet-message-source
              ;; it will contain the user-id.

              ;; There should be a turtle variable for every widget in the client interface that
              ;; stores a value (sliders, choosers, and switches). The server will receive a message
              ;; from the client whenever the value changes. However, it will not be able to
              ;; retrieve the value at will unless it is stored it in a variable on the server.
  index       ;; student index
  concept-no  ;; The concept number associated with the turtle.
  from-no     ;; Originating concept number of a link: i.e., the "from" concept number
  to-no       ;; Terminating concept number of a link: i.e., the "to" concept number
  s-prop      ;; Proposition for the link
]

classes-own
[
  concept-no  ;; The concept number associated with the turtle.
  user-id
]

student-links-own
[
  student-id
  from-concept
  to-concept
]

class-links-own
[
  from-concept
  to-concept
]

;; the STARTUP procedure runs only once at the beginning of the model
;; at this point you must initialize the system.
to startup
  hubnet-reset
end

to setup
  clear-patches
  clear-drawing
  clear-output
  clear-turtles
  clear-all-plots
  ;; during setup you do not want to kill all the turtles
  ;; (if you do you'll lose any information you have about the clients)
  ;; so reset any variables you want to default values, and let the clients
  ;; know about the change if the value appears anywhere in their interface.

  setup-input-parameters
  setup-concept-list
  setup-levels
  create-class-concepts
  setup-consensus-plots
  set Track FALSE
  set Cluster FALSE
  set Show-Links FALSE
  set c-record FALSE
  set plot-increment 0
  ask students
  [
    hubnet-send user-id shape "box 2"
  ]
  ;; this variable is used to select the concept to drag-and-drop
  set s-index -1
  set s-selected []
  set c-selected nobody

  ;; calling reset-ticks enables the 'go' button
  reset-ticks
  reset-timer
end

to go
  ;; process incoming messages and respond to them (if needed)
  ;; listening for messages outside of the every block means that messages
  ;; get processed and responded to as fast as possible
  listen-clients
  every 0.1
  [
    ;; tick (and display) causes world updates messages to be sent to clients
    ;; these types of messages should only be sent inside an every block.
    ;; otherwise, the messages will be created as fast as possible
    ;; and consume your bandwidth.
    if Track and length hubnet-clients-list > 1 [ position-class-concepts ]
    ifelse mouse-down?
    [
      view-student-concepts
    ]
    [
      set c-selected nobody
      ask students [ set hidden? TRUE ]
    ]
    if Show-Links and length hubnet-clients-list > 0
    [
      view-student-links
    ]

    ;; Set the overrides for the client interfaces. For this model, the concepts for all students
    ;; are shown at the start (whenever a new student logs in). Whenever a client exectutes a
    ;; a command (e.g., clicks in the window), the other students are hiddent from the client's view.
    execute-overrides
    if Track or Cluster
    [
      plot-level-consensus
      plot-cluster-consensus
    ]
    if Show-Links [plot-link-consensus]
    tick
  ]

end

;;
;; HubNet Procedures
;;

to listen-clients
  ;; as long as there are more messages from the clients
  ;; keep processing them.
  while [ hubnet-message-waiting? ]
  [
    ;; get the first message in the queue
    hubnet-fetch-message
    ifelse hubnet-enter-message? ;; when clients enter we get a special message
    [ create-new-student ]
    [
      ifelse hubnet-exit-message? ;; when clients exit we get a special message
      [ remove-student ]
      [ ask students with [user-id = hubnet-message-source]
        [ execute-command hubnet-message-tag ] ;; otherwise the message means that the user has
      ]                                        ;; done something in the interface hubnet-message-tag
                                               ;; is the name of the widget that was changed
    ]
  ]
end

to create-new-student
  ;; When a new user logs in, create a student turtle for each concept.
  ;; These turtles will store any state on the client (i.e., values of sliders, etc.)
  let i 0
  set s-index s-index + 1
  set s-selected lput nobody s-selected
  ;; Each student will be represented by a different base color in the server interface.
  let student-color one-of remove gray base-colors
  let gap (max-pycor - min-pycor) / (length concept + 1)
  while [ i < concepts]
  [
    create-students 1
    [
      ;; display concepts vertically on right of world view
      setxy (max-pxcor - gap) (max-pycor - (i + 1) * gap)
      set color student-color
      set shape "box"
      set concept-no i + 1
      set index s-index
      ;; Store the message-source in user-id now so the server knows which client to address.
      set user-id hubnet-message-source
      set label (word item i concept " (" user-id ")" )
      set label-color white
      set hidden? TRUE
    ]
    set i i + 1
  ]
end

to remove-student
  ;; When a user logs out, this procedures makes sure to clean up the turtle that
  ;; was associated with that user (so you don't try to send messages to it after it is gone).
  ;; If any other turtles of variables reference this turtle make sure to clean up those
  ;; references too.
  ask students with [user-id = hubnet-message-source]
  [ die ]
end

to execute-command [command]
  ;; Other messages correspond to users manipulating the
  ;; client interface, handle these individually.
  ;; Create one if statement for each widget that can affect the outcome of the model,
  ;; buttons, sliders, switches choosers and the view.
  ;; If the client clicks on the view the server will receive a message with the tag "View"
  ;; and the hubnet-message will be a two item list of the coordinates.
  ;;
  ;; Allows a client to click on a concept and drag it to another location in the view.
  ;; The "View" command is invoked when the client clicks; the "Mouse Up" command is invoked when
  ;; the client releases. The HubNet message contains the xcor and pcor of the mouse.
  (ifelse
    command = "View" [
      ask students with [user-id = hubnet-message-source] [set s-selected replace-item index s-selected nobody]
      execute-select-and-drag item 0 hubnet-message item 1 hubnet-message stop
    ]
    command = "Mouse Up" [
      execute-move-to item 0 hubnet-message item 1 hubnet-message stop
    ]
    command = "From-Concept" [
      set from-no hubnet-message
      if from-no > 0 and from-no <= length concept
      [
        let from-selected item (from-no - 1) concept
        hubnet-send user-id "FromConcept" from-selected
      ]
      stop
    ]
    command = "To-Concept" [
      set to-no hubnet-message
      if to-no > 0 and to-no <= length concept
      [
        let to-selected item (to-no - 1) concept
        hubnet-send user-id "ToConcept" to-selected
      ]
      stop
    ]
    command = "Proposition" [
      set s-prop hubnet-message
      stop
    ]
    command = "Create-Link" [
      execute-create-link
      stop
    ]
    command = "Remove-Link" [
      execute-remove-link stop
    ]
  )
end

to execute-select-and-drag [snap-xcor snap-ycor]
  ;; This procedure allows the client to select a concept. It first identifies the closest concept
  ;; to the mouse click location, then determines if it is close enough to be selected.
  ;; The selection is limited to concepts that belong to the client: i.e.,
  ;;   students with [user-id = hubnet-message-source]
  ;;   student concepts are identified by the s-selected list:
  ;;         [ (student concept for first client) (student concept for the second client) ...]
  if item index s-selected = nobody  [
    set s-selected replace-item index s-selected min-one-of students with [user-id = hubnet-message-source] [distancexy snap-xcor snap-ycor]
    if [distancexy snap-xcor snap-ycor] of item index s-selected > 1
      [set s-selected replace-item index s-selected nobody]
  ]
end


to execute-move-to [snap-xcor snap-ycor]
  ;; This procedure executes the move once the client drags the mouse to the "Mouse Up"
  ;; (i.e., release mouse) position.
  if item index s-selected != nobody [ ask item index s-selected [ setxy snap-xcor snap-ycor ] ]
end

;to execute-select-and-link [snap-xcor snap-ycor]
;  if linked = nobody [
;    set linked min-one-of students with [user-id = hubnet-message-source] [distancexy snap-xcor snap-ycor]
;    ask selected [create-link-with linked]
;  ]
;end

to execute-overrides
  ;; This procedure sets the overrides for the client views.
  ;;
  let i 0
  let client ""
  while [i < length hubnet-clients-list]
  [
    set client item i hubnet-clients-list
    ask students with [user-id = client]
    [
      ;; First, the client's concepts and links are made visible.
      hubnet-send-override client self "color" [green]
      hubnet-send-override client self "label-color" [white]
      hubnet-send-override client self "hidden?" [FALSE]
      ask student-links with [student-id = client] [
      ;ask links with [student-id = client] [
        hubnet-send-override client self "color" [yellow]
        hubnet-send-override client self "label-color" [yellow]
        hubnet-send-override client self "hidden?" [FALSE]
      ]
    ]
    ;;
    ;; Next, all other clients' concepts and links are hidden from the client's view.
    ask turtles with [user-id != client] [
      hubnet-send-override client self "hidden?" [TRUE]
    ]
    ask student-links with [student-id != client] [
    ;ask links with [student-id != client] [
      hubnet-send-override client self "hidden?" [TRUE]
    ]
    ask class-links [
      hubnet-send-override client self "hidden?" [TRUE]
    ]
    set i i + 1
  ]
end

;;
;; Regular Procedures
;;

to create-class-concepts
  ;; This procedure creates the class concepts. These turtles are used to show the "consensus" position of the concepts.
  ;; - position is determined by the mean xcor and ycor of the corresponding student concepts
  ;; - color is determined by the standard deviation of the ycor (level) of the corresponding student concepts
  let i 0
  let gap (max-pycor - min-pycor) / (length concept + 1)
  while [ i < concepts]
  [
    create-classes 1
    [
      ;; display concepts vertically on right of world view
      setxy 0 (max-pycor - (i + 1) * gap)
      set color grey
      set shape "triangle 2"
      set concept-no i + 1
      ;; Store the message-source in user-id now so the server knows which client to address.
      set label item i concept
      set label-color white
      set user-id ""
    ]
    set i i + 1
  ]
end

to setup-input-parameters
  ;; This procedure reads the set of concepts from the input file.
  ;; Each concept is a line (i.e., single or multiple words) separated by carriage returns.
  file-open "Input-Parameters.txt"
  ;; First, read the focus question and put it at the top of the world view
  ask patch (max-pxcor - 1) 14 [set plabel (word "Concept Q: " file-read-line) set plabel-color yellow]
  set concept []
  while [ not file-at-end? ]
  [
    set concept lput file-read-line concept
  ]
  set concepts length concept
  file-close
end

to setup-levels
  ;; This procedure is used to setup the levels for the concepts. The instructor (server) identifies the number of
  ;; concept levels on the interface. Students then drag the concepts to the appropriate level.
  let spacing round ((max-pycor - min-pycor) / (Levels + 1))
  let next-level spacing
  let i 0
  while [ i < Levels ]
  [
    ask patches with [ pycor = max-pycor - next-level ] [set pcolor grey]
    ask patch (min-pxcor + 1) (max-pycor - next-level) [set plabel-color black set plabel (word "L: " (i + 1))]
    set next-level next-level + spacing
    set i i + 1
  ]
end

to position-class-concepts
  ;; This procedure is used to position the class concepts. The class concepts are placed at the mean xcor and ycor
  ;; of all of the student concepts. The colour of the class concepts is based on the standard deviation and is
  ;; intended to represent the level of agreement with respect to the level of the concept.
  let i 1
  while [ i <= concepts ]
  [
    ask classes with [ concept-no = i ]
    [
      set xcor item 0 c-position i
      set ycor item 1 c-position i
      let consensus item 2 c-position i
      (ifelse
        consensus < 2 [set color green]
        consensus >= 2 and consensus < 5 [set color yellow]
        consensus >= 5 and consensus < 10 [set color orange]
        consensus >= 10 [set color red]
      )
    ]
    set i i + 1
  ]
end

to execute-create-link
  ;; This procedure is used to create a link between two concepts
  ;; The student (client) specifies the "from concept", the "to concept", and the proposition on the student interface
  let link-to-id 0
  ask students with [user-id = hubnet-message-source and concept-no = from-no]
  [
    let from-number from-no
    let to-number to-no
    let link-proposition s-prop
    set link-to-id [who] of students with [user-id = hubnet-message-source and concept-no = to-no]
    create-student-links-to students with [user-id = hubnet-message-source and concept-no = to-no]
    ask my-student-links with [end2 = student item 0 link-to-id]
    [
      set student-id hubnet-message-source
      set from-concept from-number
      set to-concept to-number
      set label link-proposition
      set hidden? TRUE
    ]
  ]
end

to execute-remove-link
  ask students with [user-id = hubnet-message-source]
  [
    let from-number from-no
    let to-number to-no
    ask student-links with [student-id = hubnet-message-source and from-concept = from-number and to-concept = to-number] [die]
  ]
end

to view-student-concepts
  ;; This procedure is used by the instructor (server) to view students associated with a given concept.
  ;; While the instructor clicks on a class concept, the associated student concepts come into view.
  let selected-concept 0
  set c-selected min-one-of classes [distancexy mouse-xcor mouse-ycor]
  ask c-selected [ set selected-concept concept-no ]
  ask students with [ concept-no = selected-concept ] [ set hidden? FALSE ]
end

to view-student-links
  ;; This procedure is used to view the student links.
  ;;
  let i 1
  let j 1
  let student-l 0
  let class-l 0
  let consensus 0
  let class-id 0
  while [i <= concepts]
  [
    ;; Count the number of student links from concept i to concept j
    while [j <= concepts]
    [
      ;; First, count the number of links from concept i to concept j between student (client) concepts
      ;; (student-links) and the number of links between class (server) concepts (class-links).
      set student-l count student-links with [from-concept = i and to-concept = j]
      set class-l count class-links with [from-concept = i and to-concept = j]
      ;; Next, calculate the "consensus" for the student-links. This the proportion of students who
      ;; have the same link from concept i to concept j
      set consensus (student-l / (length hubnet-clients-list) * 100)
      ;show (word "From " i " to " j ": " student-links " student, " class-links " class")
      (ifelse
        student-l > 0 and class-l = 0 [
          ask classes with [concept-no = i]
          [
            set class-id [who] of classes with [concept-no = j]
            ;show class-id
            create-class-links-to classes with [concept-no = j]
            ;show (word "Created Link from " i " to " j " Consensus = " consensus)
            ask my-class-links with [end2 = class item 0 class-id]
            [
              set from-concept i
              set to-concept j
              (ifelse
                consensus = 100 [set color green]
                consensus < 100 and consensus >= 67 [set color yellow]
                consensus < 67 and consensus >= 33 [set color orange]
                consensus < 33 [set color red]
              )
            ]
          ]
        ]
        student-l > 0 and class-l > 0 [
          ask classes with [concept-no = i]
          [
            ;show (word "Maintained Link from " i " to " j " Consensus = " consensus)
            set class-id [who] of classes with [concept-no = j]
            ask my-class-links with [end2 = class item 0 class-id]
            [
              (ifelse
                consensus = 100 [set color green]
                consensus < 100 and consensus >= 67 [set color yellow]
                consensus < 67 and consensus >= 33 [set color orange]
                consensus < 33 [set color red]
              )
            ]
          ]
        ]
        student-l = 0 and class-l > 0 [
          ask class-links with [from-concept = i and to-concept = j] [die]
          ;show (word "Removed Link from " i " to " j)
        ]
      )
      set j j + 1
    ]
    set j 1
    set i i + 1
  ]
end

to setup-consensus-plots
  ;; This procedure is used to setup the consensus plots based on the number of concepts.
  ;; A temporary pen is created for each concept (C1, C2, C3, etc.). These temporary pens
  ;; are referenced by the plot commands.
  ;; Notes: (1) 14 pen colours are available with this approach (expand for more concepts?)
  ;;        (2) Rather than "C1" etc., the concept name could be used
  set-current-plot "Level Consensus"
  let i 1
  while [i <= concepts]
  [
    create-temporary-plot-pen (word "C" i)
    set-plot-pen-color ((i - 1) * 10 + 5)
    set i i + 1
  ]
  set-current-plot "Cluster Consensus"
  set i 1
  while [i <= concepts]
  [
    create-temporary-plot-pen (word "C" i)
    set-plot-pen-color ((i - 1) * 10 + 5)
    set i i + 1
  ]
  set-current-plot "Link Consensus"
  set i 1
  while [i <= concepts]
  [
    create-temporary-plot-pen (word "C" i)
    set-plot-pen-color ((i - 1) * 10 + 5)
    set i i + 1
  ]

end

to plot-level-consensus
  ;; This procedure is used to plot concept level consensus vs time
  ;; A range of 0 - 60 seconds is used. Once the time reaches 60 seconds, the plot scrolls to the
  ;; right with a 60 second interval.
  set-current-plot "Level Consensus"
  ifelse timer <= 60
  [set-plot-x-range 0 60]
  ;[set-plot-x-range timer - 60 timer]
  [set-plot-x-range (timer - 60 - plot-increment) (timer - plot-increment)]
  let i 1
  let consensus 0
  if Track and length hubnet-clients-list > 1
  [
    while [i <= concepts]
    [
      set-current-plot-pen (word "C" i)
      set consensus sqrt (variance [ ycor ] of students with [ concept-no = i ])
      plotxy timer consensus
      if c-record = TRUE [record-consensus-data (word "LC" i) timer consensus]
      set i i + 1
    ]
  ]
end

to plot-cluster-consensus
  ;; This procedure is used to plot cluster concept consensus vs time
  ;; A range of 0 - 60 seconds is used. Once the time reaches 60 seconds, the plot scrolls to the
  ;; right with a 60 second interval.
  set-current-plot "Cluster Consensus"
  ifelse timer <= 60
  [set-plot-x-range 0 60]
  ;[set-plot-x-range timer - 60 timer]
  [set-plot-x-range (timer - 60 - plot-increment) (timer - plot-increment)]
  let i 1
  let consensus 0
  if Track and length hubnet-clients-list > 1
  [
    while [i <= concepts]
    [
      set-current-plot-pen (word "C" i)
      set-plot-pen-color (i * 10 + 5)
      set consensus sqrt (variance [ xcor ] of students with [ concept-no = i ])
      plotxy timer consensus
      if c-record = TRUE [record-consensus-data (word "CC" i) timer consensus]
      set i i + 1
    ]
  ]
end

to plot-link-consensus
  ;; This procedure is used to plot cluster concept consensus vs time
  ;; A range of 0 - 60 seconds is used. Once the time reaches 60 seconds, the plot scrolls to the
  ;; right with a 60 second interval.
  set-current-plot "Link Consensus"
  ifelse timer <= 60
  [set-plot-x-range 0 60]
  ;[set-plot-x-range timer - 60 timer]
  [set-plot-x-range (timer - 60 - plot-increment) (timer - plot-increment)]
  let i 1
  let consensus 0
  if Show-Links and length hubnet-clients-list > 1
  [
    while [i <= concepts]
    [
      set-current-plot-pen (word "C" i)
      set-plot-pen-color (i * 10 + 5)
      set consensus link-consensus i
      plotxy timer consensus
      if c-record = TRUE [record-consensus-data (word "IC" i) timer consensus]
      set i i + 1
    ]
  ]
end

to scroll-plot [increment]
  ;; This procedure is used to set the plot-increment used in the plots
  ;; to allow the plot to be scrolled back and forward in time (ticks)
  ;; Reset if increment = 0
  if increment = 0
  [set plot-increment 0]
  ;; Check that we are not going too far back or too far forward before incrementing
  let temp-increment plot-increment + increment * 10
  if (timer - temp-increment) <= timer and (timer - 60 - plot-increment) >= 0
  [set plot-increment temp-increment]
end

to-report link-consensus [concept-number]
  ;; This procedure is used to calculate the link consensus for a given concept.
  ;; This is based on the number of links coming into or out of a given concept. If there is 100% consensus, the number of links
  ;; associated with each concept is the number of links associated with each student concept times the number of students (clients).
  ;;
  let no-student-links count student-links with [from-concept = concept-number or to-concept = concept-number]
  let no-class-links count class-links with [from-concept = concept-number or to-concept = concept-number]
  ifelse no-class-links > 0
  [report 100 * (no-student-links / (no-class-links * length hubnet-clients-list))]
  [report 0]
end

to setup-consensus-data [record-mode]
  ;; This procedure is used to open/close the consensus data file
  ifelse record-mode = TRUE
  [
    file-open "Output-Consensus.txt"
    set c-record TRUE
  ]
  [
    file-close
    set c-record FALSE
  ]
end

to setup-concept-list
  ;; This procedure is used to print the list of concepts to the output area on
  ;; the instructor (server) interface
  let i 0
  while [i < concepts]
  [
    output-print (word "C" (i + 1) ": " item i concept)
    set i i + 1
  ]
end

to record-consensus-data [what time variable]
  ;; This procedure is used to record consensus data
  file-print what
  file-print time
  file-print variable
end

to-report c-position [ concept-number ]
  ;; This procedure is used to calculate the mean position of all students' with concept = concept-number
  ;; A list is reported as follows:
  ;;     item 0 = mean xcor
  ;;     item 1 = mean ycor
  ;;     item 2 = std dev (used to colour the server concept to indicate level of consensus)
  ;;              if Cluster is selected, the std dev of the xcor is used (left-right variance)
  ;;              else, the std dev of ycor is used (up-down or level variance)
  let concept-position []
  set concept-position lput mean [ xcor ] of students with [ concept-no = concept-number ] concept-position
  set concept-position lput mean [ ycor ] of students with [ concept-no = concept-number ] concept-position
  ifelse Cluster = TRUE
  [set concept-position lput sqrt variance [ xcor ] of students with [ concept-no = concept-number ] concept-position]
  [set concept-position lput sqrt variance [ ycor ] of students with [ concept-no = concept-number ] concept-position]
  report concept-position
end

to-report c-consensus [ consensus-type ]
  ;; This procedure is used to report on the concept consensus (agreement between the students).
  ;; The consensus is calculated by first summing the variances for each of the concepts, then calculating the
  ;; standard deviation. Note: for independent random variables, the variance of their sums or differences is the sum of
  ;; their variances.
  ;; **** NOTE **** use the "Cluster" global to determine xcor vs ycor variance?
  let c-variance 0
  if Track and length hubnet-clients-list > 1
  [
    let i 1
    while [i <= concepts]
    [
      ifelse consensus-type = 0
      [set c-variance c-variance + variance [ ycor ] of students with [ concept-no = i ]]
      [set c-variance c-variance + variance [ xcor ] of students with [ concept-no = i ]]
      set i i + 1
    ]
  ]
  report sqrt c-variance
end


to-report random-between [ min-num max-num ]
    report random-float (max-num - min-num) + min-num
end
@#$#@#$#@
GRAPHICS-WINDOW
200
10
931
742
-1
-1
23.323
1
10
1
1
1
0
0
0
1
-15
15
-15
15
1
1
0
ticks
30.0

BUTTON
10
17
81
50
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
83
17
154
50
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
10
58
182
91
Levels
Levels
0
concepts
3.0
1
1
NIL
HORIZONTAL

SWITCH
10
140
113
173
Track
Track
0
1
-1000

SWITCH
10
181
113
214
Cluster
Cluster
1
1
-1000

BUTTON
10
97
93
130
Clear Grid
ask patches [set pcolor black]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
99
97
182
130
Draw Grid
setup-levels
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
941
10
1224
243
Level Consensus
Time
Consensus
0.0
60.0
0.0
10.0
false
true
"" ""
PENS

PLOT
941
248
1224
482
Cluster Consensus
Time
Consensus
0.0
60.0
0.0
10.0
false
true
"" ""
PENS

BUTTON
945
770
1045
803
Start Recording
setup-consensus-data TRUE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1053
770
1153
803
Stop Recording
setup-consensus-data FALSE
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
6
287
194
512
13

TEXTBOX
8
269
158
287
Concept List:
11
0.0
1

SWITCH
10
223
138
256
Show-Links
Show-Links
0
1
-1000

PLOT
941
487
1226
722
Link Consensus
NIL
NIL
0.0
60.0
0.0
100.0
false
true
"" ""
PENS

BUTTON
978
729
1043
762
-10 s
scroll-plot 1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1052
729
1117
762
Reset
scroll-plot 0
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1126
729
1195
762
+10 s
scroll-plot -1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
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

When SETUP is pressed, the levels (defined using the _Levels_ slider, shown by grey horizontal bars) and the concepts are placed on the screen.  The concepts are arranged vertically on the world view in the order that they are listed in Input-Parameters.txt. The number of levels can be changed by clicking _Clear Grid_, selecting a new number of levels, then clicking _Draw Grid_.

* Instructor (server) View: The concepts are listed vertically in the centre of the world view and are listed in the output area (under 'Concept List:').
* Student (client) View: The concepts are listed vertically to the right of the world view.

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

The instructor can view the student links by selecting _Show Links_. The student links are coloured based on consensus:

* Green: All students have identified this link.
* Yellow: More than 2/3 of the students have identified this link (100% < no. students <= 67%).
* Orange: More than 1/3 of the students have identified this link (670% < no. students <= 33%).
* Red: Less than 1/3 of the students have identified this link.

As well, the instructor can monitor the degree of student 'link consensus' using the _Link Consensus_ plot. This plot becomes active once _Show Links_ is selected. 

## NEXT STEPS

### Links 
Links can be created by students (clients) using the interface. Possible improvements:

* It would be interesting to see if the links can be created by a "drag-and-click" type approach.

### Server Interface Links
It will be useful to have a means of comparing consensus on the formation of links. 

* Work has started on this with the ``` view-student-links ``` procedure. Eventually, this should be incorporated into the go method.
* The procedure is intended to show all links, and colour them based on the degree of consensus.

### Instructor (Server) Functions
I would be useful to have some controls on the instructor (server) interface for data monitoring and collection.

* buttons could be added to allow the instructor to scroll back and forward in time with the consensus plots.

### Student (Client) Functions
It may be useful to allow students or the instructor to add additional concepts to the world view (see "How to Use it" above).

### Metrics
Some features should be added that provide some insight into the _evolution_ of the concept map over time.

* An instructor view plot that tracks the _degree of consensus_. Currently, two plots have been created that show the standard deviation of the concept positions _vs._ time. 'scroll back' and 'scroll forwar' buttons could be placed under the plot to allow the instructor to look back at consensus.
* The _degree of consensus_ can also be collected for the individual concepts for external analysis. The Rapid Miner tool is worth exploring for data analysis.
* An indication of which concepts are the most _troublesome_. This metric will have to be defined: e.g., based on the Std Dev, based on the length of time to reach consensus. This metric is important with respect to the notion of identifying _threshold concepts_.
* Link consensus needs to be tracked as noted above. 

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
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

box 2
false
0
Polygon -7500403 true true 150 285 270 225 270 90 150 150
Polygon -13791810 true false 150 150 30 90 150 30 270 90
Polygon -13345367 true false 30 90 30 225 150 285 150 150

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
VIEW
252
10
983
650
0
0
0
1
1
1
1
1
0
1
1
1
-15
15
-15
15

CHOOSER
20
18
158
63
From-Concept
From-Concept
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0

MONITOR
20
70
178
119
FromConcept
NIL
3
1

CHOOSER
20
126
158
171
To-Concept
To-Concept
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
0

MONITOR
21
179
179
228
ToConcept
NIL
3
1

INPUTBOX
20
236
249
296
Proposition
NIL
1
0
String

BUTTON
21
307
125
340
Create-Link
NIL
NIL
1
T
OBSERVER
NIL
NIL

BUTTON
130
307
242
340
Remove-Link
NIL
NIL
1
T
OBSERVER
NIL
NIL

@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
