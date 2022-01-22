type loaderData = {joke: Db.Jokes.t, isOwner: bool}

let meta: Remix.metaFunction<loaderData> = ({data}) => {
  switch data {
  | Some(data) =>
    Remix.HtmlMetaDescriptor.make({
      "title": `${data.joke.name} joke`,
      "description": `Enjoy the ${data.joke.name} joke and much more`,
    })
  | None =>
    Remix.HtmlMetaDescriptor.make({
      "title": "No joke",
      "description": "No joke found",
    })
  }
}

let loader: Remix.loaderFunctionForResponse = ({request, params}) => {
  let jokeId = params->Js.Dict.unsafeGet("jokeId")
  Promise.all2((request->Session.getUserId, jokeId->Db.Jokes.getById))->Promise.then(((
    userId,
    joke,
  )) => {
    switch joke {
    | Some(joke) =>
      Remix.jsonWithInit(
        {"joke": joke, "isOwner": userId == Some(joke.jokesterId)},
        Webapi.Fetch.ResponseInit.make(
          ~headers=Webapi.Fetch.HeadersInit.make({
            "Cache-Control": `public, max-age=${(60 * 5)->Js.Int.toString}, s-maxage=${(60 *
              60 * 24)->Js.Int.toString}`,
            "Vary": "Cookie",
          }),
          (),
        ),
      )->Promise.resolve
    | None =>
      RemixHelpers.Promise.rejectResponse(
        Webapi.Fetch.Response.makeWithInit(
          "What a joke! Not found.",
          Webapi.Fetch.ResponseInit.make(~status=404, ()),
        ),
      )
    }
  })
}

let headers: Remix.headersFunction = ({loaderHeaders}) =>
  Webapi.Fetch.Headers.makeWithInit(
    Webapi.Fetch.HeadersInit.make({
      "Cache-Control": loaderHeaders
      ->Webapi.Fetch.Headers.get("Cache-Control")
      ->Belt.Option.getWithDefault(""),
      "Vary": loaderHeaders->Webapi.Fetch.Headers.get("Vary")->Belt.Option.getWithDefault(""),
    }),
  )

let action: Remix.actionFunctionForResponse = ({request, params}) => {
  let method = request->Webapi.Fetch.Request.method_
  switch method {
  | Delete => {
      let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getUnsafe
      Promise.all2((request->Session.requireUserId, jokeId->Db.Jokes.getById))->Promise.then(((
        userId,
        joke,
      )) => {
        switch joke {
        | None =>
          RemixHelpers.Promise.rejectResponse(
            Webapi.Fetch.Response.makeWithInit(
              "Can't delete what does not exist",
              Webapi.Fetch.ResponseInit.make(~status=404, ()),
            ),
          )
        | Some(joke) =>
          if joke.jokesterId != userId {
            RemixHelpers.Promise.rejectResponse(
              Webapi.Fetch.Response.makeWithInit(
                "Pssh, nice try. That's not your joke",
                Webapi.Fetch.ResponseInit.make(~status=401, ()),
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
}

@react.component
let default = () => {
  let data: loaderData = Remix.useLoaderData()

  <JokeDisplay joke={data.joke} isOwner={data.isOwner} />
}

let catchBoundary: Remix.catchBoundaryComponent = () => {
  let caught = Remix.useCatch()
  let params = Remix.useParams()

  let status = caught->Webapi.Fetch.Response.status

  switch status {
  | 404 =>
    <div className="error-container">
      {`Huh? What the heck is ${params->Js.Dict.unsafeGet("jokeId")}?`->React.string}
    </div>
  | 401 =>
    <div className="error-container">
      {`Sorry, but ${params->Js.Dict.unsafeGet("jokeId")} is not your joke.`->React.string}
    </div>
  | _ => Js.Exn.raiseError(`Unhandled error: ${status->Js.Int.toString}`)
  }
}
%%raw(`export const CatchBoundary = catchBoundary`)

let errorBoundary: Remix.errorBoundaryComponent = ({error}) => {
  Js.log(error)
  let params = Remix.useParams()
  let jokeId = params->Js.Dict.get("jokeId")->Belt.Option.getUnsafe

  <div> {`There was an error loading joke by the id ${jokeId}. Sorry.`->React.string} </div>
}
%%raw(`export const ErrorBoundary = errorBoundary`)
