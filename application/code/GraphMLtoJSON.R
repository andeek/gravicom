GraphMLtoJSON<-function(file){
  require(XML)
  require(rjson)
  require(plyr)
  
  graph<-xmlRoot(xmlTreeParse(file))[["graph"]]
  
  nodes<-xmlElementsByTagName(graph, "node")
  edges<-xmlElementsByTagName(graph, "edge")
  
  node_list<-list()
  for(i in 1:length(nodes)){
    id<-xmlGetAttr(nodes[[i]], "id")
    data<-xmlElementsByTagName(nodes[[i]], "data")
    data_list<-list()
    for(j in 1:length(data)) {
      data_list[[xmlGetAttr(data[[j]],"key")]]<-xmlValue(data[[j]])  
    }
    node_list[[i]]<-cbind(id, data.frame(data_list))
  }
  
  edge_list <- lapply(1:length(edges),function(i) c(source=xmlGetAttr(edges[[i]],"source"), target=xmlGetAttr(edges[[i]],"target")))

  temp.n<-ldply(node_list)
  temp.e<-ldply(edge_list)
  e.2<-data.frame(source=apply(temp.e, 1, function(x) which(temp.n$id == x["source"])-1),
                  target=apply(temp.e, 1, function(x) which(temp.n$id == x["target"])-1))
  
  edge_list.2<-split(e.2, 1:nrow(e.2))
  names(edge_list.2)<-NULL
  
  merge_lists<-list()
  merge_lists$nodes<-node_list
  merge_lists$edges<-edge_list.2
  return(toJSON(merge_lists))
}