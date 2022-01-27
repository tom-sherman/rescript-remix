let action: Remix.actionFunctionForResponse = ({request}) => request->Session.logout

let loader: Remix.loaderFunctionForResponse = _ => Remix.redirect("/")->Promise.resolve
