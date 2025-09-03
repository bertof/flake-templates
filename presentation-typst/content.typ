#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/cetz:0.4.1"

#let full_cite = cite.with(form: "full")

#let hat(a) = math.accent(a, sym.hat)

#import cetz.draw: bezier, content, line
#let node = box.with(inset: 5pt)
#let bnode(body) = rect(inset: 5pt, stroke: 1pt)[#align(center)[#body]]
#let rbnode(body) = rect(inset: 5pt, stroke: 1pt, radius: .5em)[#align(
    center,
  )[#body]]
#let label(body) = box(fill: white, inset: .25em)[#align(center)[#text(
      size: .8em,
    )[#body]]]
#let arrow = line.with(mark: (end: ">", fill: black))
#let darrow = line.with(mark: (symbol: ">", fill: black))
#let barrow = bezier.with(mark: (end: ">", fill: black))

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)

#let setup = metropolis-theme.with(
  lang: "en",
  // font: ("Linux Libertine", "Source Han Sans SC", "Source Han Sans"),
  config-info(
    title: [Presentation title],
    // subtitle: [Subtitle Here],
    author: [Filippo Berto],
    date: datetime.today(),
    institution: [Dipartimento di Informatica, Università degli Studi di Milano],
  ),
  config-common(
    datetime-format: "[day] [month repr:short] [year]",
    // show-notes-on-second-screen: bottom,
    // handout: true,
  ),
)

#title-slide()

== Motivation

#slide(composer: (1fr, auto))[
  Nowadays data intensive workflows are increasingly deployed in the #alert[Edge-Cloud continuum]

  Data is collected and #alert[preprocessed] at the #alert[Edge] and moved to the #alert[Cloud] only when necessary

  #pause

  #alert[5G technology] is a fundamental enabler for the continuum, supporting #alert[private low-latency communication] and advanced #alert[peripheral processing capabilities]

  #alert[Need for trustworthiness] on the infrastructures and the services deployed on them

][]



== Challenges

#slide(composer: (1fr, auto))[
  - Current #alert[5G standards] are not fully ready for the edge-cloud continuum
  - Severe difficulties in handling #alert[security and privacy]
  - Current security and privacy assurance solutions are not well fitted for the #alert[dynamicity] and #alert[heterogeneity] of the continuum
    - Focus on #alert[application level], leaving strong expectations on the infrastructure
][]

== Literature Gaps

#slide(composer: (1fr, auto))[
  - *G1*: Current #alert[5G standards lack support for advanced security and QoS features], and integration with cloud environments
  - *G2*: Research on distributed service workflows mainly #alert[focuses on FaaS], which does not fit well with modern data-intensive #alert[stateful workflows]
  - *G3*: Literature lacks a complete #alert[framework of non-functional properties], only performance-oriented ones are commonly recognized
  - *G4*: Lack of non-functional aware #alert[workflow deployment] solution for the continuum
][]

== Contributions

#slide(composer: (1fr, auto))[
  Novel notion of #alert[5G enabled edge-cloud continuum] (G1) @anisetti_orchestration_2022

  Realization of a #alert[complete continuum infrastructure] including a fully functional simulated 5G stack (G2) @berto_5g-iot_2022-1@berto_5g-iot_2022

  Novel #alert[assurance methodology] for modern distributed infrastructures (G3) @anisetti_assurance_2023@anisetti_devsecops-based_2022@anisetti_security_2022@anisetti_security_2021

  #alert[Property-aware deployment] solution for the #alert[assurance-focused continuum] (G4) @anisetti_qos-aware_2023
][]

// == Current notion of Edge-Cloud Continuum
// #align(center)[#cetz-canvas({
//     import cetz.draw: *

//     content((0, 0), name: "ec", node[Edge Center])
//     content((4, 4), name: "dc1", node[Data Center])
//     content((-4, 4), name: "dc2", node[Data Center])
//     content((-4, -4), name: "p", node[People])
//     content((4, -4), name: "iot", node[IoT devices])


//     darrow("ec", "dc1", name: "ec-dc1")
//     content((name: "ec-dc1", anchor: 50%), label[public \ internet])

//     darrow("ec", "dc2", name: "ec-dc2")
//     content((name: "ec-dc2", anchor: 50%), label[public \ internet])

//     darrow("ec", "p", name: "ec-people")
//     content((name: "ec-people", anchor: 50%), label[public \ internet])

//     darrow("ec", "iot", name: "ec-iot")
//     content((name: "ec-iot", anchor: 50%), label[public \ internet])

//     content((-8, 4), rbnode[Cloud \ Computing])
//     content((-8, 0), rbnode[Edge \ Computing])
//     content((-8, -4), rbnode[Fog \ Computing])
//   })
// ]

#slide(title: "Our 5G enabled continuum", align: center + horizon)[]

== Definition

*Assurance*

#pad(
  left: 1em,
)[_"Way to gain justifiable confidence that IT systems will consistently demonstrate a (set of) security property and operationally behave as expected"_]


== Infrastructure Assurance

#slide(composer: (1fr, auto))[#text(size: 18pt)[
    #alert[Assurance] allows the verification of #alert[properties] on a system by inferring over #alert[evidence]

    #alert[Components] expose state and configuration through #alert[monitoring endpoints]

    Evidence is collected my measuring the system #alert[state and configuration] using #alert[metrics]

    Each property is associated with a #alert[contract] that describes how to verify it in terms of metrics

    Properties verification gives us #alert[guarantees] on the #alert[behavior] of the system

    #alert[Assurance process] continuously verifies contracts based on the collected evidence

    Produce #alert[trustworthiness in infrastructures], as building blocks for distributed applications
  ]][
  #meanwhile
  #cetz-canvas({
    import cetz.draw: *

    content((), name: "ap", rbnode([Assurance process]))
    content((rel: (4, -3), to: "ap"), name: "c", rbnode([Contracts]))
    content((rel: (-4, -3), to: "ap"), name: "p", rbnode([Properties]))

    barrow("ap.east", "c.north", ("ap", "-|", "c"), name: "ap-c")
    content((name: "ap-c", anchor: 70%), label[references])

    barrow("ap.west", "p.north", ("ap", "-|", "p"), name: "ap-p")
    content((name: "ap-p", anchor: 70%), label[targets])

    content((rel: (0, -3), to: "c"), name: "m", rbnode([Metrics]))
    content((rel: (0, -3), to: "p"), name: "cs", rbnode([Components]))
    content((rel: (0, -3.5), to: "m"), name: "ep", rbnode(align(
      center,
    )[Monitoring \ Endpoints]))
    content((rel: (0, -3.5), to: "cs"), name: "sc", rbnode(align(
      center,
    )[State and \ Configuration]))

    arrow("c", "m", name: "c-m")
    content((name: "c-m", anchor: 50%), label[based on])

    arrow("p", "cs", name: "p-cs")
    content((name: "p-cs", anchor: 50%), label[apply to])

    arrow("m", "ep", name: "m-ep")
    content((name: "m-ep", anchor: 50%), label[query])

    arrow("cs", "sc", name: "cs-sc")
    content((name: "cs-sc", anchor: 50%), label[have])

    arrow("ep", "sc", name: "ep-sc")
    content((name: "ep-sc", anchor: 50%), label[expose])


    arrow("m", "sc", name: "m-sc")
    content((name: "m-sc", anchor: 50%), label[measure])
  })
]

= Applying assurance in modern distributed workflows

#text(size: 14pt)[#full_cite(<anisetti_assurance_2023>)]

== Assurance for Analytics Workflows

// The target of the assurance process is a workflow $tau$ composed of
// - a set of #alert[tasks] $t in T$ implementing the processing workflow $w$
// - a set of #alert[services] $s in S$ implementing the ecosystem $e$ and supporting the deployment and execution of the workflow

// Our methodology is based on two abstractions:

#slide[
  #alert[Abstract Service Ecosystem] is a 5-tuple $#sym.angle.l S_I,S_C,S_S,S_V,S_E #sym.angle.r$

  - $S_S$ is a set of storage services,
  - $S_C$ is a set of computational services,
  - $S_I$ is a set of ingestion services supporting data collection,
  - $S_V$ is a set of visualization services,
  - $S_E$ is a set of environmental services offering additional non-functional capabilities.
]

#slide(composer: (1fr, auto))[
  #alert[Abstract workflow] defined via BNF as a sequence of steps (_Input_, _Preparation_, _Analytics_, _Visualization_)

  #alert[Concrete workflow] produced by instantiating each generic task $t in w$ in an executable task with the form of a function call
][
  $
    w & ::= #sym.angle.l T_I #sym.plus.circle P #sym.plus.circle A #sym.plus.circle T_V #sym.angle.r \
    P & ::= epsilon | T_P | P #sym.plus.circle T_P \
    A & ::= epsilon | T_A | A #sym.plus.circle T_A \
    T_I & ::= #text[stream] | #text[fileSystem] | #text[DBMS] | ... \
    T_P & ::= #text[cleaning] | #text[normalization] | #text[selection] | ... \
    T_A & ::= #text[modeling] | #text[prediction] \
    T_V & ::= T_I | T_I #sym.plus.circle #text[visualization] | \
  $
]


// == Running Example on Apache Spark


// #slide(composer: (1fr, auto))[
//   #box(clip: true, height: 16em)[
//     #v(6em)
//     #image("images/pipeline_tasks.png", height: 19em)
//   ]
// ][
//   $
//     #sym.Pi = #sym.angle.l w,e #sym.angle.r #h(1em) & w= #sym.angle.l t_1 #sym.plus.circle t_2 #sym.plus.circle t_3 #sym.plus.circle t_4 #sym.angle.r \
//     & e= #sym.angle.l s_1,[s_2,s_3],s_4,s_5,s_6 #sym.angle.r \
//     I= #sym.angle.l hat(w) , hat(e) #sym.angle.r #h(1em) & hat(w) = #sym.angle.l hat(t_1) #sym.plus.circle hat(t_2) #sym.plus.circle hat(t_3) #sym.plus.circle hat(t_4) #sym.angle.r \
//     & hat(e) = #sym.angle.l hat(s_1),\[ hat(s_2), hat(s_3)\], hat(s_1), #sym.epsilon, \[ hat(s_4), hat(s_5)\] #sym.angle.r
//   $
// ]

// == Requirements Annotations

// The template is annotated with #alert[generic non-functional requirements] to be addressed via two labeling functions

// - $lambda$ assigns labels $lambda(t_i)$ corresponding to workflow requirements in $R_w$
// - $gamma$ assigns labels $gamma(s_i)$ corresponding to service requirements in $R_e$

// The instance is annotated with #alert[specific non-functional requirements] to be address via two labeling functions
// - $theta$ assigns a label $theta(hat(t_i))$ corresponding to workflow requirements in $R_(hat(w))$
// - $psi$ assigns a label $psi(hat(s_i))$ corresponding to workflow requirements in $R_(hat(e))$


== Assurance Methodology

#slide(composer: (1fr, auto))[
  - The #alert[client] chooses a #alert[workflow template] and annotates it with #alert[generic requirements]
  - The annotated template is converted to an #alert[annotated workflow instance] based on the concrete requirements that can be supported
  - The workflow is checked using #alert[probes], verifying the annotated requirements, producing #alert[assurance confidence levels]
][ ]

// == Running Example: Requirements and Assurance Probes

// #slide(composer: (1fr, 1fr))[
//   #image("images/pipeline_requirements.png")
// ][
//   #image("images/pipeline_probes.png")
// ]

// == Running Example: Assurance Evaluation

// #slide(composer: (1fr, 1fr), align: center + horizon)[
//   #cetz-canvas({
//     import cetz.draw: *
//     content(
//       (0, 0),
//       text(size: 12pt)[
//         #align(center + horizon)[#table(
//             columns: (auto, auto, auto, auto, auto),
//             align: center + horizon,
//             inset: .5em,
//             table.header(
//               table.cell(colspan: 5)[
//                 #text(weight: "extrabold")[
//                   Workflow tasks $hat(t) in hat(T)$
//                 ]
//               ],
//               [$hat(t)$], [$cal(R)$],
//               [$P(r,tau)$],
//               [$E(E V,r)$],
//               [$A_(tau,r)$],
//             ),
//             table.cell(rowspan: 4)[$hat(t_1)$],
//             [$r^theta_1$],
//             [$P_1(r^theta_1,hat(t_1))$],
//             [$[1.0]$],
//             [1.0],
//             [$r^theta_2$],
//             [$P_2(r^theta_2,hat(t_1)),P_3(r^theta_2,hat(t_1)),P_4(r^theta_2,hat(t_1))$],
//             [$[1.0,1.0,1.0]$],
//             [$1.0$],
//             [$r^theta_3$],
//             [$P_5(r^theta_3,hat(t_1)),P_6(r^theta_3,hat(t_1))$],
//             [$[0.75,1.0]$],
//             [$0.88$],
//             [$r^theta_5$],
//             [$P_8(r^theta_5,hat(t_1))$],
//             [$[1.0]$],
//             [$1.0$],
//             table.cell(rowspan: 3)[$hat(t_2)$],
//             [$r^theta_1$],
//             [$P_1(r^theta_1,hat(t_2))$],
//             [$[1.0]$],
//             [$1.0$],
//             [$r^theta_2$],
//             [$P_2(r^theta_2,hat(t_2)),P_3(r^theta_2,hat(t_2)),P_4(r^theta_2,hat(t_2))$],
//             [$[1.0,1.0,1.0]$],
//             [$1.0$],
//             [$r^theta_3$],
//             [$P_5(r^theta_3,hat(t_2)),P_6(r^theta_3,hat(t_1))$],
//             [$[0.75,1.0]$],
//             [$0.88$],
//             table.cell(rowspan: 3)[$hat(t_3)$],
//             [$r^theta_1$],
//             [$P_1(r^theta_1,hat(t_3))$],
//             [$[1.0]$],
//             [1.0],
//             [$r^theta_2$],
//             [$P_2(r^theta_2,hat(t_3)),P_3(r^theta_2,hat(t_3)),P_4(r^theta_2,hat(t_3))$],
//             [$[1.0,1.0,1.0]$],
//             [$1.0$],
//             [$r^theta_3$],
//             [$P_5(r^theta_3,hat(t_3)),P_6(r^theta_3,hat(t_1))$],
//             [$[0.75,1.0]$],
//             [$0.88$],
//             table.cell(rowspan: 4)[$hat(t_4)$],
//             [$r^theta_1$],
//             [$P_1(r^theta_1,hat(t_4))$],
//             [$[1.0]$],
//             [$1.0$],
//             [$r^theta_2$],
//             [$P_2(r^theta_2,hat(t_4)),P_3(r^theta_2,hat(t_4)),P_4(r^theta_2,hat(t_4))$],
//             [$[1.0,1.0,0.0]$],
//             [$0.66$],
//             [$r^theta_3$],
//             [$P_5(r^theta_3,hat(t_4)),P_6(r^theta_3,hat(t_1))$],
//             [$[0.75,1.0]$],
//             [$0.88$],
//             [$r^theta_6$],
//             [$P_9(r^theta_6,hat(t_4))$],
//             [$[1.0]$],
//             [$1.0$],
//             [$hat(p)$],
//             [$r^theta_4$],
//             [$P_7(r^theta_4,hat(p))$],
//             [$[1.0]$],
//             [$1.0$],
//           )]],
//     )
//     rect(
//       (rel: (-6, -4.125)),
//       (rel: (12, 1.125)),
//       fill: red.transparentize(80%),
//       stroke: red,
//     )
//   })
// ][
//   #cetz-canvas({
//     import cetz.draw: *

//     content((0, 0), image(
//       "images/pipeline_evaluation_services.png",
//       width: 18em,
//     ))
//     rect(
//       (rel: (-6.5, -5)),
//       (rel: (12.75, 1.5)),
//       fill: red.transparentize(80%),
//       stroke: red,
//     )
//   })

//   #text(
//     size: 12pt,
//   )[Assurance levels $A_(tau,gamma)$ = Frequency of positive evaluation multiplied by the average of the positive evaluations]
// ]


// == Running Example: Assurance Evaluation

// #slide(composer: (1fr, 1fr))[
//   Performance of the assurance process on the example workflow in different scenarios:
//   - #alert[Contextual changes (CC)]
//   - #alert[Workflow changes (PC)]
//   - #alert[Ecosystem changes (EC)]
//   - #alert[Instance changes (IC)]
//   - #alert[No changes (NC)]
// ][
//   #image("images/pipeline_assurance_performance.png")
// ]

= Assurance-aware deployments in the continuum

#text(size: 14pt)[#full_cite(<anisetti_qos-aware_2023>)]

== Deployment in Network and Computing infrastructures

The non-functional properties of the deployment targets influence the deployed application's properties

The #alert[heterogeneity] of the continuum ecosystem reflects on the deployment targets

#alert[Exploiting infrastructure peculiarities] to support NFP-based Service Level Agreements while deploying workflows in the continuum

== Deployment Methodology

#slide(composer: (1fr, 1fr))[
  - Continuum Service Providers generate an #alert[annotated graph of their facilities]
  - The client defines an #alert[annotated template for service composition]
  - The #alert[deployment matching process] searches for a suitable match of services and deployment facilities
  - If a match is found, the system generates #alert[deployment recipes for the Edge-Cloud continuum]
][
  #text(size: 12pt)[
    #cetz-canvas({
      import cetz.draw: *

      content((0, 0), name: "DM", rbnode([Deployment Matching]))
      content((to: "DM", rel: (4, 2)), name: "SCT", rbnode(align(
        center,
      )[Annotated Service Composition \ Template]))
      content((to: "DM", rel: (-4, 2)), name: "ADF", rbnode(align(
        center,
      )[Annotated Continuum \ Facilities Graph]))
      content((to: "SCT", rel: (0, 2)), name: "C", rbnode([Client]))
      content(
        (to: "ADF", rel: (0, 2)),
        name: "SP",
        rbnode([Continuum Service Provider]),
      )
      content((to: "DM", rel: (0, -2)), name: "DR", rbnode([Deployment Recipes]))
      content(
        (to: "DR", rel: (0, -2)),
        name: "CDF",
        rbnode([Edge-Cloud Continuum]),
      )

      barrow("ADF.south", "DM.west", ("ADF", "|-", "DM"), name: "ADF-DM")
      content((name: "ADF-DM", anchor: 40%), label[used by])

      barrow("SCT.south", "DM.east", ("SCT", "|-", "DM"), name: "SCT-DM")
      content((name: "SCT-DM", anchor: 40%), label[used by])

      arrow("C", "SCT", name: "C-SCT")
      content((name: "C-SCT", anchor: 50%), label[defines])

      arrow("SP", "ADF", name: "SP-ADF")
      content((name: "SP-ADF", anchor: 50%), label[generates])

      arrow("DM", "DR", name: "DM-DR")
      content((name: "DM-DR", anchor: 50%), label[generates])

      arrow("DR", "CDF", name: "DR-CDF")
      content((name: "DR-CDF", anchor: 50%), label[deployed on])
    })
  ]
]

== Deployment Matching

#slide(composer: (2fr, 1fr))[
  - The client identifies a list of #alert[services] and annotate them with #alert[non-functional requirements]
  - The Continuum Service Provider describe the available #alert[deployment facilities] and their #alert[non-functional capabilities]
  - The #alert[deployment matching process] finds a #alert[suitable configuration] considering #alert[services' requirements] and #alert[facilities' capabilities]
][ ]

== Handling assurance failure

#slide(composer: (2fr, 1fr))[
  - The node $f_2$ loses a non-functional capability that is required by $S_2$ and $S_3$
  #uncover(2)[
    - The deployment process finds a new suitable matching and generates new deployment recipes
  ]
][ ]

// == Performance Evaluation

// #slide(composer: (1fr, 1fr))[
//   Performance of the #alert[Matching Process] varying the number of services and facilities

//   Services requirements and Facilities capabilities are synthetically generated
// ][
//   #image("images/matching_perf.pdf.png")
// ]


= Assurance for Content Distribution Networks

#text(size: 14pt)[
  #full_cite(<anisetti_security_2022>) \
  #full_cite(<anisetti_security_2021>)
]

#slide(
  composer: (1fr, auto),
  repeat: 2,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    #alternatives[
      CDN based on #alert[Named Data Networking]

      // Alternative network stack to TCP/IP

      Advanced content cache system focused on #alert[in-protocol caching and security]

      #alert[Contents security and privacy] by default

      // Can be used as an application layer in other protocols
    ][
      #alert[Target Nodes] expose metrics as NDN contents

      #alert[Accredited Labs] implement the assurance process
      - collect evidence from #alert[Target Nodes]
      - verify properties of Target Nodes on-demand of #alert[Certification Clients]
      - issue #alert[signed certificates] containing the #alert[verification results]

      Previously issued certificates by trusted AL can be reused to #alert[speed-up the verification process]

      Accredited Labs can collaborate sharing #alert[signed certificates] and #alert[evidence]
    ]
  ],
)[ ]



== Centralized VS Decentralized Certification

#slide(composer: (2fr, 1fr))[
  // The peculiar capabilities of NDN allowed us to develop two certification solutions

  A #alert[centralized certification process], which is the standard implementation

  A #alert[collaborative and decentralized certification process] using NDN caching model

  ALs #alert[share evidence and certificates] with other ALs in the network, maintaining #alert[confidentiality and non-repudiability]
][ ]

// == Performance evaluation

// #slide(composer: (1fr, 1fr))[
//   #image("images/execution_time_on_nodes.pdf.png")
// ][
//   #image("images/network_usage.pdf.png")
// ]

= TIM Industrial Scenario

#text(size: 14pt)[
  #full_cite(<berto_5g-iot_2022-1>) \
  #full_cite(<berto_5g-iot_2022>)
]

== TIM Industrial Scenario: Workflow

#align(horizon + center)[
  #cetz-canvas({
    import cetz.draw: *
    content((0, 0), [])
    content((4.2, -0.5), label[#text(
        size: 19pt,
        font: "DejaVu Sans",
      )[Data Workflow]])
  })
]

== TIM Industrial Scenario: Performance


#slide(composer: (1fr, 1fr), align: center + horizon)[ ][ ]



== Conclusions

#slide(composer: (1fr, auto))[
  Introduction of a #alert[novel fully-functional 5G-empowered continuum architecture]

  The #alert[infrastructure assurance methodology] has been developed and verified in #alert[integrated industrial-ready scenario]

  Proposed a solution for supporting #alert[intensive computation and smart deployment]

  Assurance for #alert[data intensive workflows] exploiting big data platforms

  Novel seamless deployment solution for #alert[workflows in the continuum]
][
]

== Thanks

#slide(composer: (1fr, auto))[
  Future research directions
  - #alert[Intent-driven continuum] empowered by assurance
  - #alert[Satellite based continuum]
  - #alert[Lightweight assurance] for unreliable networks
  - #alert[AI-based assurance] methodology

  The #alert[work in this thesis] resulted in
  - #alert[2] journal articles (Q1 according to Scimago)
  - #alert[7] conference papers
  - #alert[1] chapters in international books

][
]


== Bibliography

#text(size: 14pt)[
  #bibliography("./biblio.bib", title: none)
]


