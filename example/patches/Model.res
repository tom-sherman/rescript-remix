module Jokes = {
  type t = {id: string, jokesterId: string, name: string, content: string}
  let jokes: array<t> = [// {
  //   id: "a",
  //   jokesterId: "z",
  //   name: "Road worker",
  //   content: `I never wanted to believe that my Dad was stealing from his job as a road worker. But when I got home, all the signs were there.`,
  // },
  // {
  //   id: "b",
  //   jokesterId: "z",
  //   name: "Frisbee",
  //   content: `I was wondering why the frisbee was getting bigger, then it hit me.`,
  // },
  // {
  //   id: "c",
  //   jokesterId: "z",
  //   name: "Trees",
  //   content: `Why do trees seem suspicious on sunny days? Dunno, they're just a bit shady.`,
  // },
  // {
  //   id: "d",
  //   jokesterId: "z",
  //   name: "Skeletons",
  //   content: `Why don't skeletons ride roller coasters? They don't have the stomach for it.`,
  // },
  // {
  //   id: "e",
  //   jokesterId: "z",
  //   name: "Hippos",
  //   content: `Why don't you find hippopotamuses hiding in trees? They're really good at it.`,
  // },
  // {
  //   id: "f",
  //   jokesterId: "z",
  //   name: "Dinner",
  //   content: `What did one plate say to the other plate? Dinner is on me!`,
  // },
  // {
  //   id: "g",
  //   jokesterId: "z",
  //   name: "Elevator",
  //   content: `My first time using an elevator was an uplifting experience. The second time let me down.`,
  // },
  ]

  let getAll = () => jokes->Promise.resolve
  let getLatest = () => jokes->Belt.Array.slice(~offset=0, ~len=5)->Promise.resolve
  let getRandom = () =>
    (Js.Math.random() *. jokes->Js.Array2.length->Belt.Int.toFloat)
    ->Js.Math.floor_int
    ->Belt.Array.get(jokes, _)
    ->Js.Promise.resolve
}
