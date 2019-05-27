function $(something) {
    var actualString = something.substring(1);
    if (something[0] == '.') {
        return document.getElementsByClassName(actualString);
    } else if (something[0] == '#') {
        return document.getElementById(actualString);
    } else if (something[0] == '!') {
        return document.getElementsByName(actualString);
    } else {
        return null
    }
}

function showNotifications() {
    var emptyList = $('.empty')[0],
        fullList  = $('.normal-list')[0];

    emptyList.classList.add('d-none');
    fullList.classList.remove('d-none');

    if (document.body.clientWidth <= 620) {
        location.href = '#notifications';
    }
}

function addChild() {
    var content   = '<form action=\"\" method=\"\" class=\"add-child-form\">' +
                        '<input type=\"text\" id=\"childID\" name=\"child-id\" class=\"add-child primary\" placeholder=\"identificare\"/>' +
                        '<input type=\"password\" name=\"child-password\" class=\"add-child primary\" placeholder=\"parolă\"/>' +
                        '<button class=\"primary pop-up-button\" id=\"add\"> + </button>' +
                    '</form>';
    showPopUp(content);
}

function showPopUp(content) {
    var popUp       = $('.overlay')[0],
        body        = document.getElementsByTagName('body')[0],
        container   = $('.pop-up-wrapper')[0],
        exitButton  = '<span class=\"exit-form\" onclick=\"exitForm()\">' +
                        '<i class=\"fas fa-times\"></i>' +
                      '</span>';

    container.innerHTML = content + exitButton;
    popUp.classList.remove('d-none');
    body.style.overflow = 'hidden';
}

function exitForm() {
    var form = $('.overlay')[0],
        body = document.getElementsByTagName('body')[0];

    form.classList.add('d-none');
    body.style.overflow = 'auto';
}

function signOut() {
    var content =   '<div class=\"sign-out\">' +
                        '<h2>Sunteți sigur/ă ?</h2>' +
                        '<div class=\"button-wrapper\">' +
                            '<button class=\"yes primary\" onclick=\"signOutConfirm()\">Da</button>' +
                            '<button class=\"no primary\" onclick=\"exitForm()\">Nu</button>' +
                        '</div>' +
                    '</div>';
    showPopUp(content);
}

function signOutConfirm() {
    location.href = '../layouts/login.html';
}

document.addEventListener('click', function(e) {
    if (e.target.id == 'add') {
        e.preventDefault();

        var container = $('.children')[0];
        var id = $('#childID').value;
        var content = document.createElement('div');
        content.classList.add('child');
        content.innerHTML = id;

        container.prepend(content);
        exitForm();
    }
});