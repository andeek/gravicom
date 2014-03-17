<style type="text/css"> 
circle.node {
  cursor: pointer;
  stroke: #3182bd;
  stroke-width: 1.5px;
}

line.link {
  fill: none;
  stroke: #9ecae1;
  stroke-width: 1.5px;
}

circle.node.selected {
  stroke: red !important;
}

.brush .extent {
  fill-opacity: .1;
  stroke: #fff;
  shape-rendering: crispEdges;
}

.loading {
  font-size: 2em;
}
</style>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-17097461-1']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<script type="text/javascript">
  
var dataset_condense;
var group_indx;

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
    return dataset_condense;
  },
  subscribe: function(el, callback) {
    $(el).on("change.inputBinding", function(e) {
      callback();
    });
  },
});
Shiny.inputBindings.register(inputBinding);

function wrapper(el, data) {  
  var w = $('svg').parent().width(),
      h = $(window).height() - $('.span12').height() - 50 - $('.nav-tabs').height(),
      r = 6,
      root,
      node,
      link,
      shiftKey,
      color_scale = d3.scale.category20();;
 
  var force = d3.layout.force()
    .on("tick", tick)
    .linkDistance(30)
    .linkStrength(2)
    .gravity(.2)
    .friction(.7)
    .charge(-120)
    .size([w, h]);
  
  d3.select(el).select("svg").remove();
  var svg = d3.select(el)
    .attr("tabindex", 1)
    .on("keydown.brush", keydown)
    .on("keyup.brush", keyup)
    .each(function() { this.focus(); })
    .append("svg")
    .attr("width", w)
    .attr("height", h);
  
  // Add brushing functionality.
  var brush = svg.append("g")
    .datum(function() { return {selected: false, previouslySelected: false}; })
    .attr("class", "brush")
    .call(d3.svg.brush()
    .x(d3.scale.identity().domain([0, w]))
    .y(d3.scale.identity().domain([0, h]))
    .on("brushstart", function(d) {
      node.each(function(d) { d.previouslySelected = shiftKey && d.selected; });
    })
    .on("brush", function() {
      var extent = d3.event.target.extent();
      node.classed("selected", function(d) {
        return d.selected = d.previouslySelected ^
            (extent[0][0] <= d.x && d.x < extent[1][0]
            && extent[0][1] <= d.y && d.y < extent[1][1]);
      });        
    })
    .on("brushend", function() {
      d3.event.target.clear();
      d3.select(this).call(d3.event.target);
      $(".d3graph").trigger("change");
    }));  
  
  if(data) {
    group_indx = data.index;
    
    root = JSON.parse(data.data_json);
  
    var scale_x = d3.scale.linear()
      .domain(d3.extent(root.nodes, function(d){return parseFloat(d.v_x)}))
      .range([0, w]);
    
    var scale_y = d3.scale.linear()
      .domain(d3.extent(root.nodes, function(d){return parseFloat(d.v_y)}))
      .range([h,0]);
    
    //setup each nodes with count 1 and store "group" value to be changed later
    root.nodes.forEach(function(d) { 
      d.count = 1; d.group = ((d.v_Group && d.v_Group != 'NA') ? d.v_Group : d.id); d.index = d.v_id; d.x = scale_x(parseFloat(d.v_x)); d.y = scale_y(parseFloat(d.v_y)); d.selected=0;});
    
    update();
  }
  
  function update() {
    
    if(node && node.length > 0) { group(root); }
    dataset_condense = condense(root);
    
    var nodes = dataset_condense.nodes,
        links = dataset_condense.links;
    
    var scale = d3.scale.linear()
      .domain(d3.extent(links, function(d){return d.strength}))
      .range([0,1])
    
    // Restart the force layout.
    force
      .nodes(nodes)
      .links(links)
      .charge(function(d){ return -1*d.weight*d.weight*5; })
      .linkDistance(function(d){ return nodes[d.source.index]._count + nodes[d.target.index]._count + 28;})
      .linkStrength(function(d){ return scale(d.strength)*3; })
      .start()
      
    // Update the links…
    link = svg.selectAll("line.link")
        .data(links, function(d) { return d.source.id + "-" + d.target.id; });
    
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
      .data(nodes, function(d){ return d.id; })
      .style("fill", color)
      .style("stroke", function(d){ 
        if(d.selected == 0 && d._count > 1) return d3.rgb(color(d)).darker().toString();        
      });
    
    // Enter any new nodes.
    node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", function(d) { return d.x; })
      .attr("cy", function(d) { return d.y; })
      .attr("r", function(d) { return d._count; })
      .style("fill", color)
      .style("stroke", function(d){ if(d.selected == 0 && d._count > 1) return d3.rgb(color(d)).darker().toString();} )
      .on('touchstart', function(d) {
        d3.event.preventDefault(); // no scrolling
      })
      .on("click", function(d) {
        if(!d3.event.defaultPrevented) {click(d);}
      })
      .call(force.drag)
      
      
    node.append("title")
      .text(function(d) { return (typeof d.v_label === "undefined") ? d.id : d.v_label;});
    
    // Exit any old nodes.
    node.exit().remove();
    
    var safety = 0;
    while(force.alpha() > 0.05) { 
        force.tick();
        if(safety++ > 5) {
          break;
        }
    }
    
    node.each(function(n){
      var rnf = root.nodes.filter(function(r){ return r.id == n.id; });
      if(rnf[0]) {
        rnf[0].x = n.x;
  		  rnf[0].y = n.y;
  	  }
    });
    
    $(".d3graph").trigger("change");
  }
  
  function tick(e) {  
    link
      .attr("x1", function(d) { return d.source.x; })
      .attr("y1", function(d) { return d.source.y; })
      .attr("x2", function(d) { return d.target.x; })
      .attr("y2", function(d) { return d.target.y; });
    
    node
      .attr("cx", function(d) { return d.x = Math.max(r, Math.min(w - r, d.x)); })
      .attr("cy", function(d) { return d.y = Math.max(r, Math.min(h - r, d.y)); }); 
  }
  
  // Color leaf nodes orange, and packages white or blue.
  function color(d) {        
    //"#c6dbef" 
    return (d._count > 1) ?  color_scale(d.group % 20) :"#3182bd";
  }
  
  // Toggle children on click.
  function click(d) {
    toggle(d);
    toggle_group(d); 
    
    //set all nodes to count so they can be reconsidered by update
    root.nodes.forEach(function(e){ 
      if (e._count) {
        e.count = e._count;
        e._count = null;
      }
    });
    update();
  }
  
  function toggle_group(d) {
    if(d.count > 1) {
      //if node count > 1, set all nodes in group clicked to own group
      root.nodes.forEach(function(e) {
        if(d.rollednodes.indexOf(e.id) > -1) {
          e.group = e.id;
        }
      });
    }
  }
  
  function toggle(d) {
    if (d.count) {
      d._count = d.count;
      d.count = null;
    } else {
      d.count = d._count;
      d._count = null;
    }
  }
  
  function group(root) {
    var selected = node.filter(function(d) { return d.selected == 1; });

    selected.each(function(d){
      root.nodes.forEach(function(e){
        if(e.id == d.id) e.group = group_indx;
      })
    });     
    
    group_indx += 1;
  }
  
  function condense(root) {
    var nodes = [],
        links = [];
        
    //first group all the necessary nodes, then worry about links
    root.nodes.forEach(function(d) {      
      if(d.count) {
        //if count not _count = 1, group
        
        //need to grab all nodes with same group as d
        var root_n = root.nodes.filter(function(v) { return v.group == d.group;});  
        
        //avoid duplicates
        root_n.forEach(function(e) { toggle(e); });
        
        //create rollup of count on group
        var nodes_temp = [],
            names_temp = [];
        var nodes_hier_count = d3.nest()
        .key(function(e) { return e.group; }).sortKeys(d3.ascending)
        .rollup(function(e) {
          e.forEach(function(a){ 
            var label = (typeof a.v_label === "undefined") ? a.id : a.v_label;
            nodes_temp.push(a.id); names_temp.push(label);
          });
          return {length: e.length, nodes: nodes_temp, nodes_label: names_temp}; 
        })          
        .entries(root_n);
        
        nodes_hier_count.forEach( function(e) { 
          var label = (e.values.length == 1) ? d.v_label : "Group "+e.key;
          var x = (e.values.x & e.values.length == 1) ? parseFloat(e.values.x) : d3.mean(root_n, function(f){ return parseFloat(f.x); });
          var y = (e.values.y & e.values.length == 1) ? parseFloat(e.values.y) : d3.mean(root_n, function(f){ return parseFloat(f.y); });
          
          nodes.push({_count: e.values.length, group:e.key, id: e.key, index: nodes.length, v_label: label, rollednodes: e.values.nodes, rollednodes_label: e.values.nodes_label, selected: 0, x: x, y: y, px: x, py: y});
                              
        });
                
      }
      
    });
    
    var root_e = root.edges;

    root_e.forEach(function(f) {
      f.source_grp = root.nodes[f.source].group;
      f.target_grp = root.nodes[f.target].group;
    });  
    
    //rollup # target within source (use for weighting, but how?)
    var edges_hier = d3.nest()
    .key(function(e) { return e.source_grp; }).sortKeys(d3.ascending)
    .key(function(e) { return e.target_grp; }).sortKeys(d3.ascending)
    .rollup(function(e) {
      return {
        length:e.length
      };
    })
    .entries(root_e);  
    
    edges_hier.forEach( function(e) {
      //e sources
      e.values.forEach( function(f) {        
        //f targets
        var test = 0;
        links.forEach(function(g) { if(e.key == g.target && f.key == g.source) test+=1; });
        if(test == 0 && f.key != e.key) {
          var s = nodes.filter(function(v) { return v.id == e.key;}),
          t = nodes.filter(function(v) { return v.id == f.key;});
          links.push({source: parseInt(s[0].index.toString()), target: parseInt(t[0].index.toString()), strength: f.values.length + e.values.length, strength2: f.values.length});
        }        
      })
    });
    return {nodes: nodes, links: links};
  }
  
  function keydown() {
    shiftKey = d3.event.shiftKey;
  }
  
  function keyup() {
    shiftKey = d3.event.shiftKey;
  }
  
}
</script>
  
