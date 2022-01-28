%%raw(`import stylesUrl from "../styles/login.css"`)

let meta: Remix.metaFunction = _ =>
  Remix.HtmlMetaDescriptor.make({
    "title": "Remix Jokes | Login",
    "description": "Login to submit your own jokes to Remix Jokes!",
  })

let links: Remix.linksFunction = () => [
  Remix.HtmlLinkDescriptor.make(~rel=#stylesheet, ~href=%raw(`stylesUrl`), ()),
]

let headers: Remix.headersFunction = _ => {
  open Webapi.Fetch

  Headers.makeWithInit(
    HeadersInit.make({
      "Cache-Control": `public, max-age=${(60 * 10)->Js.Int.toString}, s-maxage=${(60 *
        60 *
        24 * 30)->Js.Int.toString}`,
    }),
  )
}

let validateUsername = (username: string) =>
  if username->Js.String2.length < 3 {
    Some("Usernames must be at least 3 characters long")
  } else {
    None
  }

let validatePassword = (password: string) =>
  if password->Js.String2.length < 6 {
    Some("Passwords must be at least 6 characters long")
  } else {
    None
  }

@decco
type fieldErrors = {username: option<string>, password: option<string>}
@decco
type fields = {loginType: string, username: string, password: string}
@decco
type actionData = {
  formError: option<string>,
  fieldErrors: option<fieldErrors>,
  fields: option<fields>,
}
let makeActionData = (~formError=?, ~fieldErrors=?, ~fields=?, ()): actionData => {
  formError: formError,
  fieldErrors: fieldErrors,
  fields: fields,
}

let action: Remix.actionFunction = ({request}) => {
  request
  ->Webapi.Fetch.Request.formData
  ->Promise.then(formData => {
    let loginType = RemixHelpers.FormData.getStringValue(formData, "loginType")
    let username = RemixHelpers.FormData.getStringValue(formData, "username")
    let password = RemixHelpers.FormData.getStringValue(formData, "password")

    switch (loginType, username, password) {
    | (Some(loginType), Some(username), Some(password)) => {
        let fields = {
          loginType: loginType,
          username: username,
          password: password,
        }

        let fieldErrors = {
          username: username->validateUsername,
          password: password->validatePassword,
        }

        if fieldErrors != {username: None, password: None} {
          makeActionData(~fieldErrors, ~fields, ())->actionData_encode->Remix.json->Promise.resolve
        } else {
          switch loginType {
          | "login" =>
            {username: username, password: password}
            ->Session.login
            ->Promise.then(user =>
              switch user {
              | Some(user) => Session.createUserSession(user.username, "/jokes")
              | None =>
                makeActionData(~formError="Username/Password combination is incorrect", ~fields, ())
                ->actionData_encode
                ->Remix.json
                ->Promise.resolve
              }
            )
          | "register" =>
            Db.Users.getByUsername(username)->Promise.then(existingUser => {
              switch existingUser {
              | Some(_) =>
                makeActionData(
                  ~formError=`User with username ${username} already exists`,
                  ~fields,
                  (),
                )
                ->actionData_encode
                ->Remix.json
                ->Promise.resolve
              | None =>
                {username: username, password: password}
                ->Session.register
                ->Promise.then(_ => {
                  Session.createUserSession(username, "/jokes")
                })
              }
            })
          | _ =>
            makeActionData(~formError="Login type invalid", ~fields, ())
            ->actionData_encode
            ->Remix.json
            ->Promise.resolve
          }
        }
      }
    | _ =>
      makeActionData(~formError="Form not submitted correctly.", ())
      ->actionData_encode
      ->Remix.json
      ->Promise.resolve
    }
  })
}

@react.component
let default = () => {
  open Belt.Option
  let actionData =
    Remix.useActionData()->Belt.Option.map(actionData =>
      actionData->actionData_decode->Belt.Result.getExn
    )

  <div className="container">
    <div className="content light">
      <h1> {"Login"->React.string} </h1>
      // <Form
      //   method="post"
      //   aria-describedby={
      //     actionData?.formError ? "form-error-message" : undefined
      //   }
      // >
      <Remix.Form method=#post>
        <fieldset>
          <legend className="sr-only"> {"Login or Register?"->React.string} </legend>
          <label>
            <input
              type_="radio"
              name="loginType"
              value="login"
              defaultChecked={
                let loginType =
                  actionData->flatMap(data => data.fields)->map(fields => fields.loginType)
                loginType == None || loginType == Some("login")
              }
            />
            {" Login"->React.string}
          </label>
          <label>
            <input
              type_="radio"
              name="loginType"
              value="register"
              defaultChecked={actionData
              ->flatMap(data => data.fields)
              ->map(fields => fields.loginType) == Some("register")}
            />
            {" Register"->React.string}
          </label>
        </fieldset>
        <div>
          <label htmlFor="username-input"> {"Username"->React.string} </label>
          <input
            type_="text"
            id="username-input"
            name="username"
            defaultValue=?{actionData->flatMap(data => data.fields)->map(fields => fields.username)}
            // ariaInvalid={actionData
            // ->flatMap(data => data.fieldErrors)
            // ->flatMap(fieldErrors => fieldErrors.username)
            // ->Belt.Option.isSome}
            ariaDescribedby=?{actionData
            ->flatMap(data => data.fieldErrors)
            ->flatMap(fieldErrors => fieldErrors.username)
            ->map(_ => "username-error")}
          />
          {switch actionData
          ->flatMap(data => data.fieldErrors)
          ->flatMap(fieldErrors => fieldErrors.username) {
          | Some(usernameError) =>
            <p className="form-validation-error" role="alert" id="username-error">
              {usernameError->React.string}
            </p>
          | None => React.null
          }}
        </div>
        <div>
          <label htmlFor="password-input"> {"Password"->React.string} </label>
          <input
            type_="password"
            id="password-input"
            name="password"
            defaultValue=?{actionData->flatMap(data => data.fields)->map(fields => fields.password)}
            // ariaInvalid={actionData
            // ->flatMap(data => data.fieldErrors)
            // ->flatMap(fieldErrors => fieldErrors.password)
            // ->Belt.Option.isSome}
            ariaDescribedby=?{actionData
            ->flatMap(data => data.fieldErrors)
            ->flatMap(fieldErrors => fieldErrors.password)
            ->map(_ => "password-error")}
          />
          {switch actionData
          ->flatMap(data => data.fieldErrors)
          ->flatMap(fieldErrors => fieldErrors.password) {
          | Some(passwordError) =>
            <p className="form-validation-error" role="alert" id="password-error">
              {passwordError->React.string}
            </p>
          | None => React.null
          }}
        </div>
        <div id="form-error-message">
          {switch actionData->flatMap(data => data.formError) {
          | Some(formError) =>
            <p className="form-validation-error" role="alert"> {formError->React.string} </p>
          | None => React.null
          }}
        </div>
        <button type_="submit" className="button"> {"Submit"->React.string} </button>
      </Remix.Form>
    </div>
    <br />
    <div> <Remix.Link to="/"> {"Back home"->React.string} </Remix.Link> </div>
  </div>
}
