let init = () => {
  %raw(`global.jokes = global.jokes || [
    {
      id: "abc-123",
      jokesterId: "drew",
      name: "javascript",
      content: "Sometimes when I'm writing Javascript I want to throw up my hands and say \"this is awful!\" but I can never remember what \"this\" refers to.",
      createdAt: new Date()
    },
  ]`)->ignore
  %raw(`global.users = global.users || [{ username: "drew", passwordHash: /* "password" */ "$2b$10$1r2h5mpCHm4trowRV6zCzO86pFDFlmQXLnPqQROrxtgYPAdOaJ.32" }]`)->ignore
}

module Jokes = {
  type new_t = {jokesterId: string, name: string, content: string}
  type t = {id: string, jokesterId: string, name: string, content: string, createdAt: Js.Date.t}
  @scope("global") @val external jokes: array<t> = "jokes"

  let getById = (jokeId: string): Promise.t<option<t>> =>
    jokes->Js.Array2.find(joke => joke.id == jokeId)->Promise.resolve
  let getAll = () => jokes->Promise.resolve
  let getLatest = () => jokes->Belt.Array.slice(~offset=0, ~len=5)->Promise.resolve
  let getRandom = () =>
    (Js.Math.random() *. jokes->Js.Array2.length->Belt.Int.toFloat)
    ->Js.Math.floor_int
    ->Belt.Array.get(jokes, _)
    ->Js.Promise.resolve
  let create = (joke: new_t) => {
    let newJoke: t = {
      id: Random.int(99999)->Js.Int.toString,
      name: joke.name,
      content: joke.content,
      jokesterId: joke.jokesterId,
      createdAt: Js.Date.make(),
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
  type t = {username: string, passwordHash: string}
  @scope("global") @val external users: array<t> = "users"

  let getAll = (): Promise.t<array<t>> => users->Promise.resolve
  let getByUsername = (username: string): Promise.t<option<t>> =>
    users->Js.Array2.find(user => user.username == username)->Promise.resolve
  let create = (user: t): Js.Promise.t<unit> =>
    user->Js.Array2.push(users, _)->ignore->Promise.resolve
}
