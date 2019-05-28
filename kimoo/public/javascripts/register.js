$('.register-button').on('click', function(e) {
    e.preventDefault();

    var isEmpty = 0;
    var containers = $('.sign-up-input');
    var object = {};

    for (let i = 0; i < containers.length; i++) {
        var container = $('.' + containers[i].classList[1]);
        object[containers[i].name] = containers[i].value;

        if (containers[i].value == '') {
            container.addClass('input-error');
            isEmpty = 1;
        }
    }

    if (!isEmpty) {
        if (object.cnp.length === 13 && object.card_number.length === 16 
            && (object.cnp[0] == 1 || object.cnp[0] == 2 || object.cnp[0] == 5 || object.cnp[0] == 6)) {
            $.ajax({
                method: 'POST',
                data: JSON.stringify(object),
                url: '/check-register',
                success: function(result) {
                    document.location.href = '/login';
                }
            });
        }
    }
});

$('.sign-up-input').change(function(e) {
    if (e.target.value !== '') {
        $(e.target).removeClass('input-error');
    } else {
        $(e.target).addClass('input-error');
    }
});

$('.cnp-input').change(function(e) {
    if (e.target.value.length !== 13) {
        $('.error-message').text('CNP should contain 13 characters');
        $('.error-message').removeClass('d-none');
        $(e.target).addClass('input-error');
    } else if (e.target.value[0] != 1 && e.target.value[0] != 2 && e.target.value[0] != 5 && e.target.value[0] != 6) {
        $('.error-message').text('CNP format not accepted');
        $('.error-message').removeClass('d-none');
        $(e.target).addClass('input-error');
    } else {
        $('.error-message').addClass('d-none');
        $(e.target).removeClass('input-error');
    }
});

$('.card-input').change(function(e) {
    if (e.target.value.length !== 16) {
        $('.error-message').text('Card number should contain 16 characters');
        $('.error-message').removeClass('d-none');
        $(e.target).addClass('input-error');
    } else {
        $('.error-message').addClass('d-none');
        $(e.target).removeClass('input-error');
    }
});