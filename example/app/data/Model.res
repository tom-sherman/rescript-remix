module Joke = {
  @decco
  type t = {id: string, jokesterId: string, name: string, content: string, createdAt: float}
}

module User = {
  type t = {username: string, passwordHash: Bcrypt.hash}
}
