function copyTextToClipboard(id,text) {
  navigator.clipboard.writeText(text).then(function() {
    var previousCopied = document.getElementsByClassName("hint clicked");
    if (previousCopied[0] != null)
        previousCopied[0].classList.toggle('clicked');
    var hintElement = document.getElementById("hint-".concat(id));
    hintElement.classList.toggle('clicked');
  }, function(err) {
    console.error('Could not copy text: ', err);
  });
}

function showHide(id,type){   
    if (id){ 
        if (document.getElementById(id).style.display == "none")
            document.getElementById(id).style.display = type;
        else 
            document.getElementById(id).style.display = 'none';    
    }
}
