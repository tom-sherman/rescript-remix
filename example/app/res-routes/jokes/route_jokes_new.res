let loader: Remix.loaderFunction = ({request}) => {
  open Webapi.Fetch

  request
  ->Session.getUserId
  ->Promise.then(userId => {
    switch userId {
    | Some(_) => Remix.json(Js.Obj.empty())->Promise.resolve
    | None =>
      RemixHelpers.Promise.rejectResponse(
        Response.makeWithInit("Unauthorized", ResponseInit.make(~status=401, ())),
      )
    }
  })
}

let validateJokeContent = (content: string) => {
  if content->Js.String2.length < 10 {
    Some("That joke is too short")
  } else {
    None
  }
}

let validateJokeName = (name: string) => {
  if name->Js.String2.length < 2 {
    Some("That joke's name is too short")
  } else {
    None
  }
}

module ActionData = {
  @decco
  type fieldErrors = {name: option<string>, content: option<string>}
  @decco
  type fields = {name: string, content: string}
  @decco
  type t = {
    formError: option<string>,
    fieldErrors: option<fieldErrors>,
    fields: option<fields>,
  }

  let make = (~formError=?, ~fieldErrors=?, ~fields=?, ()) => {
    formError: formError,
    fieldErrors: fieldErrors,
    fields: fields,
  }
}

let action: Remix.actionFunction = ({request}) => {
  request
  ->Session.requireUserId
  ->Promise.then(userId => {
    request
    ->Webapi.Fetch.Request.formData
    ->Promise.then(formData => {
      let name = RemixHelpers.FormData.getStringValue(formData, "name")
      let content = RemixHelpers.FormData.getStringValue(formData, "content")

      switch (name, content) {
      | (Some(name), Some(content)) => {
          let fields: ActionData.fields = {
            name: name,
            content: content,
          }

          let fieldErrors: ActionData.fieldErrors = {
            name: validateJokeName(name),
            content: validateJokeContent(content),
          }

          if fieldErrors == {name: None, content: None} {
            {Db.Jokes.name: name, content: content, jokesterId: userId}
            ->Db.Jokes.create
            ->Promise.thenResolve(joke => Remix.redirect(`/jokes/${joke.id}`))
          } else {
            ActionData.make(~fieldErrors, ~fields, ())
            ->ActionData.t_encode
            ->Remix.json
            ->Promise.resolve
          }
        }
      | _ =>
        ActionData.make(~formError="Form not submitted correctly", ())
        ->ActionData.t_encode
        ->Remix.json
        ->Promise.resolve
      }
    })
  })
}

let default = () => {
  open Belt.Option

  let actionData =
    Remix.useActionData()->Belt.Option.map(actionData =>
      actionData->ActionData.t_decode->Belt.Result.getExn
    )

  <div>
    <p> {"Add your own hilarious joke"->React.string} </p>
    <Remix.Form method=#post>
      <div>
        <label>
          {"Name: "->React.string}
          <input
            type_="text"
            defaultValue={actionData
            ->flatMap(data => data.fields)
            ->map(fields => fields.name)
            ->getWithDefault("")}
            name="name"
            // aria-invalid={Boolean(actionData?.fieldErrors?.name)}
            ariaDescribedby=?{actionData
            ->flatMap(data => data.fieldErrors)
            ->flatMap(fieldErrors => fieldErrors.name)
            ->map(_ => "name-error")}
          />
        </label>
        {switch actionData
        ->flatMap(data => data.fieldErrors)
        ->flatMap(fieldErrors => fieldErrors.name) {
        | Some(nameError) =>
          <p className="form-validation-error" role="alert" id="name-error">
            {nameError->React.string}
          </p>
        | None => React.null
        }}
      </div>
      <div>
        <label>
          {"Content: "->React.string}
          <textarea
            defaultValue={actionData
            ->flatMap(data => data.fields)
            ->map(fields => fields.content)
            ->getWithDefault("")}
            name="content"
            // aria-invalid={Boolean(actionData?.fieldErrors?.content)}
            ariaDescribedby=?{actionData
            ->flatMap(data => data.fieldErrors)
            ->flatMap(fieldErrors => fieldErrors.name)
            ->map(_ => "content-error")}
          />
        </label>
        {switch actionData
        ->flatMap(data => data.fieldErrors)
        ->flatMap(fieldErrors => fieldErrors.content) {
        | Some(contentError) =>
          <p className="form-validation-error" role="alert" id="content-error">
            {contentError->React.string}
          </p>
        | None => React.null
        }}
      </div>
      <button type_="submit" className="button"> {"Add"->React.string} </button>
    </Remix.Form>
  </div>
}

let catchBoundary: Remix.catchBoundaryComponent = () => {
  let caught = Remix.useCatch()

  let status = caught->Webapi.Fetch.Response.status

  switch status {
  | 401 =>
    <div className="error-container">
      <p> {"You must be logged in to create a joke."->React.string} </p>
      <Remix.Link to="/login"> {"Login"->React.string} </Remix.Link>
    </div>
  | _ => Js.Exn.raiseError(`Unexpected caught response with status: ${status->Js.Int.toString}`)
  }
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = ({error}) => {
  Js.log(error)

  <div className="error-container">
    {"Something unexpected went wrong. Sorry about that."->React.string}
  </div>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
