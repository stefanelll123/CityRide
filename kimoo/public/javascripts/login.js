$(".sign-up-button").on("click", function(e) {
  e.preventDefault();

  var emailContainer = $(".email-input");
  var passwordContainer = $(".password-input");
  var email = emailContainer[0].value;
  var password = passwordContainer[0].value;

  if (email === "") {
    emailContainer.addClass("input-error");
  }

  if (password === "") {
    passwordContainer.addClass("input-error");
  }

  if (email !== "" && password !== "") {
    $.ajax({
      method: "POST",
      data: JSON.stringify({
        email: email,
        password: password
      }),
      url: "/check-login",
      success: function(result) {
        if (result.value == -1) {
          emailContainer.addClass("input-error");
          passwordContainer.addClass("input-error");

          return;
        }

        document.cookie = "user-id=" + result.value;
        document.location.href = "/";
      }
    });
  }
});
