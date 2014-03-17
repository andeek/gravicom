<style>
.node {
  stroke: #fff;
  stroke-width: 1.5px;
}

.node .selected {
  stroke: red;
}

.hidden {
  stroke-width: 0px;
  opacity: 0;
}

.link {
  stroke: #999;
}

.brush .extent {
  fill-opacity: .1;
  stroke: #fff;
  shape-rendering: crispEdges;
}

.control {   
  margin-bottom: 5px;  
  height: 44px;
}

.button{
  float: left;
  margin-left: 5px;
  width: 44px !important;  
}
</style>
<script src="http://d3js.org/d3.v3.js"></script>
<script type="text/javascript">

var dataset;
var group_indx = 0;

var outputBinding = new Shiny.OutputBinding();
$.extend(outputBinding, {
  find: function(scope) {
    return $(scope).find('.d3graph');
  },
  renderValue: function(el, data) {  
	  wrapper(el, data);
}});
Shiny.outputBindings.register(outputBinding);

var inputBinding = new Shiny.InputBinding();
$.extend(inputBinding, {
  find: function(scope) {
    return $(scope).find('.d3graph');
  },
  getValue: function(el) {
    return dataset;
  },
  subscribe: function(el, callback) {
    $(el).on("change.inputBinding", function(e) {
      callback();
    });
  },
});
Shiny.inputBindings.register(inputBinding);

function wrapper(el, data) {
  var w = 550,
      h = 400,
      node,
      link,
      root;

  var force = d3.layout.force()
      .on("tick", tick)
      .size([w, h]);

  var svg = d3.select(el).append("svg")
      .attr("width", w)
      .attr("height", h);

  d3.json(data.data_json, function(json) {
    root = json;
    update();
  });
  
  function update() {
    var nodes = flatten(root),
        links = d3.layout.tree().links(nodes);
  
    // Restart the force layout.
    force
        .nodes(nodes)
        .links(links)
        .start();
  
    // Update the links…
    link = svg.selectAll("line.link")
        .data(links, function(d) { return d.target.id; });
  
    // Enter any new links.
    link.enter().insert("line", ".node")
        .attr("class", "link")
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
  
    // Exit any old links.
    link.exit().remove();
  
    // Update the nodes…
    node = svg.selectAll("circle.node")
        .data(nodes, function(d) { return d.id; })
        .style("fill", color);
  
    // Enter any new nodes.
    node.enter().append("circle")
        .attr("class", "node")
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; })
        .attr("r", function(d) { return Math.sqrt(d.size) / 10 || 4.5; })
        .style("fill", color)
        .on("click", click)
        .call(force.drag);
  
    // Exit any old nodes.
    node.exit().remove();
  }
  
  function tick() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });
  
    node.attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });
  }
  
  // Color leaf nodes orange, and packages white or blue.
  function color(d) {
    return d._children ? "#3182bd" : d.children ? "#c6dbef" : "#fd8d3c";
  }
  
  // Toggle children on click.
  function click(d) {
    if (d.children) {
      d._children = d.children;
      d.children = null;
    } else {
      d.children = d._children;
      d._children = null;
    }
    update();
  }
  
  // Returns a list of all nodes under the root.
  function flatten(root) {
    var nodes = [], i = 0;
  
    function recurse(node) {
      if (node.children) node.children.forEach(recurse);
      if (!node.id) node.id = ++i;
      nodes.push(node);
    }
  
    recurse(root);
    return nodes;
  }

  
  
}
</script>
