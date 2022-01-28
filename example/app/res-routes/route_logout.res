let action: Remix.actionFunction = ({request}) => request->Session.logout

let loader: Remix.loaderFunction = _ => Remix.redirect("/")->Promise.resolve
