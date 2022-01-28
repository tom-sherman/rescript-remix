let init = () => {
  %raw(`global.jokes = global.jokes || [
    {
      id: "abc-123",
      jokesterId: "drew",
      name: "javascript",
      content: "Sometimes when I'm writing Javascript I want to throw up my hands and say \"this is awful!\" but I can never remember what \"this\" refers to.",
      createdAt: Date.now()
    },
    {
      id: "def-456",
      jokesterId: "drew",
      name: "batman",
      content: "console.log(new Array(5).join(\"a\"-10) + \" Batman!\")",
      createdAt: Date.now()
    },
  ]`)->ignore
  %raw(`global.users = global.users || [
    {
      username: "rescript",
      passwordHash: /* "password" */ "$2b$10$1r2h5mpCHm4trowRV6zCzO86pFDFlmQXLnPqQROrxtgYPAdOaJ.32"
    }
  ]`)->ignore
}

module Jokes = {
  type new_t = {jokesterId: string, name: string, content: string}
  @scope("global") @val external jokes: array<Model.Joke.t> = "jokes"

  let getById = (jokeId: string): Promise.t<option<Model.Joke.t>> =>
    jokes->Js.Array2.find(joke => joke.id == jokeId)->Promise.resolve
  let getAll = (): Promise.t<array<Model.Joke.t>> => jokes->Promise.resolve
  let getLatest = (): Promise.t<array<Model.Joke.t>> =>
    jokes->Belt.Array.slice(~offset=0, ~len=5)->Promise.resolve
  let getRandom = (): Promise.t<option<Model.Joke.t>> =>
    jokes->Js.Array2.length->Random.int->Belt.Array.get(jokes, _)->Promise.resolve
  let create = (joke: new_t): Promise.t<Model.Joke.t> => {
    let newJoke: Model.Joke.t = {
      id: Random.int(99999)->Js.Int.toString,
      name: joke.name,
      content: joke.content,
      jokesterId: joke.jokesterId,
      createdAt: Js.Date.now(),
    }
    jokes->Js.Array2.push(newJoke)->ignore
    newJoke->Promise.resolve
  }
  let deleteById = (jokeId: string): Promise.t<unit> => {
    let indexToRemove = jokes->Js.Array2.findIndex(joke => joke.id === jokeId)
    jokes->Js.Array2.spliceInPlace(~pos=indexToRemove, ~remove=1, ~add=[])->ignore
    Promise.resolve()
  }
}

module Users = {
  @scope("global") @val external users: array<Model.User.t> = "users"

  let getAll = (): Promise.t<array<Model.User.t>> => users->Promise.resolve
  let getByUsername = (username: string): Promise.t<option<Model.User.t>> =>
    users->Js.Array2.find(user => user.username == username)->Promise.resolve
  let create = (user: Model.User.t): Promise.t<unit> =>
    user->Js.Array2.push(users, _)->ignore->Promise.resolve
}
