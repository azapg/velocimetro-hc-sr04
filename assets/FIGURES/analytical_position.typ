#import "@preview/fancy-units:0.1.1": *
#import "@preview/cetz:0.3.4"

#let TIME_MIN = 0.2566499999999223;
#let TIME_MAX = 1.452854;

#let analytical_results = cetz.canvas({
  import cetz.draw: *
  import "@preview/cetz-plot:0.1.1": *

  plot.plot(
    size: (16, 7),
    y-max: 275,
    y-min: 0,
    x-tick-step: 0.1,
    x-grid: true,
    y-grid: true,
    y-label: [Posición $x$ (#unit[cm])],
    x-label: [Tiempo (#unit[s])],
    legend: "north",
    {
      plot.add(
        csv("../DATA/positions_clean.csv", row-type: dictionary).map(point => (
          float(point.relative_time_s),
          float(point.distance),
        )),
        style: (stroke: (paint: gray)),
        mark: "o",
        mark-style: (fill: gray, stroke: none),
        mark-size: 0.12,
        label: [Datos con filtro de Hampel],
      )

      plot.add(
        domain: (TIME_MIN, TIME_MAX),
        t => (-56.03 * (t * t * t) + 176.89 * (t * t) - 72.00 * t + 11.86),
        label: [$x(t)$],
        style: (stroke: (paint: navy)),
      )

      plot.add(
        domain: (TIME_MIN, TIME_MAX),
        t => (-168.09 * (t * t) + 353.79 * t - 72.00),
        label: [$x'(t)$],
        style: (stroke: (paint: blue.darken(5%))),
      )

      plot.add(
        domain: (TIME_MIN, TIME_MAX),
        t => (-336.18 * t + 353.79),
        label: [$x''(t)$],
        style: (stroke: (paint: blue.lighten(55%))),
      )
    },
  )
})
