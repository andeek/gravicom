library(plyr)
library(reshape2)

chapters <- read.csv("paper/data/got/chapters.csv")
characters <- read.csv("paper/data/got/characters.csv")
events <- read.csv("paper/data/got/events.csv")
teams <- read.csv("paper/data/got/teams.csv")


##look at important coappearance in chapters
chaps <- ddply(subset(events, event!="mentioned"), .(chapterID, characterID), nrow)
chaps_with <- subset(events, !is.na(withID))[, c(1,2,5)]
chaps_with.m <- melt(chaps_with, id.var="chapterID")[,c("chapterID", "value")]
names(chaps_with.m)[2] <- "characterID"
chaps_with.m$V1 <- rep(1, nrow(chaps_with.m))

chaps <- merge(rbind(chaps, chaps_with.m), chapters, by.x='chapterID', by.y='ID', all.x=TRUE)
#chaps <- merge(chaps, chapters, by.x='chapterID', by.y='ID', all.x=TRUE)




#function to create gml files for gravicom
makegraph <- function(id) {
  require(reshape2)
  require(plyr)
  require(igraph)
  
  w <- dcast(subset(chaps, bookID == id)[,c(1,2,3)], characterID ~ chapterID, value.var="V1", fun.aggregate = sum)
  coocc <- ldply(apply(w[,-1], 2, function(col) expand.grid(w[col > 0,]$characterID, w[col > 0,]$characterID)), function(x) x)
  coocc <- subset(coocc, Var1 != Var2)
  names(coocc) <- c("chapterID", "charID_1", "charID_2")
  coocc <- merge(merge(coocc, characters, by.x="charID_2", by.y="characterID", all.x=TRUE)[,1:4], characters, by.x="charID_1", by.y="characterID", all.x=TRUE)[,1:5]
  names(coocc) <- c("charID_1", "charID_2", "chapterID", "charName_2", "charName_1")
  graph <- graph.data.frame(coocc[,c("charName_1", "charName_2")], directed=FALSE)
  graph <- simplify(graph, remove.loops=FALSE)
  V(graph)$label <- V(graph)$name
  V(graph)$name <- 1:length(V(graph))
  write.graph(graph, sprintf("paper/data/got/book_%x.gml", id), format="gml")
}

#apply to all chapters
sapply(0:4, makegraph)


