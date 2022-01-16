%%raw(`import stylesUrl from "../styles/login.css"`)

let meta = () =>
  {"title": "Remix Jokes | Login", "description": "Login to submit your own jokes to Remix Jokes!"}

let links = () => [{"rel": "stylesheet", "href": %raw(`stylesUrl`)}]

let headers = () =>
  {
    "Cache-Control": `public, max-age=${(60 * 10)->Js.Int.toString}, s-maxage=${(60 * 60 * 24 * 30)
        ->Js.Int.toString}`,
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

// action data
type fieldErrors = {username: option<string>, password: option<string>}
type fields = {loginType: string, username: string, password: string}
type actionData = {
  formError: option<string>,
  fieldErrors: option<fieldErrors>,
  fields: option<fields>,
}

let getFormValue = (formData: Webapi.FormData.t, fieldName: string): option<string> => {
  formData
  ->Webapi.Fetch.FormData.get(fieldName)
  ->Belt.Option.flatMap(value =>
    switch value->Webapi.Fetch.FormData.EntryValue.classify {
    | #String(value) => Some(value)
    | _ => None
    }
  )
}

let action: Remix.actionFunctionForResponse = ({request}) => {
  request
  ->Webapi.Fetch.Request.formData
  ->Promise.then(formData => {
    let loginType = getFormValue(formData, "loginType")
    let username = getFormValue(formData, "username")
    let password = getFormValue(formData, "password")

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
          {formError: None, fieldErrors: Some(fieldErrors), fields: Some(fields)}
          ->Remix.json
          ->Promise.resolve
        } else {
          switch loginType {
          | "login" =>
            Session.login({username: username, password: password})->Promise.then(user =>
              switch user {
              | Some(user) => Session.createUserSession(user.username, "/jokes")
              | None =>
                {
                  formError: Some("Username/Password combination is incorrect"),
                  fieldErrors: None,
                  fields: Some(fields),
                }
                ->Remix.json
                ->Promise.resolve
              }
            )
          | _ =>
            {
              formError: Some("Login type invalid"),
              fieldErrors: None,
              fields: Some(fields),
            }
            ->Remix.json
            ->Promise.resolve
          }
        }
      }
    | _ =>
      {formError: Some("Form not submitted correctly."), fieldErrors: None, fields: None}
      ->Remix.json
      ->Promise.resolve
    }
  })
}

@react.component
let default = () => {
  open Belt.Option
  let actionData: option<actionData> = Remix.useActionData()

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
          // <input
          //   type_="text"
          //   id="username-input"
          //   name="username"
          //   defaultValue={actionData?.fields?.username}
          //   aria-invalid={Boolean(actionData?.fieldErrors?.username)}
          //   aria-describedby={
          //     actionData?.fieldErrors?.username ? "username-error" : undefined
          //   }
          // />
          <input
            type_="text"
            id="username-input"
            name="username"
            defaultValue=?{actionData->flatMap(data => data.fields)->map(fields => fields.username)}
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
          // <input
          //   id="password-input"
          //   name="password"
          //   defaultValue={actionData?.fields?.password}
          //   type_="password"
          //   aria-invalid={Boolean(actionData?.fieldErrors?.password)}
          //   aria-describedby={
          //     actionData?.fieldErrors?.password ? "password-error" : undefined
          //   }
          // />
          <input id="password-input" name="password" type_="password" />
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
