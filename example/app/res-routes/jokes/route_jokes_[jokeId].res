@decco
type loaderData = {joke: Model.Joke.t, isOwner: bool}

let meta: Remix.metaFunction = ({data}) => {
  switch data {
  | Some(json) => {
      let data = json->loaderData_decode->Belt.Result.getExn
      Remix.HtmlMetaDescriptor.make({
        "title": `${data.joke.name} joke`,
        "description": `Enjoy the ${data.joke.name} joke and much more`,
      })
    }
  | None =>
    Remix.HtmlMetaDescriptor.make({
      "title": "No joke",
      "description": "No joke found",
    })
  }
}

let loader: Remix.loaderFunction = ({request, params}) => {
  open Webapi.Fetch

  let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getExn
  Promise.all2((request->Session.getUserId, jokeId->Db.Jokes.getById))->Promise.then(((
    userId,
    joke,
  )) => {
    switch joke {
    | Some(joke) =>
      Remix.jsonWithInit(
        {joke: joke, isOwner: userId == Some(joke.jokesterId)}->loaderData_encode,
        ResponseInit.make(
          ~headers=HeadersInit.make({
            "Cache-Control": `public, max-age=${(60 * 5)->Js.Int.toString}, s-maxage=${(60 *
              60 * 24)->Js.Int.toString}`,
            "Vary": "Cookie",
          }),
          (),
        ),
      )->Promise.resolve
    | None =>
      RemixHelpers.Promise.rejectResponse(
        Response.makeWithInit("What a joke! Not found.", ResponseInit.make(~status=404, ())),
      )
    }
  })
}

let headers: Remix.headersFunction = ({loaderHeaders}) => {
  open Webapi.Fetch

  Headers.makeWithInit(
    HeadersInit.make({
      "Cache-Control": loaderHeaders->Headers.get("Cache-Control")->Belt.Option.getWithDefault(""),
      "Vary": loaderHeaders->Headers.get("Vary")->Belt.Option.getWithDefault(""),
    }),
  )
}

let action: Remix.actionFunction = ({request, params}) => {
  open Webapi.Fetch

  request
  ->Request.formData
  ->Promise.thenResolve(formData =>
    formData->RemixHelpers.FormData.getStringValue("_method")->Belt.Option.getExn
  )
  ->Promise.then(method =>
    switch method {
    | "delete" => {
        let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getExn
        Promise.all2((request->Session.requireUserId, jokeId->Db.Jokes.getById))->Promise.then(((
          userId,
          joke,
        )) => {
          switch joke {
          | None =>
            RemixHelpers.Promise.rejectResponse(
              Response.makeWithInit(
                "Can't delete what does not exist",
                ResponseInit.make(~status=404, ()),
              ),
            )
          | Some(joke) =>
            if joke.jokesterId != userId {
              RemixHelpers.Promise.rejectResponse(
                Response.makeWithInit(
                  "Pssh, nice try. That's not your joke",
                  ResponseInit.make(~status=401, ()),
                ),
              )
            } else {
              Db.Jokes.deleteById(jokeId)->Promise.thenResolve(() => Remix.redirect("/jokes"))
            }
          }
        })
      }
    | _ => Js.Exn.raiseError(`Don't know how to handle request`)
    }
  )
}

@react.component
let default = () => {
  let data = Remix.useLoaderData()->loaderData_decode->Belt.Result.getExn

  <JokeDisplay name=data.joke.name content=data.joke.content isOwner={data.isOwner} />
}

let catchBoundary: Remix.catchBoundaryComponent = () => {
  let caught = Remix.useCatch()
  let params = Remix.useParams()

  let status = caught->Webapi.Fetch.Response.status
  let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getExn

  switch status {
  | 404 =>
    <div className="error-container"> {`Huh? What the heck is ${jokeId}?`->React.string} </div>
  | 401 =>
    <div className="error-container">
      {`Sorry, but ${jokeId} is not your joke.`->React.string}
    </div>
  | _ => Js.Exn.raiseError(`Unhandled error: ${status->Js.Int.toString}`)
  }
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = ({error}) => {
  Js.log(error)
  let params = Remix.useParams()
  let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getExn

  <div> {`There was an error loading joke by the id ${jokeId}. Sorry.`->React.string} </div>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
