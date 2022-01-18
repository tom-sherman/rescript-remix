module Jokes = {
  type t = {id: string, jokesterId: string, name: string, content: string}
  let jokes: ref<array<t>> = ref([
    {
      id: "a",
      jokesterId: "drew",
      name: "Road worker",
      content: `I never wanted to believe that my Dad was stealing from his job as a road worker. But when I got home, all the signs were there.`,
    },
    {
      id: "b",
      jokesterId: "drew",
      name: "Frisbee",
      content: `I was wondering why the frisbee was getting bigger, then it hit me.`,
    },
    {
      id: "c",
      jokesterId: "drew",
      name: "Trees",
      content: `Why do trees seem suspicious on sunny days? Dunno, they're just a bit shady.`,
    },
    {
      id: "d",
      jokesterId: "drew",
      name: "Skeletons",
      content: `Why don't skeletons ride roller coasters? They don't have the stomach for it.`,
    },
    {
      id: "e",
      jokesterId: "drew",
      name: "Hippos",
      content: `Why don't you find hippopotamuses hiding in trees? They're really good at it.`,
    },
    {
      id: "f",
      jokesterId: "drew",
      name: "Dinner",
      content: `What did one plate say to the other plate? Dinner is on me!`,
    },
    {
      id: "g",
      jokesterId: "drew",
      name: "Elevator",
      content: `My first time using an elevator was an uplifting experience. The second time let me down.`,
    },
  ])

  let getById = (jokeId: string): Promise.t<option<t>> =>
    jokes.contents->Js.Array2.find(joke => joke.id == jokeId)->Promise.resolve
  let getAll = () => jokes.contents->Promise.resolve
  let getLatest = () => jokes.contents->Belt.Array.slice(~offset=0, ~len=5)->Promise.resolve
  let getRandom = () =>
    (Js.Math.random() *. jokes.contents->Js.Array2.length->Belt.Int.toFloat)
    ->Js.Math.floor_int
    ->Belt.Array.get(jokes.contents, _)
    ->Js.Promise.resolve
  let create = (joke: t) => {
    let newJokes = jokes.contents->Js.Array2.concat([joke])
    jokes := newJokes
    joke->Promise.resolve
  }
  let deleteById = (jokeId: string): Promise.t<unit> => {
    let newJokes = jokes.contents->Js.Array2.filter(joke => joke.id != jokeId)
    jokes := newJokes
    Promise.resolve()
  }
}

module Users = {
  type t = {username: string, password: string}
  let users: array<t> = [
    {
      username: "drew",
      password: "password",
    },
  ]

  let getByUsername = (username: string): Promise.t<option<t>> =>
    users->Js.Array2.find(user => user.username == username)->Promise.resolve
  let create = (user: t): Js.Promise.t<unit> =>
    user->Js.Array2.push(users, _)->ignore->Promise.resolve
}
