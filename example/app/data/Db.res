%%raw(`global.jokes = global.jokes || [
    {
      id: "abc-123",
      jokesterId: "drew",
      name: "javascript",
      content: "Sometimes when I'm writing Javascript I want to throw up my hands and say \"this is stupid!\" but I can never remember what \"this\" refers to.",
    },
  ]`)

module Jokes = {
  type new_t = {jokesterId: string, name: string, content: string}
  type t = {id: string, jokesterId: string, name: string, content: string}
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
      id: (Js.Math.random() *. 99999.)->Js.Math.floor_int->Js.Int.toString,
      name: joke.name,
      content: joke.content,
      jokesterId: joke.jokesterId,
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

%%raw(`global.users = global.users || [{ username: "drew", password: "password" }]`)

module Users = {
  type t = {username: string, password: string}
  @scope("global") @val external users: array<t> = "users"

  let getByUsername = (username: string): Promise.t<option<t>> =>
    users->Js.Array2.find(user => user.username == username)->Promise.resolve
  let create = (user: t): Js.Promise.t<unit> =>
    user->Js.Array2.push(users, _)->ignore->Promise.resolve
}
