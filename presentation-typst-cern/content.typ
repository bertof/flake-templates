#import "@preview/touying:0.6.1": *
#import "@preview/fletcher:0.5.8"
#import "./lib.typ": *

#let full_cite = cite.with(form: "full")

#let setup = cern-theme.with(
  lang: "en",
  config-info(
    title: [An overview on Virtualized PLCs and Agentic AI for Industrial Control Systems],
    // subtitle: [Subtitle Here],
    author: [Filippo Berto],
    date: datetime(year: 2026, month: 3, day: 5),
    institution: [CERN, BE-ICS],
  ),
)

#set list(spacing: 1em)
#set enum(spacing: 1em)
#set terms(separator: [\ ], tight: false, spacing: 1em, hanging-indent: 1em)

#title-slide()

#centered-slide()[
  #image("figures/LOGO_openlab.png", width: 250pt)
  #v(1em)
  #stack(
    image("figures/cern_logo.svg", width: 100pt),
    image("figures/Siemens_AG_logo.svg", width: 100pt),
    dir: ltr,
    spacing: 20pt,
  )
]

= Virtualized PLCs
Migrating Industrial Control Systems from Physical Hardware to Software Infrastructure

== How do we virtualize a PLC?

#slide(composer: (3fr, 2fr))[
  + *Abstract the hardware layer*: Physical PLCs are replaced by #alert[virtual machines] running the same software
  + *Deploy a real-time execution environment*: the PLC programs are executed on #alert[realtime-capable hosts], preserving the deterministic behavior
  + *Map I/Os*: connect the vPLCs to sensors and actuators via #alert[Software Defined Networks]
  + *Ensure safety & certification*: apply functional #alert[safety standards] to the virtual stack
][#align(center + horizon, image(
  "figures/Virtual PLCs.webp",
  alt: "Comparison between physical PLCs and virtual PLCs",
))]

== Motivation

- *Cost reduction*: no need to purchase, ship or maintain hardware
- *Scalability & flexibility*: spin up (or down) instances for training, testing and prototyping
- *Faster development cycles*: DevOps techniques can be applied for automatic deployment and rollback while the system is running
- *Enhanced reliability & uptime*: redundant host servers can provide automatic fallback in case of failure
- *Deployment in hazardous environments*: remote deployments are not affected by radiation or electromagnetic interference, and reduce in-person human intervention
- *Tight integration with other services*: vPLCs can be deployed alongside SCADA systems, databases, storage, and ML models for seamless integration


== Challenges

- *Real‑time performance*: Maintaining deterministic cycle times on non‑dedicated hardware across the virtualization stack
- *I/O latency*: Remote deployments increase network latency
- *Certification & regulatory compliance*: Existing safety certifications often assume dedicated hardware
- *Resource contention*: Multiple virtual PLCs sharing CPU, memory, or NIC bandwidth can affect timing and requires proper resource isolation (cgroups, VM limits).
- *Change management*: Versioning and rollback of virtual PLC images must be tightly controlled to avoid configuration drift.
- *Human factors*: Operators accustomed to tactile hardware may resist or mistrust a "software‑only" controller.

== Current developments

#slide(composer: (3fr, 1fr))[
  - *First pilot projects*: Remote control of I/O modules from vPLCs in a data center 25 Km away (#link("https://blog.siemens.com/2025/05/simatic-s7-1500v-with-failsafe-function-the-worlds-first-failsafe-virtual-plc/?stc=wwdi135358", "source")).
  #pause
  - *Edge‑centric virtualization*: Small form‑factor edge servers run containerized PLC runtimes close to the plant floor, reducing latency (#link("https://news.siemens.com/en-us/new-simatic-s7-1500-virtual-plc-vplc-industrial-edge/", "source")).
  #pause
  - *Safety‑certified virtualization layers*: Vendors are pursuing #alert[IEC 61508 SIL‑3/4 certifications] for their virtualization platforms (e.g., Siemens’ SIMATIC PCS 7 Virtual).
  #pause
  - *Hybrid deployments*: Combining physical PLCs for #alert[hard‑real‑time loops] with virtual PLCs for #alert[supervisory or optimization] tasks.
][
  #meanwhile
  #align(center + horizon, image(
    "figures/simatic-s7-1500-virtual-plc-16-4-ratio-news-01-1280x720.jpg",
    alt: "vPLC representation",
    width: 170pt,
  ))
]

== Research Focus: vPLC Implementation

+ *Multi-tier test bed deployment*: Evaluating performance across industrial edge devices, edge servers, and cloud infrastructure
#pause
+ *Performance profiling & benchmarking*: Analyzing computation and latency determinism, measuring performance and providing real-time guarantees
#pause
+ *Enhanced datacenter monitoring*: Implementing comprehensive monitoring solutions for vPLC performance, resource utilization, and health status in datacenter environments
#pause
+ *Operational integration framework*: Defining procedures and tools for seamless vPLC integration into existing development and operational workflows

== vPLC Deployment Test bed
#align(center)[
  #import fletcher: diagram, edge, node
  #diagram(
    node-stroke: .1em,

    node((2, 0), [Edge \ Switch]),

    node((4, -1), [I/O \ Module], fill: green),
    edge("l,d,l", "-", shift: 3pt),
    node((4, 0), [I/O \ Module], fill: green),
    edge("ll", "-"),
    node((4, 1), [I/O \ Module], fill: green),
    edge("l,u,l", "-", shift: -3pt),
    node((2, -1), [Industrial\ Edge Device], fill: yellow),
    edge("d", "-"),
    node((2, 1), [Industrial\ Edge Server], fill: orange),
    edge("u", "-"),

    node((1, 0), [PRP], fill: red),
    edge("r", stroke: 2pt),
    node((0, 0), [Router(s)]),
    edge("r", stroke: 2pt),
    node((-1, 0), [PRP], fill: red),
    edge("r", stroke: 2pt),
    node((0, -.25), [VXLAN], stroke: none),

    node((-2, 0), [Hypervisor \ Switch], name: <hvs>),
    edge("r", stroke: 2pt),
    node((-2, -.6), [vPLC], name: <vplc>),
    node((-2, -1.1), [Virtual \ Machine], stroke: none, name: <l_vm>),
    node(enclose: (<vplc>, <l_vm>), name: <vm>, fill: blue.lighten(40%)),
    edge("d", stroke: 2pt),
    node((-2, .5), [Hypervisor], stroke: none, name: <hv>),

    node(enclose: (<vm>, <hvs>, <hv>), layer: 2),
  )
]

= Agentic AI in Industrial Automation
Intelligent Assistance for Control Systems Development

== Challenges

#slide(composer: (1fr, 1fr))[
  / PLC code writing:
    - Slow and error prone,
    - Many aspects and guidelines to be considered,
    - Steep entry barrier
  / Writing documentation:
    - low priority, high effort task
    - low immediate gains
  / Writing tests:
    - Extra time not put into the product itself
    - Difficult to have high coverage
][
  / Complex data:
    - High volumes of multi-dimensional data thightly coupled with the code
  / Specification process:
    - Highly standardized and mostly automated
    - Several edge-cases need cross-field knowledge
  / Complex systems diagnostics:
    - Alerts and warnings might be hard to interpret by an operator
    - Diagnostics require cross-field knowledge
]

== What are AI Agents?

#slide(composer: (3fr, 2fr))[
  + *Autonomous entities* that perceive their environment, make decisions, and take actions to achieve specific goals
  + *Multi-step reasoning*: Chain complex thought processes to solve problems requiring multiple operations
  + *Tool integration*: Access and utilize external APIs, databases, and software systems
  + *Continuous learning*: Adapt and improve performance based on feedback and experience
][#align(center + horizon, {
  image(
    "figures/ai-agent.pdf",
    alt: "AI Agent architecture diagram",
  )
})]

== Agents for Industrial Control Systems

/ Rapid code prototyping: Quickly iterate through control logic variations with limited manual coding
/ Lower entry barrier: Complex processes become more accessible to less experienced users
/ Accelerate expert productivity: Automate boilerplate tasks, allowing professionals to focus on critical logic and safety aspects
/ Knowledge integration: Combine engineering expertise, safety standards, and best practices automatically
/ Documentation generation: Automatically create comprehensive documentation alongside code
/ Testing & validation: Generate test cases and verify compliance with safety requirements

== Implementation Challenges in ICS Context

#slide(composer: (3fr, 2fr))[
  / Niche programming languages: Limited training data for the models in use
  / Safety & reliability: Errors can have serious physical consequences
  #pause
  / On-premises infrastructure requirements: Handling sensitive data requires specialized models running in local controlled environments
  / Process integration complexity: AI agents must align with established safety procedures and regulatory frameworks
][
  #meanwhile
  === Targeted programming languages
  + Ctrl/Ctrl++ (WinCC OA Scripting)
  + PLC programming (STL/SCL)
  + C++ (Extensions/Plugins)
  + ...

  #pause
  === Targeted processes
  + Data exploration
  + Specification checking
  + Specification to Unicos Application Builder translation
]

== Research Focus: Agentic AI Implementation

/ Advanced code generation capabilities:
- Automated CTRL/CTRL++ and STL/SCL code generation
- Integration with CERN  WinCC OA frameworks (UNICOS, JCOP)
- Early-stage automated code verification and safety checking
#pause
/ Specification enhancement tools:
- AI-assisted specification validation and improvement
- Automated specification conversion and documentation generation
// - Specification file reversing and synchronization
- Compliance checking against specification guidelines

---

/ On-premises AI infrastructure:
- Model fine-tuning for industrial control languages
- Deploying LLM services in Prévessin data center
- Ensuring data security and regulatory compliance
#pause
/ Data exploration acceleration:
- Automated diagnostics for operators
- Integration with existing CERN data analysis frameworks
- Real-time insight generation for system optimization

---

#focus-slide()[Discussion & Questions]

// == Bibliography
// #text(size: 14pt)[
//   #bibliography("./biblio.bib", title: none)
// ]

#last-slide()

