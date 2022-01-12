type loaderData = {randomJoke: Model.Jokes.t}

external responseAsExn: Webapi.Fetch.Response.t => 'a = "%identity"
let rejectWithResponse = (response: Webapi.Fetch.Response.t): Promise.t<'a> => {
  Promise.reject(response->responseAsExn)
}

let loader = (): Promise.t<loaderData> => {
  Model.Jokes.getRandom()->Promise.then(joke =>
    switch joke {
    | Some(joke) => Promise.resolve({randomJoke: joke})
    | None =>
      rejectWithResponse(
        Webapi.Fetch.Response.makeWithInit(
          "No random joke found",
          Webapi.Fetch.ResponseInit.make(~status=404, ()),
        ),
      )
    }
  )
}

@react.component
let default = () => {
  let data: loaderData = Remix.useLoaderData()

  <div>
    <p> {"Here's a random joke:"->React.string} </p>
    <p> {data.randomJoke.content->React.string} </p>
    <Remix.Link to={data.randomJoke.id}>
      {`${data.randomJoke.name} Permalink`->React.string}
    </Remix.Link>
  </div>
}

let catchBoundary = () => {
  let caught = Remix.useCatch()
  Js.log(caught)

  if caught->Webapi.Fetch.Response.status == 404 {
    <div className="error-container">
      <p> {"There are no jokes to display."->React.string} </p>
      <Remix.Link to="new"> {"Add your own"->React.string} </Remix.Link>
    </div>
  } else {
    Js.Exn.raiseError(
      `Unexpected caught response with status: ${caught
        ->Webapi.Fetch.Response.status
        ->Js.Int.toString}`,
    )
  }
}
// %%raw(`export const CatchBoundary = Route_jokes_index$catchBoundary`)
%%raw(`export const CatchBoundary = catchBoundary`)
