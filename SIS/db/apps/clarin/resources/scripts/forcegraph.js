var linkedByIndex = {};

function moveto (d) {
         return "M"+d.source.x+","+d.source.y;
      };
    
      function lineto (d) {
         return " L"+d.target.x+","+d.target.y;
      };
    
function drawGraph(data,w,h,c){  
    
    var json = eval ("(" + data + ")");
    
    var width = w, height = h
    var svg = d3.select("#chart").append("svg")
        .attr("width", width)
        .attr("height", height);
    
    var force = d3.layout.force()
        .nodes(json.nodes)
        .links(json.links)
        .gravity(.05)
        .distance(100)
        .charge(c)
        .linkDistance(80)
        .size([width, height])
        .start();
        
   json.links.sort(function(a,b) {
    if (a.source > b.source) {return 1;}
    else if (a.source < b.source) {return -1;}
    else {
        if (a.target > b.target) {return 1;}
        if (a.target < b.target) {return -1;}
        else {return 0;}
    }
    });
    
   for (var i=0; i<json.links.length; i++) {
        if (i != 0 &&
            json.links[i].source == json.links[i-1].source &&
            json.links[i].target == json.links[i-1].target) {
                json.links[i].linknum = json.links[i-1].linknum + 1;
            }
        else {json.links[i].linknum = 1;};
    };
    
 var marker = svg.append("defs")
       .append("svg:marker")
       .attr("id", "arrow")
       .attr("viewBox", "0 -5 10 10")
       .attr("refX", 16)
       .attr("refY", -1.5)
       .attr("markerWidth", 7)
       .attr("markerHeight", 7)
       .attr("orient", "auto")
       .append("path")
       .attr("d", "M0,-7L10,0L-5,7")
       .style("fill", "grey");

    var link = svg.append("g").selectAll("path")
       .data(json.links)
       .enter().append("path")       
       .style("stroke", function(d){return d.label})
       .style("fill","none")
       .attr("marker-end", "url(#arrow)");
          
     var node = svg.selectAll(".node")
          .data(json.nodes)
          .enter().append("a")
          .attr("xlink:href", function(d) {return d.reflink})
          .attr("class", "node")
          .call(force.drag);
          
        node.append("circle")
        .attr("r", function(d) { return d.size;})
        .attr("class", "node")
        .style("fill", "grey")
        .style("stroke", "white");
    
        node.append("text")
          .attr("text-anchor","start")
          .attr("dy", ".35em")
          .attr("dx","12")          
          .style("fill","grey")
          .style("font","10px sans-serif")
          .text(function(d) { return d.name });
          
      force.on("tick", function() {
        link.attr("d", function(d) {
        var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = 75/d.linknum;  //linknum is defined above
        return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
         }); 
        node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
      });        
}