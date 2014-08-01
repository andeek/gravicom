<style>
.reveal section del,
.reveal h1 del,
.reveal h3 del {
  color: #0772A1;
}

.reveal section code {
  font-size: 14px;
}

.reveal, .reveal h3 {
  color: #333333;
}

.reveal table {
  font-size: 14px;
  border-collapse: collapse;
  float: left;
}

/*** section background ***/
.section .reveal .state-background {
   background: #0772A1;
}

/*** navigation color ***/
.reveal .controls div.navigate-left,
.reveal .controls div.navigate-left.enabled {
  border-right-color: #0990CC;
}

.reveal .controls div.navigate-right,
.reveal .controls div.navigate-right.enabled {
  border-left-color: #0990CC;
}

.reveal .controls div.navigate-up,
.reveal .controls div.navigate-up.enabled {
  border-bottom-color: #0990CC;
}

.reveal .controls div.navigate-down,
.reveal .controls div.navigate-down.enabled {
  border-top-color: #0990CC;
}

.reveal .controls div.navigate-left.enabled:hover {
  border-right-color: #0BB5FF;
}

.reveal .controls div.navigate-right.enabled:hover {
  border-left-color: #0BB5FF;
}

.reveal .controls div.navigate-up.enabled:hover {
  border-bottom-color: #0BB5FF;
}

.reveal .controls div.navigate-down.enabled:hover {
  border-top-color: #0BB5FF;
}

.reveal .progress span {
  background: #0990CC;
}

.reveal blockquote {
  background: #0772A1;
  color: white;
}
</style>

gravicom
========================================================
author: Andee Kaplan, Heike Hofmann, Daniel Nordman
date: August 3, 2014
font-family: Helvetica
css: css/charts.css

A web-based tool for community detection in networks

<br/><br/><br/>
<img src="images/jsm.jpg" width=15%/>

Introduction
========================================================
type: section

Who cares and why did we make this?

Networks 
========================================================
- Many relationships easily conceptualized as a graph/network
- A ~~graph~~ is defined as a collection of nodes (entities) and edges (relationships)
- A ~~community~~ is defined as a group of nodes in a graph that share properties
- Examples of such relationships include:
  - social networks (sociology)
  - the world wide web (computer science)
  - protein networks (biology)


The Problem
========================================================
- Current methodology for ~~community detection~~ often involves an algorithmic approach; partitions a graph into node clusters iteratively before stopping criterion
- First define an objective function and then optimize
- Many different objective functions possible, providing many ways to split a graph.
- The optimization of an objective function is typically an NP-hard problem
- The number of possible partitions of the network requires \(2^n\) complexity


Current Solutions
========================================================
- Heuristics used to optimize the objective function in a reasonable amount of time
- Heuristic-based clustering is useful because this offers an automated way to perform community detection 

>The main elements of the problem themselves [graph clustering], i.e. the concepts of community and partition, are not rigorously defined, and require some degree of arbitrariness and/or common sense. (Fortunato, 2010)


- Heuristics are not ~~the~~ solution.

Leverage the Human Visual System
========================================================
- Communities are often fuzzily-defined human concepts
- Address this by adding element of human judgement
- Introduce a novel visualization-based community detection tool, ~~gravicom~~

gravicom Functionality
========================================================
- Allows users to 
  - Visually direct and interact with the steps of community detection
  - Assess the created clusters through visual and quantitative summaries
- Standalone exploratory tool for graph data
- Initial state to be passed to a community detection algorithm in order reduce the complexity of optimization

Demo
========================================================
type: section

http://glimmer.rstudio.com/andeek/gravicom

- Shiny: Server-client interaction
- D3: User interface and graph layout
- igraph/rjson: Data formatting

Football Example
========================================================
![Site Components](images/football_progression.png)

Football Example (Cont'd)
========================================================


<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Aug 01 14:58:45 2014 -->
<TABLE border=1>
<TR> <TH> Conference </TH> <TH> Teams Identified </TH> <TH> Proportion </TH> <TH> Accuracy </TH>  </TR>
  <TR> <TD align="center"> SEC </TD> <TD> Vanderbilt,  Florida,  Louisiana State,  South Carolina,  Mississippi,  Arkansas,  Auburn,  Kentucky,  Georgia,  Mississippi State,  Alabama,  Tennessee </TD> <TD align="center"> 1.50 </TD> <TD align="center"> 100% </TD> </TR>
  <TR> <TD align="center"> MAC </TD> <TD> <i><del> Central Florida</del></i>,  Western Michigan,  Miami Ohio,  Ohio,  Bowling Green State,  Marshall,  Ball State,  Akron,  Buffalo,  Northern Illinois,  Eastern Michigan,  Toledo,  Central Michigan,  Kent </TD> <TD align="center"> 1.46 </TD> <TD align="center"> 92.9% </TD> </TR>
  <TR> <TD align="center"> Big 12 </TD> <TD> Kansas State,  Iowa State,  Kansas,  Texas A& M,  Texas Tech,  Baylor,  Missouri,  Texas,  Oklahoma State,  Colorado,  Oklahoma,  Nebraska </TD> <TD align="center"> 1.44 </TD> <TD align="center"> 100% </TD> </TR>
  <TR> <TD align="center"> ACC </TD> <TD> Duke,  Wake Forest,  Virginia,  Florida State,  Clemson,  North Carolina,  Maryland,  Georgia Tech,  North Carolina State </TD> <TD align="center"> 1.44 </TD> <TD align="center"> 100% </TD> </TR>
  <TR> <TD align="center"> Pac-10 </TD> <TD> Arizona,  Oregon State,  Washington,  Washington State,  Arizona State,  UC LA,  Stanford,  Southern California,  Oregon,  California </TD> <TD align="center"> 1.33 </TD> <TD align="center"> 100% </TD> </TR>
  <TR> <TD align="center"> Big 10 </TD> <TD> Ohio State,  Penn State,  Michigan,  Michigan State,  Purdue,  Minnesota,  Northwestern,  Illinois,  Iowa,  Wisconsin,  Indiana </TD> <TD align="center"> 1.22 </TD> <TD align="center"> 100% </TD> </TR>
   <A NAME=tab:football_final></A>
</TABLE>

Football Example (Cont'd)
========================================================
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Aug 01 14:58:45 2014 -->
<TABLE border=1>
<TR> <TH> Conference </TH> <TH> Teams Identified </TH> <TH> Proportion </TH> <TH> Accuracy </TH>  </TR>
  <TR> <TD align="center"> WAC </TD> <TD> Nevada,  Fresno State, <i><del> Texas Christian</del></i>,  Tulsa,  Hawaii,  Rice,  Southern Methodist,  San Jose State,  Texas El Paso </TD> <TD align="center"> 1.20 </TD> <TD align="center"> 88.9% </TD> </TR>
  <TR> <TD align="center"> Mountain West </TD> <TD> Brigham Young,  San Diego State, <i><del> Boise State</del></i>,  Wyoming,  New Mexico,  Nevada Las Vegas,  Utah, <i><del> North Texas</del></i>, <i><del> Utah State</del></i>, <i><del> New Mexico State</del></i>,  Colorado State, <i><del> Arkansas State</del></i>, <i><del> Idaho</del></i>,  Air Force </TD> <TD align="center"> 0.96 </TD> <TD align="center"> 57.1% </TD> </TR>
  <TR> <TD align="center"> C-USA </TD> <TD> Cincinnati,  Louisville,  Houston,  Tulane,  Southern Mississippi,  Army,  Memphis,  East Carolina,  Alabama Birmingham </TD> <TD align="center"> 0.91 </TD> <TD align="center"> 100% </TD> </TR>
  <TR> <TD align="center"> Big East </TD> <TD> Boston College,  Miami Florida,  Virginia Tech,  Syracuse,  Temple,  West Virginia, <i><del> Connecticut</del></i>,  Pittsburgh,  Rutgers </TD> <TD align="center"> 0.83 </TD> <TD align="center"> 88.9% </TD> </TR>
  <TR> <TD align="center"> Big West </TD> <TD> Middle Tennessee State,  Louisiana Lafayette,  Louisiana Monroe, <i><del> Louisiana Tech</del></i> </TD> <TD align="center"> 0.26 </TD> <TD align="center"> 75% </TD> </TR>
  <TR> <TD align="center"> Independent </TD> <TD> Notre Dame,  Notre Dame,  Navy,  Navy </TD> <TD align="center"> 0.00 </TD> <TD align="center"> 100% </TD> </TR>
   <A NAME=tab:football_final></A>
</TABLE>
- Through manual specification of conferences, we were able to correctly classify 91.3 % of the football teams into their conferences. 

Graphical Devices
========================================================
type: section

Theory behind the curtain

Importance of Graph Layout
========================================================
- ~~Graph layout~~ is an assignment of a Cartesian coordinate to each node for display in 2D or 3D
- Layout of a graph significantly affects the number of communities that users detect within a graph
- Humans used to detect communities \( \Rightarrow \) special attention needs to be paid to the layout being used
- Location of a node spatially relative to other nodes in a cluster has a significant effect on user: "adjacent nodes must be placed near to each other if possible" (McGrath, Blythe, and Krackhardt, 1996)
- A force-directed layout satisfies these requirements by placing repulsive forces on nodes to separate all pairs of nodes with fixed-distance geometric constraints as links

Graph Simplification
========================================================
- Difficult to glean meaning from a visual representation in large/complex graphs 
- Replace repeated patterns in a graph by a representation, to simplify a network
- Fewer nodes and edges to display \( \Rightarrow \) visual complexity of the graph visualization is greatly reduced
- Allows the user to analyze the network structure more accurately

Conclusions/Further Work
========================================================
type: section

Possible extensions to gravicom

Ideas
========================================================
- Integrated algorithmic community detection
  - Combine the benefits of human detection of communities with algorithmic detection
  - Visual detection of communities serves as an initialization step, then pass to iterative algorithm
  - User tracks progress and has power to dynamically set stopping criterion
- Dynamic temporal graph visualization
  - View a dynamic graph across time -- how the edges change between nodes 
  - Detect time-dependent communities; Add optional node labels to track progress

Questions?
========================================================
type: section

Thank you!


Appendix
========================================================
type: section

Extra stuff and things.


Page Lifecycle
========================================================
![Integrated Algorithm](images/pagelifecycle.png)

Tools (Cont'd)
========================================================
![Integrated Algorithm](images/clientserverflow.png)

Data Formatting
========================================================
GML file structure:

```
graph
[
  directed 0
  node
  [
    id 0
    label "Node 1"
    value 100
  ]
  node
  [
    id 1
    label "Node 2"
    value 200
  ]
  edge
  [
    source 1
    target 0
  ]
]
```

JSON file structure:

```
{
  "nodes":
  [{"id":"n0","v_id":"0","v_label":"Node 1","v_value":"100"}, 
   {"id":"n1","v_id":"1","v_label":"Node 2","v_value":"200"}], 
 "edges":
  [{"source":0, "target":1}]
}
```



<script type="text/javascript" src="scripts/jquery.min.js"></script>
<script type="text/javascript" src="scripts/d3.v3.min.js"></script>
<script type="text/javascript" src="scripts/charts.js"></script>
<script>
$(document).ready(function() { 
  (particleChart())() ;   
});
</script>

