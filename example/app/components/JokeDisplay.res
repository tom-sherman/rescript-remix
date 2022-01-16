@react.component
let make = (~joke: Model.Jokes.t, ~isOwner: bool, ~canDelete: option<bool>=?) =>
  <div>
    <p> {"Here's your hilarious joke:"->React.string} </p>
    <p> {joke.content->React.string} </p>
    <Remix.Link to="."> {`${joke.name} Permalink`->React.string} </Remix.Link>
    {isOwner
      ? <Remix.Form method=#delete>
          <button
            type_="submit"
            className="button"
            disabled={!(canDelete->Belt.Option.getWithDefault(false))}>
            {"Delete"->React.string}
          </button>
        </Remix.Form>
      : React.null}
  </div>
