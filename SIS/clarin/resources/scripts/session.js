document.addEventListener('DOMContentLoaded', function() {
  window.onload=checkActiveRI();
});

function setSessionCookie(cookieName, cookieValue) {
    document.cookie = cookieName + '=' + cookieValue + ';path=/';
    setActiveRI(cookieValue);
    location.reload();
}

// Get session cookie value
function getSessionCookie(cookieName) {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
        const cookie = cookies[i].trim();
        if (cookie.startsWith(cookieName + '=')) {
            return cookie.substring(cookieName.length + 1);
        }
    }
    return null;
    // Cookie not found
}

function setActiveRI(riValue){
    const elements = document.querySelectorAll('[id$="RI-ID"]');
    // Loop through the selected elements
    elements.forEach(element => {
        element.classList.remove('ri-active');
    });
    
    var element = document.getElementById(riValue + '-RI-ID');
    element.classList.add('ri-active');
}

function checkActiveRI(){
    var riValue = getSessionCookie("ri");
    if (riValue == null){
        setSessionCookie("ri","CLARIN");
        /*document.cookie = 'ri=CLARIN;path=/';
        var element = document.getElementById('CLARIN-RI-ID');
        element.className += " ri-active";*/
    }
    else{
        setActiveRI(riValue);
    }
}