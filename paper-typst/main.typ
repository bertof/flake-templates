#import "@preview/charged-ieee:0.1.3": ieee
#import "@preview/cetz:0.3.3": canvas, draw, tree
#import "@preview/fletcher:0.5.5" as fletcher: diagram, edge, node

#show: ieee.with(
  title: [Multi-layer Certification],
  abstract: [
    The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing. Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.
  ],
  paper-size: "a4",
  authors: (
    (
      name: "Anonymous for double-blind review",
    ),
  ),
  index-terms: (
    "Scientific writing",
    "Typesetting",
    "Document creation",
    "Syntax",
  ),
  bibliography: bibliography("biblio.bib"),
)

// Your content goes below.

= Background<sec:background>

= Related Work<sec:relatedwork>

// \input{other/07_tbl_related_work.tex}

According to Table~\ref{tbl:relatedwork}, we can first observe that \hl{TODO, vediamo quando completi}

#figure(
  diagram(
    $
                    G edge(f, ->) edge("d", pi, ->>) & im(f) \
      G slash ker(f) edge("dr", tilde(f), "hook-->")
    $,
  ),
  caption: [test fletcher],
)
