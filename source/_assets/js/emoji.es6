//= require twemoji/2/twemoji.min

(() => {
  function supportsEmoji() {
    if (!document.createElement("canvas").getContext) {
      return
    }

    context = document.createElement("canvas").getContext("2d");
    if (typeof context.fillText != "function") {
      return
    }

    smile = String.fromCodePoint(0x1F604);
    context.textBaseline = "top";
    context.font = "32px Arial";
    context.fillText(smile, 0, 0);
    val = context.getImageData(16, 16, 1, 1)
    return val.data[0] !== 0
  }

  if (!supportsEmoji()) {
    document.querySelectorAll("p,li,span,a").forEach((e) => {
      twemoji.parse(e, (i, o, v) => {
        return "/assets/twemoji/" + i + ".svg";
      });
    });
  }
})();