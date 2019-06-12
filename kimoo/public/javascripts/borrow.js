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

function setCookie(key, value) {
    var expires = new Date();
    expires.setTime(expires.getTime() + 1 * 24 * 60 * 60 * 1000);
    document.cookie = key + '=' + value + ';expires=' + expires.toUTCString();
}

function uncheckOptions() {
    $('.option-container').removeClass('option-selected');
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

$('.sign-out').on('click', function(e) {
    setCookie('user-id', '');
    location.reload();
});

$('.all-bicycles').on('click', function(e) {
    location.reload();
});

$(".option:not('.all-bicycles')").on('click', function(e) {
    var attribute = $(e.target).data('attr');

    uncheckOptions();
    if ($(e.target).hasClass('option-name')) {
        $(e.target.parentNode).addClass('option-selected');
    } else {
        $(e.target).addClass('option-selected');
    }

    if (attribute) {
        if (attribute == 'price_history') {
            var container = $('.content-list')[0];
            container.innerHTML = '';
            $('.feed-title')[0].innerHTML = e.target.innerText;
            container.innerHTML +=
                '<form class="padded-container price-history">' +
                '<input class="sign-up-input startDate" type="date" name="startDate" placeholder="Start Date">' +
                '<input class="sign-up-input endDate" type="date" name="endDate" placeholder="End Date">' +
                '<button class="sign-up-button price-history" onclick="priceHistory(event)">Submit</button>' +
                '</form>';
        } else {
            $(".overlay:not('.pop-up')").removeClass('d-none');
            $.ajax({
                method: 'GET',
                headers: {
                    accept: 'application/json',
                    'content-type': 'application/x-www-form-urlencoded'
                },
                url: 'https://localhost:5001/api/admin/bicycles/' + attribute,
                success: function(result) {
                    $(".overlay:not('.pop-up')").addClass('d-none');
                    var container = $('.content-list')[0];
                    container.innerHTML = '';
                    $('.feed-title')[0].innerHTML = e.target.innerText;

                    for (var i = 0; i < 200; i++) {
                        if (attribute == 'overdue') {
                            container.innerHTML +=
                                '<div class="article">' +
                                '<div class="article-header">' +
                                '<div class="article-title" id="' +
                                result[i].bicycle_id +
                                '">Borrower: ' +
                                result[i].borrowBy +
                                '</div>' +
                                '</div>' +
                                '<div class="article-footer">' +
                                '<div class="tag-list">' +
                                '<div class="tag-label article-tag-label">Register date: ' +
                                result[i].registeR_DATE.split('T')[0] +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '</div>';
                        } else if (
                            attribute == 'load_old' ||
                            'load_maintainance' == attribute
                        ) {
                            container.innerHTML +=
                                '<div class="article" onclick="popUp(this)">' +
                                '<div class="article-header">' +
                                '<div class="article-title" id="' +
                                result[i].bicycle_id +
                                '">' +
                                result[i].type_issue +
                                '</div>' +
                                '<div class="popularity-score">Bicycle ID: ' +
                                result[i].bicycle_id +
                                '</div>' +
                                '</div>' +
                                '<div class="article-content">' +
                                result[i].description +
                                '</div>' +
                                '<div class="article-footer">' +
                                '<div class="tag-list">' +
                                (result[i].severity == 'low'
                                    ? '<div class="tag-label article-tag-label">' +
                                      result[i].severity +
                                      '</div>'
                                    : '') +
                                (result[i].severity == 'major'
                                    ? '<div class="tag-label article-tag-label major">' +
                                      result[i].severity +
                                      '</div>'
                                    : '') +
                                (result[i].severity == 'critical'
                                    ? '<div class="tag-label article-tag-label red">' +
                                      result[i].severity +
                                      '</div>'
                                    : '') +
                                (result[i].severity == 'medium'
                                    ? '<div class="tag-label article-tag-label orange">' +
                                      result[i].severity +
                                      '</div>'
                                    : '') +
                                '<div class="tag-label article-tag-label">' +
                                result[i].registration_date.split('T')[0] +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '</div>';
                        } else {
                            container.innerHTML +=
                                '<div class="article" onclick="popUp(this)">' +
                                '<div class="article-header">' +
                                '<div class="article-title" id="' +
                                result[i].id +
                                '">ID: ' +
                                result[i].id +
                                '</div>' +
                                (!(attribute == 'borrowed')
                                    ? '<div class="popularity-score">Pickup Point ID: ' +
                                      result[i].poinT_ID +
                                      '</div>'
                                    : '') +
                                '</div>' +
                                '<div class="article-footer">' +
                                '<div class="tag-list">' +
                                (attribute == 'borrowed'
                                    ? '<div class="tag-label article-tag-label blue">' +
                                      attribute +
                                      '</div>'
                                    : '') +
                                (attribute == 'broken'
                                    ? '<div class="tag-label article-tag-label red">' +
                                      attribute +
                                      '</div>'
                                    : '') +
                                (attribute == 'available'
                                    ? '<div class="tag-label article-tag-label">' +
                                      attribute +
                                      '</div>'
                                    : '') +
                                '<div class="tag-label article-tag-label">' +
                                result[i].registeR_DATE.split('T')[0] +
                                '</div>' +
                                '</div>' +
                                '</div>' +
                                '</div>';
                        }
                    }
                }
            });
        }
    } else {
        $(".overlay:not('.pop-up')").removeClass('d-none');
        $.ajax({
            method: 'GET',
            headers: {
                accept: 'application/json',
                'content-type': 'application/x-www-form-urlencoded'
            },
            url: 'https://localhost:5001/api/admin/issues',
            success: function(result) {
                $(".overlay:not('.pop-up')").addClass('d-none');
                var container = $('.content-list')[0];
                container.innerHTML = '';
                $('.feed-title')[0].innerHTML = e.target.innerText;

                for (var i = 0; i < 200; i++) {
                    container.innerHTML +=
                        '<div class="article" onclick="popUp(this)">' +
                        '<div class="article-header">' +
                        '<div class="article-title" id="' +
                        result[i].bicycle_id +
                        '">' +
                        result[i].type_issue +
                        '</div>' +
                        '<div class="popularity-score">Bicycle ID: ' +
                        result[i].bicycle_id +
                        '</div>' +
                        '</div>' +
                        '<div class="article-content">' +
                        result[i].description +
                        '</div>' +
                        '<div class="article-footer">' +
                        '<div class="tag-list">' +
                        (result[i].severity == 'low'
                            ? '<div class="tag-label article-tag-label">' +
                              result[i].severity +
                              '</div>'
                            : '') +
                        (result[i].severity == 'major'
                            ? '<div class="tag-label article-tag-label major">' +
                              result[i].severity +
                              '</div>'
                            : '') +
                        (result[i].severity == 'critical'
                            ? '<div class="tag-label article-tag-label red">' +
                              result[i].severity +
                              '</div>'
                            : '') +
                        (result[i].severity == 'medium'
                            ? '<div class="tag-label article-tag-label orange">' +
                              result[i].severity +
                              '</div>'
                            : '') +
                        '<div class="tag-label article-tag-label">' +
                        result[i].registration_date.split('T')[0] +
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                }
            },
            error: function(err) {
                console.log(err);
            }
        });
    }
});

function popUp(element) {
    var content = '<div class="issues">';
    var id = $(element).find('.article-title')[0].id;

    $.ajax({
        method: 'GET',
        headers: {
            accept: 'application/json',
            'content-type': 'application/x-www-form-urlencoded'
        },
        url: 'https://localhost:5001/api/admin/bicycles/issues?bicycleId=' + id,
        success: function(result) {
            $(".overlay:not('.pop-up')").addClass('d-none');

            for (var i = 0; i < result.length; i++) {
                content +=
                    '<div class="article issue-article">' +
                    '<div class="article-header">' +
                    '<div class="article-title" id="' +
                    result[i].type_issue +
                    '">' +
                    result[i].type_issue +
                    '</div>' +
                    '<div class="popularity-score">Borrow ID: ' +
                    result[i].borrow_id +
                    '</div>' +
                    '</div>' +
                    '<div class="article-content">' +
                    result[i].description +
                    '</div>' +
                    '<div class="article-footer">' +
                    '<div class="tag-list">' +
                    (result[i].severity == 'low'
                        ? '<div class="tag-label article-tag-label">' +
                          result[i].severity +
                          '</div>'
                        : '') +
                    (result[i].severity == 'critical'
                        ? '<div class="tag-label article-tag-label red">' +
                          result[i].severity +
                          '</div>'
                        : '') +
                    (result[i].severity == 'medium'
                        ? '<div class="tag-label article-tag-label orange">' +
                          result[i].severity +
                          '</div>'
                        : '') +
                    '<div class="tag-label article-tag-label">' +
                    result[i].registration_date.split('T')[0] +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }

            if (!result.length) {
                content +=
                    '<div class="article issue-article">' +
                    '<div class="article-header">' +
                    '<div class="article-title">' +
                    'No issues reported yet!' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }

            content += '</div>';
            showPopUp(content);
        },
        error: function(err) {
            console.log(err);
        }
    });
}

function showPopUp(content) {
    var popUp = $('.pop-up')[0],
        body = document.getElementsByTagName('body')[0],
        container = $('.pop-up-wrapper')[0],
        exitButton =
            '<span class="exit-form" onclick="exitForm()">' +
            '<i class="fas fa-times"></i>' +
            '</span>';

    container.innerHTML = content + exitButton;
    popUp.classList.remove('d-none');
    body.style.overflow = 'hidden';
}

function exitForm() {
    var form = $('.pop-up')[0],
        body = document.getElementsByTagName('body')[0];

    form.classList.add('d-none');
    body.style.overflow = 'auto';
}

function priceHistory(event) {
    event.preventDefault();

    var startDate = $('.startDate')[0].value;
    var endDate = $('.endDate')[0].value;

    if (startDate == '' || endDate == '') {
        $('.sign-up-input').addClass('input-error');
    } else {
        $(".overlay:not('.pop-up')").removeClass('d-none');
        $.ajax({
            method: 'GET',
            headers: {
                accept: 'application/json',
                'content-type': 'application/x-www-form-urlencoded'
            },
            url:
                'https://localhost:5001/api/admin/prices/history?startDate=' +
                startDate +
                '&endDate=' +
                endDate,
            success: function(result) {
                $(".overlay:not('.pop-up')").addClass('d-none');
                var container = $('.content-list')[0];
                container.innerHTML = '';

                for (var i = 0; i < result.length; i++) {
                    container.innerHTML +=
                        '<div class="article price-history-card">' +
                        '<div class="article-header">' +
                        '<div class="article-title"> Start Date: ' +
                        result[i].start_date.split('T')[0] +
                        '</div>' +
                        '<div class="popularity-score">End Date: ' +
                        result[i].end_date.split('T')[0] +
                        '</div>' +
                        '</div>' +
                        '<div class="article-footer">' +
                        '<div class="tag-list">' +
                        '<div class="tag-label article-tag-label"> Value: ' +
                        result[i].value +
                        '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                }

                if (!result.length) {
                    container.innerHTML +=
                        '<div class="article issue-article">' +
                        '<div class="article-header">' +
                        '<div class="article-title">' +
                        'The history is empty! Please select another interval.' +
                        '</div>' +
                        '</div>' +
                        '</div>';
                }
            }
        });
    }
}

$('.fa-history').on('click', function(e) {
    $(".overlay:not('.pop-up')").removeClass('d-none');
    var content =
        '<div class="issues">';

    $.ajax({
        method: 'GET',
        headers: {
            accept: 'application/json',
            'content-type': 'application/x-www-form-urlencoded'
        },
        url:
            'https://localhost:5001/api/admin/user/borrow_history?userId=' +
            getCookie('user-id'),
        success: function(result) {
            $(".overlay:not('.pop-up')").addClass('d-none');

            for (var i = 0; i < result.length; i++) {
                content +=
                    '<div class="article issue-article">' +
                    '<div class="article-header">' +
                    '<div class="article-title" id="' +
                    result[i].bicyclE_ID +
                    '"> Bicycle ID: ' +
                    result[i].bicyclE_ID +
                    '</div>' +
                    '</div>' +
                    '<div class="article-content"> Price: ' +
                    result[i].price +
                    '</div>' +
                    '<div class="article-footer">' +
                    '<div class="tag-list">' +
                    '<div class="tag-label article-tag-label">Start Date: ' +
                    result[i].borroW_DATE.split('T')[0] +
                    '</div>' +
                    '<div class="tag-label article-tag-label">End Date: ' +
                    result[i].enD_DATE.split('T')[0] +
                    '</div>' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }

            if (!result.length) {
                content +=
                    '<div class="article issue-article">' +
                    '<div class="article-header">' +
                    '<div class="article-title">' +
                    'No issues reported yet!' +
                    '</div>' +
                    '</div>' +
                    '</div>';
            }

            content += '</div>';
            showPopUp(content);
        }
    });
});
