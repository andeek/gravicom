dynGraph <- function(inputoutputId) 
{
  div(id = inputoutputId, class="d3graph")
}

shinyUI(
  navbarPage("[ gravicom ]",
             id="top-nav",  theme = "bootstrap.min.css", inverse=TRUE,
             
             
             tabPanel(title="", icon=icon("home"),  
                      column(5,
                             wellPanel(
                                h4("gravicom:"),
                                h5("Graphical Visualization of Communities"),
                                p("A web application for facilitating the detection of community structures through direct user interaction. Built on the R package Shiny and the JavaScript library D3."),
                                p("For more information and instructions on use, click the question mark above."),
                                hr(),
                                conditionalPanel(
                                  condition = "input.upload == false",
                                  uiOutput("choose_dataset")
                                ),
                                checkboxInput("upload", "Upload new dataset", FALSE),
                                conditionalPanel(
                                  condition = "input.upload == true",
                                  fileInput('dataset_up', 'Choose GML File',
                                            accept="text/xml; subtype='gml/3.1.1'")
                                ),   
                                downloadButton('downloadData', 'Download current dataset'),
                                #uiOutput("choose_layout"),
                                hr(),
                                p("User Selection"),
                                tableOutput('d3summary')
                              )
                      ),
                
                      column(7,    
                        tabsetPanel(      
                          tabPanel("Graph", dynGraph(inputoutputId = 'd3io')),
                          tabPanel("Groups", htmlOutput("groupTable"))
                          )
                      )
                ),
             tabPanel(title="", value="http://andeekaplan.com/gravicom", icon=icon('question-circle')),
             tabPanel(title="", value="http://andeekaplan.com", icon=icon('envelope')),
             tabPanel(title="", value="http://github.com/andeek/gravicom", icon=icon("github")),
             footer=tagList(
               includeScript("scripts/jquery.min.js"),
               includeScript("scripts/jquery-ui.js"),
               includeScript("scripts/d3.v3.js"),
               includeScript("scripts/top-nav-links.js"),
               includeHTML("scripts/graph_2.js"),
               includeCSS("css/jquery-ui.css")
             ),
             tags$head(tags$link(rel="shortcut icon", href="images/icon.png"))
  )
)
