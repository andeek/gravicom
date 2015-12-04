library(igraph)
G <- graph_from_literal(A:B:C:D:E:F-A:B:C:D:E:F, A1:B1:C1:D1:E1:F1-A1:B1:C1:D1:E1:F1,A-A1,B-B1,C-C1,D-D1,E-E1,F-F1,
                         A-F1,B-C1,C-D1,D-E1,E-F1,F-A1)
G <- set.vertex.attribute(G, "label", index = V(G), value = get.vertex.attribute(G, "name"))
fc <- fastgreedy.community(G)

G <- set.vertex.attribute(G, "name", index = V(G), value = as.character(0:11))
write_graph(G, "paper/submission2/data/small_test.gml", format = "gml")


#plot results ------------------
G_grouped <- as.undirected(read_graph("paper/submission2/data/small_test_grouped.gml", format = "gml"))
plot(G_grouped, vertex.color = V(G_grouped)$Group)
