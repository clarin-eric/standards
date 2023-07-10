document.addEventListener('DOMContentLoaded', function() {
  window.onload=init();
});

function init(){
    checkActiveRI();
    createTags();
}

function createTags() {      
try {
  TagCanvas.Start('myCanvas','tags',{
    textColour: '#2070AA',
    outlineColour: '#DDDDDD',
    reverse: true,
    depth: 0.5,
    minBrightness:0.2,
    wheelZoom: false,
    maxSpeed: 0.03,
    freezeActive:false,
    weight:true,
    weightSize:1.0            
  });
} catch(e) {
  // something went wrong, hide the canvas container
  document.getElementById('myCanvasContainer').style.display = 'none';
}
};