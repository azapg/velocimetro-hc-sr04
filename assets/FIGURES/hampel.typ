#import "@preview/fancy-units:0.1.1": *
#import "@preview/cetz:0.3.4"

#let hampel-comparison = cetz.canvas({
  import cetz.draw: *
  import "@preview/cetz-plot:0.1.1": *
  plot.plot(
    size: (10, 7),
    y-max: 110,
    x-tick-step: 1,
    x-grid: true,
    y-grid: true,
    y-label: [Distancia $lambda$ (#unit[cm])],
    x-label: [Tiempo (#unit[s])],
    legend: "north",
    {
      plot.add(
        csv("../DATA/speed_test.csv", row-type: dictionary).map(point => (
          float(point.relative_time_s),
          float(point.distance),
        )),
        style: (stroke: (paint: gray)),
        label: [Datos sin filtrar],
      )

      plot.add(
        csv("../DATA/cleaned_data.csv", row-type: dictionary).map(point => (
          float(point.relative_time_s),
          float(point.distance),
        )),
        style: (stroke: (paint: blue.darken(40%))),
        label: [Datos con filtro de Hampel],
      )

      plot.add(
        csv("../DATA/outliers_data.csv", row-type: dictionary).map(point => (
          float(point.relative_time_s),
          float(point.distance),
        )),
        style: (stroke: none),
        mark: "o",
        mark-style: (fill: red.lighten(10%), stroke: none),
        mark-size: 0.12,
        label: [Valores atípicos],
      )
    },
  )
})

#let speed-test-filtered = cetz.canvas({
  import cetz.draw: *
  import "@preview/cetz-plot:0.1.1": *
  plot.plot(
    size: (7, 7),
    y-max: 110,
    x-tick-step: 0.15,
    x-grid: true,
    y-grid: true,
    y-label: none,
    y-format: (_) => [],
    x-label: [Tiempo (#unit[s])],
    legend: "north",
    {
      plot.add(
        csv("../DATA/cleaned_acceleration.csv", row-type: dictionary).map(point => (
          float(point.relative_time_s),
          float(point.distance),
        )),
        style: (stroke: (paint: blue.darken(40%))),
      )
    },
  )
})
