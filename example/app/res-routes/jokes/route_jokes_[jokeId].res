// meta function

type loaderData = {joke: Model.Jokes.t, isOwner: bool}

// loader
let loader: Remix.loaderFunctionForResponse = ({request, params}) => {
  let jokeId = params->Js.Dict.unsafeGet("jokeId")
  Promise.all2((request->Session.getUserId, jokeId->Model.Jokes.getById))->Promise.then(((
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
      RemixHelpers.rejectWithResponse(
        Webapi.Fetch.Response.makeWithInit(
          "What a joke! Not found.",
          Webapi.Fetch.ResponseInit.make(~status=404, ()),
        ),
      )
    }
  })
}

// headers

// action

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

// error boundary
