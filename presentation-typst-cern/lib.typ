#import "@preview/touying:0.6.1": *
#import themes.simple: *

#let cern_colors = (
  blue: color.rgb("0033a0"),
  dark: color.rgb("2f2f2f"),
  light_blue: color.rgb("61c4d3"),
  orange: color.rgb("e15e32"),
  gray: color.rgb("bebecb"),
  purple: color.rgb("6e2466"),
  dark_blue: color.rgb("1c446a"),
)
#let datetime-format = "[month repr:long] [day] [year]"

#let cern_logo = image.with("figures/LogoOutline-Blue.svg", alt: "CERN logo")

#let deco-format(it) = stack(
  dir: ttb,
  line(length: 100%, stroke: .5pt + cern_colors.blue),
  v(5pt),
  text(
    size: 8.5pt,
    fill: cern_colors.blue,
    it,
  ),
)

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (int, auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
////   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (function): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (array): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = components.left-and-right(
    utils.call-or-display(self, self.store.header),
    utils.call-or-display(self, self.store.header-right),
  )
  let footer(self) = {
    // line(length: 100%, stroke: self.colors.primary + 1pt),
    deco-format(
      components.left-and-right(
        utils.call-or-display(self, self.store.footer),
        utils.call-or-display(self, self.store.footer-right),
      ),
    )
  }
  let self = utils.merge-dicts(
    self,
    config-common(datetime-format: datetime-format),
    config-page(header: header, footer: footer, margin: (
      top: 32pt,
      bottom: 17pt,
      left: 27pt,
      right: 27pt,
    )),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})


/// Centered slide for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let centered-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(self: self, ..args.named(), config: config, align(
    center + horizon,
    args.pos().sum(default: none),
  ))
})


/// Title slide for the presentation.
///
/// Example: `#title-slide[Hello, World!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let self = utils.merge-dicts(
    self,
    config-common(datetime-format: datetime-format),
    config-page(margin: (top: 8pt, bottom: 46pt, left: 27pt, right: 27pt)),
  )
  let body = {
    set align(center)

    block(cern_logo(height: 141pt))
    v(40pt)

    set text(fill: self.colors.neutral-darkest, size: 17pt)
    align(left, {
      if info.title != none {
        block(heading(
          text(info.title, size: 45pt, top-edge: .5em),
          depth: 1,
        ))
      }

      if info.subtitle != none {
        block(text(
          info.subtitle,
          size: 20pt,
          fill: self.colors.primary,
          weight: "bold",
        ))
      }

      v(1fr)

      block(text(
        {
          if info.author != none { text(info.author, weight: "bold") }
          if info.institution != none {
            ", "
            info.institution
          }
          if info.date != none {
            v(-3pt)
            utils.display-info-date(self)
          }
        },
        size: 15pt,
      ))

      // v(25pt)
    })
  }
  touying-slide(self: self, body)
})

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let new-section-slide(config: (:), ..args, body) = touying-slide-wrapper(
  self => {
    touying-slide(
      self: utils.merge-dicts(
        self,
        config-common(datetime-format: datetime-format),
        config-page(
          footer: self => {
            deco-format(
              components.left-and-right(
                utils.call-or-display(self, self.store.footer),
                utils.call-or-display(self, self.store.footer-right),
              ),
            )
          },
          margin: (top: 17pt, bottom: 17pt, left: 27pt, right: 27pt),
        ),
      ),
      ..args.named(),
      config: config,
      [
        #v(230pt)
        #text(
          55pt,
          weight: "bold",
          fill: cern_colors.blue,
          utils.display-current-heading(level: 1),
        )\ #v(.1em)
        #text(fill: cern_colors.light_blue, body)
      ],
    )
  },
)

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - background (color, auto): The background color of the slide. Default is `auto`, which means the primary color of the slides.
///
/// - foreground (color): The foreground color of the slide. Default is `white`.
#let focus-slide(
  config: (:),
  background: auto,
  foreground: white,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: if background == auto {
      self.colors.primary
    } else {
      background
    }),
  )
  set text(fill: foreground, size: 50pt)
  touying-slide(self: self, config: config, align(center + horizon, body))
})

#let last-slide(..args) = touying-slide-wrapper(self => {
  touying-slide(
    self: utils.merge-dicts(
      self,
      config-common(subslide-preamble: self => none),
    ),
    {
      align(center + bottom, stack(
        image("figures/cern_logo.svg", alt: "CERN logo", width: 75pt),
        text(link("https://home.cern", "home.cern"), size: 16pt),
        v(10pt),
        dir: ttb,
        spacing: 25pt,
      ))
    },
  )
})


/// Touying simple theme.
///
/// Example:
///
/// ```typst
/// #show: simple-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typst
/// config-colors(
///   neutral-light: gray,
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
///   primary: aqua.darken(50%),
/// )
/// ```
///
/// - aspect-ratio (string): The aspect ratio of the slides. Default is `16-9`.
///
/// - header (function): The header of the slides. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - header-right (content): The right part of the header. Default is `self.info.logo`.
///
/// - footer (content): The footer of the slides. Default is `none`.
///
/// - footer-right (content): The right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - primary (color): The primary color of the slides. Default is `aqua.darken(50%)`.
///
/// - subslide-preamble (content): The preamble of the subslides. Default is `block(below: 1.5em, text(1.2em, weight: "bold", utils.display-current-heading(level: 2)))`.
#let cern-theme(
  aspect-ratio: "16-9",
  header: self => none,
  header-right: self => none,
  footer: self => grid(
    columns: (50pt, 1fr),
    align: horizon,
    cern_logo(width: 25pt),
    text(8.5pt, self.colors.primary)[#self.info.author | #self.info.title],
  ),
  footer-right: self => grid(
    columns: (1fr, 1fr, 1fr),
    align: horizon,
    block(height: 25pt),
    utils.display-info-date(self),
    align(
      right,
      text(
        weight: "bold",
      )[#context utils.slide-counter.display()/#utils.last-slide-number ],
    ),
  ),
  primary: cern_colors.blue,
  subslide-preamble: self => {
    block(
      text(
        36pt,
        weight: "bold",
        fill: self.colors.primary,
        utils.display-current-heading(level: 2),
      ),
    )
    v(20pt)
  },
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 17pt, bottom: 17pt, left: 27pt, right: 27pt),
      footer-descent: -1em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      subslide-preamble: subslide-preamble,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          font: "Liberation Sans",
          size: 18pt,
          fill: self.colors.neutral-darkest,
        )
        show footnote.entry: set text(size: .6em)
        show heading.where(level: 1): set text(
          size: 50pt,
          fill: self.colors.primary,
        )
        show heading.where(level: 2): set text(
          size: 36pt,
          fill: self.colors.primary,
        )
        show heading.where(level: 3): set text(
          size: 21pt,
          fill: self.colors.neutral-darkest,
        )
        show link: set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-light: gray,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#2f2f2f"),
      primary: primary,
    ),
    // save the variables for later use
    config-store(
      header: header,
      header-right: header-right,
      footer: footer,
      footer-right: footer-right,
      subslide-preamble: subslide-preamble,
    ),
    ..args,
  )

  body
}
