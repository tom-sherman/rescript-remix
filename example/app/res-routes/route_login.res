%%raw(`import stylesUrl from "../styles/login.css"`)

let meta = () =>
  {"title": "Remix Jokes | Login", "description": "Login to submit your own jokes to Remix Jokes!"}

let links = () => {"rel": "stylesheet", "href": %raw(`stylesUrl`)}

let headers = () =>
  {
    "Cache-Control": `public, max-age=${(60 * 10)->Js.Int.toString}, s-maxage=${(60 * 60 * 24 * 30)
        ->Js.Int.toString}`,
  }

// validateUsername

// validatePassword

// action data
type fieldErrors = {username: option<string>, password: option<string>}
type fields = {loginType: option<string>, username: option<string>, password: option<string>}
type actionData = {
  formError: option<string>,
  fieldErrors: option<fieldErrors>,
  fields: option<fields>,
}

// action
let action: Remix.actionFunctionForResponse = ({request}) => {
  request
  ->Webapi.Fetch.Request.formData
  ->Promise.thenResolve(data => {
    let formData = data->Webapi.Fetch.FormData.getAll
    Js.log(formData)
  })
  ->Promise.thenResolve(_ => Webapi.Fetch.Response.make("Ok"))
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
                  actionData->flatMap(data => data.fields)->flatMap(fields => fields.loginType)
                loginType == None || loginType == Some("login")
              }
            />
            {" Login"->React.string}
          </label>
          <label>
            // <input
            //   type_="radio"
            //   name="loginType"
            //   value="register"
            //   defaultChecked={actionData?.fields?.loginType === "register"}
            // />{" Register"->React.string}
            <input
              type_="radio"
              name="loginType"
              value="register"
              defaultChecked={actionData
              ->flatMap(data => data.fields)
              ->flatMap(fields => fields.loginType) == Some("register")}
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
          <input type_="text" id="username-input" name="username" />
          // {actionData?.fieldErrors?.username ? (
          //   <p
          //     className="form-validation-error"
          //     role="alert"
          //     id="username-error"
          //   >
          //     {actionData.fieldErrors.username}
          //   </p>
          // ) : null}
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
          // {actionData?.fieldErrors?.password ? (
          //   <p
          //     className="form-validation-error"
          //     role="alert"
          //     id="password-error"
          //   >
          //     {actionData.fieldErrors.password}
          //   </p>
          // ) : null}
        </div>
        <div id="form-error-message" />
        <button type_="submit" className="button"> {"Submit"->React.string} </button>
      </Remix.Form>
    </div>
    <br />
    <div> <Remix.Link to="/"> {"Back home"->React.string} </Remix.Link> </div>
  </div>
}
