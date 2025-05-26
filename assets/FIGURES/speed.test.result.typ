#import "@preview/fancy-units:0.1.1": *
#import "@preview/cetz:0.3.4"

#let speed-test-result = cetz.canvas({
  import cetz.draw: *;
  import "@preview/cetz-plot:0.1.1": *

  plot.plot(
    size: (7,7),
    y-max: 110,
    x-tick-step: 0.5,
    x-grid: true,
    y-grid: true,
    y-label: [Distancia $lambda$ (#unit[cm])],
    x-label: [Tiempo (#unit[s])],
    legend: "north",
    {

      plot.add(
        csv("../DATA/speed_test.csv", row-type: dictionary).map(point => (float(point.relative_time_s), float(point.distance))),
      )
    }
  )
})