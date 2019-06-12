function getCookie(cname) {
    var name = cname + '=';
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return '';
}

$('.borrow-button').on('click', function(e) {
    e.preventDefault();

    var qrContainer = $('.sign-up-input');
    var qr = qrContainer[0].value;

    if (qr === '') {
        qrContainer.addClass('input-error');
    }

    if (qr !== '') {
        $.ajax({
            method: 'POST',
            data: JSON.stringify({
                qrCode: qr
            }),
            url: '/borrow',
            success: function(result) {
                if (result.value != -1) {
                    location.reload();
                } else {
                    alert('failure');
                }
            }
        });
    }
});

$('.return-button').on('click', function(e) {
    e.preventDefault();

    var pointContainer = $('.sign-up-input');
    var pointID = pointContainer[0].value;

    if (pointID === '') {
        pointContainer.addClass('input-error');
    }

    if (pointID !== '') {
        $.ajax({
            method: 'POST',
            data: JSON.stringify({
                pointId: pointID
            }),
            url: '/borrow/return',
            success: function(result) {
                if (result.value != -1) {
                    location.reload();
                } else {
                    alert('failure');
                }
            }
        });
    }
});

$('.sign-up-input').change(function(e) {
    if (e.target.value !== '') {
        $(e.target).removeClass('input-error');
    } else {
        $(e.target).addClass('input-error');
    }
});
