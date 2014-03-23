dynGraph <- function(inputoutputId) 
{
  div(id = inputoutputId, class="d3graph")
}

shinyUI(pageWithSidebar(
  
  headerPanel("gravicom: Graphical Visualization of Communities"),
  
  sidebarPanel(
    includeScript("scripts/jquery.min.js"),
    includeScript("scripts/jquery-ui.js"),
    includeScript("scripts/d3.v3.js"),
    includeCSS("css/jquery-ui.css"),
    includeHTML("scripts/graph_2.js"),
    helpText(HTML("<p>Select a dataset from the drop down or upload your own. To start detecting communities, select points and monitor the table below for updates on number of edges within your selection versus outside. When you are happy with the community selected, click a selected point to group them and continue.</p><p>Tip: Use the shift key for multiple selections!</p>")),
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
    p(HTML("<h4>User Selection</h4>")),
    tableOutput('d3summary'),
    helpText(HTML("All source available on <a href = 'https://github.com/andeek/gravicom' target='_blank'>Github</a>"))
  ),
  
  mainPanel(    
    tabsetPanel(      
      tabPanel("Graph", dynGraph(inputoutputId = 'd3io')),
      tabPanel("Groups", htmlOutput("groupTable"))
    )
  )
))
