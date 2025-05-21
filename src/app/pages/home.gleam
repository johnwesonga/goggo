import lustre/element.{type Element, text}
import lustre/element/html.{h1}

pub fn home() {
  h1([], [text("Homepage")])
}
