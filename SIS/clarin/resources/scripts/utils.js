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

