# .libPaths("/home/andeek/R/library")
# addResourcePath('images', '~/ShinyApps/DevNetworkGraph/images')
# addResourcePath('scripts', '~/ShinyApps/DevNetworkGraph/scripts')
# addResourcePath('data', '~/ShinyApps/DevNetworkGraph/data')
#addResourcePath('images', '/var/shiny-server/www/D3/Network\ Graph/images') 
#addResourcePath('images', 'U:/Documents/Projects/Community-Detection/Prototype\ D3-Shiny/Network\ Graph/images')
#addResourcePath('images', '~/Documents/Projects/Community-Detection/Prototype\ D3-Shiny/Network\ Graph/images')

library(plyr)

#data_sets <- c("data/football.gml", "data/karate.gml")
#layouts <- c("force")
data_sets <- paste("data/", list.files("data/", pattern="*.gml"), sep="")

getXMLfromFile <- function(file) {
  require(igraph)
  graph<-read.graph(file, format="gml")  
  layout <- layout.auto(graph)
  V(graph)$x <- layout[,1]
  V(graph)$y <- layout[,2]
  write.graph(graph, paste(strsplit(file, "\\.")[[1]][1], ".xml", sep=""), format="graphml")
  
  graph.df<-get.data.frame(graph, what="vertices")
  
  if('Group' %in% colnames(graph.df)) {
    index <- max(as.numeric(graph.df$Group), na.rm=TRUE) + 1
  } else {
    index <- 0
  }
  return(list(loc=paste(strsplit(file, "\\.")[[1]][1], ".xml", sep=""), index=index))
}

shinyServer(function(input, output) {
  source("code/GraphMLtoJSON.R")
  # Drop-down selection box for which data set
  output$choose_dataset <- reactiveUI(function() {
    selectInput("dataset", "Data set", as.list(data_sets))
  })
  
  # Layouts
  #output$choose_layout <- reactiveUI(function() {
    # If missing input, return to avoid error later in function
  #  if(is.null(input$dataset)) return()
  #  selectInput("layout", "Graph Layout", as.list(layouts))
  #})
  
  data <- reactive({
    #if(is.null(input$dataset) | is.null(input$layout))    
    supported_formats<-c("gml")
    
    if(!input$upload) {
      if(is.null(input$dataset)) return()
      else if(tolower(strsplit(input$dataset, "\\.")[[1]][2]) %in% supported_formats) {
        #return(list(data_json=GraphMLtoJSON(getXMLfromFile(input$dataset)), layout=input$layout))
        xml <- getXMLfromFile(input$dataset)        
        return(list(data_json=GraphMLtoJSON(xml$loc), index = xml$index))
      } else {
        return()  
      }
    } else {
      if(is.null(input$dataset_up)) return()
      else if(tolower(strsplit(input$dataset_up$name, "\\.")[[1]][2]) %in% supported_formats) {
        tryCatch({
          #return(list(data_json=GraphMLtoJSON(getXMLfromFile(input$dataset)), layout=input$layout))
          xml <- getXMLfromFile(input$dataset_up$datapath)
          return(list(data_json=GraphMLtoJSON(xml$loc), index = xml$index))
        }, error = function(e) {
          d <-  tempdir()
          unlink(d, recursive=TRUE)
          return()
        })
      } else {
        return()  
      }
    }
  })
  output$d3io <- reactive({ data() })
  
  datasetInput <- reactive({    
    empty<-data.frame(Within=0, Outside=0, Proportion=NA, row.names="Connections")
    
    if(exists("input") && length(names(input)) > 0){
      if(names(input)[1] == "d3io") {
        nodes<-ldply(input[[names(input)[names(input) == "d3io"]]]["nodes"][[1]], function(x) data.frame(x[c("_count","group","id","index","selected","weight")]))
  
        if("selected" %in% names(nodes)) { 
          nodes_selected<-as.character(subset(nodes, selected == 1)$id)
          edges<-ldply(input[[names(input)[names(input) == "d3io"]]]["links"][[1]], function(x) data.frame(c(x[["source"]][c("id", "selected")], x[["target"]][c("id", "selected")], x["strength2"])))
          names(edges) <- c("source.id", "source.selected", "target.id", "target.selected", "strength")
          if(nrow(edges) > 0) {
            edges_selected<-subset(edges, source.selected == 1 | target.selected == 1)
            within_selected<-subset(edges_selected, as.character(source.id) %in% nodes_selected & as.character(target.id) %in% nodes_selected)
            #n_total_selected<-nrow(edges_selected)
            #n_within_selected<-nrow(within_selected)
            n_total_selected<-sum(edges_selected$strength)
            n_within_selected<-sum(within_selected$strength)
          } else {
            n_total_selected<-0
            n_within_selected<-0
          }        
          empty<-data.frame(Within=n_within_selected, Outside=n_total_selected - n_within_selected, Proportion=ifelse(n_total_selected - n_within_selected != 0, round(as.numeric(n_within_selected)/as.numeric(n_total_selected - n_within_selected), 4),NA), row.names="Connections")
          
        }
      }
    }
    
    return(empty)
  })
  
  
  datasetDownload <- reactive({
    require(igraph)
    
    supported_formats<-c("gml")
    graph.df<-list(vertices=data.frame(id=character(), label=character(), value=character()), edges=data.frame(from=character(), to=character()))
    empty<-data.frame(Node=character(), Group=character())
    
    if(!input$upload) {
      if(is.null(input$dataset)) return()
      else if(tolower(strsplit(input$dataset, "\\.")[[1]][2]) %in% supported_formats) {
        graph<-read.graph(input$dataset, format="gml")
        graph.df<-get.data.frame(graph, what="both")
      } 
    } else {
      if(is.null(input$dataset_up)) return()
      else if(tolower(strsplit(input$dataset_up$name, "\\.")[[1]][2]) %in% supported_formats) {
        tryCatch({
          graph<-read.graph(input$dataset_up$datapath, format="gml")
          graph.df<-get.data.frame(graph, what="both")
        }, error = function(e) {
          return()
        })
      } 
    }  
    
    
    if(exists("input") && length(names(input)) > 0){      
      if(names(input)[1] == "d3io") {
        nodes<-input[[names(input)[names(input) == "d3io"]]]["nodes"][[1]]
        
        for(i in 1:length(nodes)) {
          if(nodes[[i]]['_count'] > 1) {
            for(j in 1:length(nodes[[i]][['rollednodes_label']])) {
              empty<-rbind(empty, cbind(Node=as.character(nodes[[i]][['rollednodes_label']][[j]]), Group=as.character(nodes[[i]]['group'])))
              names(empty)<-c("Node","Group")
            }
          }
        }        
        empty<-empty[with(empty, order(as.numeric(as.character(Group)), as.character(Node))), ]
      }
    }
    
    graph.final<-list(vertices=data.frame(id=character(), label=character(), value=character()), edges=data.frame(from=character(), to=character()))
    
    #some graphs have no labels
    if(!('label' %in% colnames(graph.df$vertices))){
      graph.df$vertices$label <- paste("n",graph.df$vertices$id,sep="")
    }
    
    if(!('value' %in% colnames(graph.df$vertices))){
      graph.df$vertices$value <- NA
    }
    
    if('Group' %in% colnames(graph.df$vertices)) {
      graph.df$vertices$Group <- NULL
    }
    
    graph.final$vertices<-merge(graph.df$vertices, empty, by.x="label", by.y="Node", all.x=TRUE)
    graph.final$vertices$Group<-as.character(graph.final$vertices$Group)
    graph.final$vertices[is.na(graph.final$vertices$Group), "Group"] <- paste("n", graph.final$vertices[is.na(graph.final$vertices$Group), "id"], sep="")
    graph.final$vertices <- graph.final$vertices[with(graph.final$vertices, order(id)), c("id", "label", "value", "Group")]
    
    
    
    if(min(c(as.numeric(graph.df$edges$to), as.numeric(graph.df$edges$from))) == min(graph.df$vertices$id)) {
      graph.final$edges<-apply(graph.df$edges, 2, as.numeric)
    } else {
      graph.final$edges<-apply(graph.df$edges, 2, function(x) {as.numeric(x) + min(graph.df$vertices$id) - 1})
      ##for some reason igraph starts indexing at 1 not 0
    } 
    
    return(graph.final)    
  })
  
  
  output$d3summary <- renderTable({dataset <- datasetInput()
                                   print(dataset)}, digits=c(0,0,0,4))
  
  output$groupTable <- renderText({
    html<-"<div id='accordion'>"
    
    empty<-data.frame(Node=character(), Group=character())
    
    if(names(input)[1] == "d3io") {
      nodes<-input[[names(input)[names(input) == "d3io"]]]["nodes"][[1]]
      
      for(i in 1:length(nodes)) {
        if(nodes[[i]]['_count'] > 1) {
          for(j in 1:length(nodes[[i]][['rollednodes_label']])) {
            empty<-rbind(empty, cbind(Node=as.character(nodes[[i]][['rollednodes_label']][[j]]), Group=as.character(nodes[[i]]['group'])))
            names(empty)<-c("Node","Group")
          }
        }
      }
      
      empty<-empty[with(empty, order(as.numeric(as.character(Group)), as.character(Node))), ]
    }
    
    for(g in as.character(unique(empty$Group))) {
      html<-paste(html,"<h3>Group ", g, " (", nrow(subset(empty, as.character(Group) == g)), ")", "</h3><div><ul>", sep="")
      for(n in as.character(subset(empty, as.character(Group) == g)$Node)) {
        html<-paste(html,"<li>", n, "</li>", sep="")
      }
      html<-paste(html,"</ul></div>", sep="")
    }
    html<-paste(html,"</div>", sep="")
    html<-paste(html, "<script> $( '#accordion' ).accordion({active: false, collapsible: true});</script>", sep="")
    return(html)
  })
  
  
  output$downloadData <- downloadHandler(
    filename = "network.gml",
    content = function(file) {
      require(igraph)
      df <- datasetDownload()
      g <- graph.data.frame(df$edges, vertices=df$vertices)
      write.graph(g, file, format="gml")
    })

  
})
