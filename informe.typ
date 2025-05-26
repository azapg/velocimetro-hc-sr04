#import "@preview/graceful-genetics:0.2.0" as graceful-genetics
#import "@preview/physica:0.9.3"
#import "@preview/fancy-units:0.1.1": *
#import "@preview/pillar:0.3.2"
#import "@preview/subpar:0.2.2"
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.3.4"

#import "assets/FIGURES/speed.test.result.typ": speed-test-result;
#import "assets/FIGURES/hampel.typ": hampel-comparison, speed-test-filtered
#import "assets/FIGURES/analytical_position.typ": analytical_results

#show: codly-init.with()

#set text(lang: "es")
#set quote(block: true)
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.")
#set page(
  header: [
    #counter(footnote).update(0)
  ],
)


#fancy-units-configure(per-mode: "slash", unit-separator: sym.comma)
#codly(languages: codly-languages)

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Apéndice])
  show heading: it => [#it.body \ \ ]
  counter(heading).update(0)
  body
}

#let eam = qty[0.40][cm];

#show: graceful-genetics.template.with(
  title: [Radar de Rapidez mediante HC-SR04 y Arduino: Calibración y Análisis de Datos],
  authors: (
    (
      name: "Allan Zapata",
      department: "Ciencia de Datos",
      institution: "EC-106-14927",
      city: "Panamá",
      country: "Panamá",
      mail: "allan.zapata@up.ac.pa",
    ),
    (
      name: "Félix Cárdenas",
      department: "Ciencia de Datos",
      institution: "8-1047-1841",
      city: "Panamá",
      country: "Panamá",
      mail: "felix-d.cardenas-m@up.ac.pa",
    ),
  ),
  date: (year: 2025, month: "May", day: 26),
  keywords: (
    "HC-SR04",
    "Arduino",
    "Calibración",
    "Datos",
    "Radar de Rapidez",
    "Sensor de Distancia",
    "Física Experimental",
  ),
  abstract: [
    Los sensores ultrasónicos son dispositivos que utilizan ondas de sonido para medir distancias. Estos son útiles en diversas aplicaciones, como la robótica o automatización en fábricas. En este informe, se presenta el uso de estos dispositivos para el estudio de cinemática, específicamente para medir la rapidez de un auto a control remoto de juguete. Se presenta la calibración del sensor consiguiendo un error absoluto medio (EAM) de #eam y posteriormente el uso de este para medir la rapidez del auto utilizando un Arduino. Se presenta también los métodos de recolección de datos y análisis de los mismos. Se concluye que el sensor ultrasónico es una herramienta útil para medir distancias y velocidades, aunque su precisión puede verse afectada por factores como la temperatura y la humedad.
  ],
)

= Introducción
El sensor ultrasónico HC-SR04 es un dispositivo ampliamente utilizado en aplicaciones de medición de distancia y detección de objetos @Prayetno_Nadapdap_Susanti_Miranda_2021@Sulistyawan_Salim_Abas_Aulia_2023.
Su funcionamiento depende de dos transductores, un emisor de ondas ultrasónicas---#qty[40][kHz]--- y un receptor del rebote de estas ondas @Fuentes_2014. Midiendo el tiempo $t$ entre la emisión y la recepción de las ondas se puede calcular la distancia $d$ al objeto utilizando la fórmula $d = v_s t$, donde $v_s$ es la velocidad del sonido en el aire. También se puede calibrar el sensor utilizando regresión lineal a partir de mediciones de tiempo de recepción junto con medidas conocidas, lo que permite obtener una relación más precisa entre la distancia medida y la distancia real. En este informe se utiliza este último método.

La decisión de utilizar este método se fundamenta en la cantidad de factores que pueden afectar la precisión de la medición, como la temperatura, densidad y la humedad del aire @Fuentes_2014@Gandha_Santoso_2020.
= Procedimiento
La realización de este experimento requiere de tres partes: la confección del dispositivo de medición, la calibración del sensor y la medición de la rapidez del auto a control remoto.

== Confección del dispositivo de medición
La confección del dispositivo de medición consiste en unir el sensor HC-SR04 a un Arduino MKR WiFi 1010 utilizando un protoboard y cables. Este controlador se conectaba a una computadora para servir como fuente de poder y permitir la recolección de datos. Imágenes de los componentes y el dispositivo de medición se pueden ver en la @fig:device_and_components.

#subpar.grid(
  caption: [Dispositivo de medición y sus componentes.],
  label: <fig:device_and_components>,
  placement: auto,
  scope: "parent",
  columns: (1fr, 1fr, 2fr),

  figure(
    image("assets/PNG/LQ/ArduinoMKRWiFi1010.png"),
    caption: [Arduino MKR WiFi 1010],
  ),
  [#figure(
      image("assets/PNG/LQ/HC-SR04.png"),
      caption: [Sensor ultrasónico HC-SR04],
    ) <fig:HC-SR04>],
  figure(
    image("assets/PNG/LQ/METER.png"),
    caption: [Dispositivo de medición],
  ),
)

#let trigPin = num[4]
#let echoPin = num[5]

El sensor ultrasónico HC-SR04 tiene cuatro pines: `Vcc`, `Gnd`, `Trig` y `Echo` _(Véase la @fig:HC-SR04)_ @Fuentes_2014. El pin `Vcc` se conecta a la fuente de alimentación de #qty[5][V]. El pin `Gnd` se conecta a tierra. El pin `Trig`, utilizado para emitir ondas ultrasónicas, se conecta al pin digital #trigPin del Arduino. El pin `Echo`, utilizado para recibir estas ondas ultrasónicas, se conecta al pin digital #echoPin del Arduino. El Arduino se alimenta a través de un cable USB conectado a la computadora.

Para programar el Arduino se decidió utilizar Platformio#footnote[https://platformio.org/] ya que este ecosistema permite mayor control que sistemas como Arduino IDE y además permite utilizar sus librerías y arquitecturas. El código en `C++` dentro del Arduino se presenta en el @fig:arduino_code. Este código incluye la configuración de los pines a utilizar, el uso del transductor emisor y receptor para obtener una lectura y la conversión a distancia utilizando la @eq:calibrated_regression obtenida en la @sec:calibration.

#figure(
  caption: [Código utilizado en el Arduino para controlar el sensor y registrar sus lecturas.],
  supplement: [Programa],
  [

    #show raw: set text(size: 4pt)

    ```cpp
    #include <Arduino.h>
    #include "constants.h"

    unsigned long duration;
    unsigned long startTime;

    void setup() {
      Serial.begin(BAUD_RATE);
      pinMode(TRIG_PIN, OUTPUT);
      pinMode(ECHO_PIN, INPUT);

      startTime = micros();
    }

    void loop() {
      digitalWrite(TRIG_PIN, LOW);
      delay(2);

      digitalWrite(TRIG_PIN, HIGH);
      delay(10);

      digitalWrite(TRIG_PIN, LOW);

      duration = pulseIn(ECHO_PIN, HIGH);
      Serial.print(duration * 0.0183 - 0.3639);
      Serial.print(" cm - ");
      Serial.print(micros() - startTime);
      Serial.println(" µs");
    }
    ```],
) <fig:arduino_code>

== Calibración del sensor <sec:calibration>
La calibración del sensor HC-SR04 involucró obtener medidas de los tiempos leídos por este mismo en base a la distancia de un objeto colocado en frente del dispositivo de medición. Se utilizó una regla y una superficie metálica plana para obtener estas medidas _(véase la @fig:calibration_elements)_.

En la configuración mostrada en la @fig:calibration_elements, las distancias se empezaban a medir desde la marca de #qty[5][cm] en la regla mostrada, esto debido a que es desde donde salen y entran las ondas ultrasónicas del sensor. Algo muy importante a considerar es que no es el punto donde se emiten o se reciben las ondas, puesto que eso ocurre en elementos dentro del sensor que no podemos referenciar.

#figure(
  caption: [Elementos utilizados en la calibración del sensor],
  image("assets/JPG/CALIBRATION.jpg"),
) <fig:calibration_elements>

#let calibration_measures = num[33];
#let calibration-measures-min = qty[0.80][cm]
#let calibration_measures_max = qty[29.80][cm]

Se obtuvieron #calibration_measures medidas al momento de calibrar desde #calibration-measures-min hasta #calibration_measures_max. Para cada distancia medida, se colocaba la superficie metálica frente al sensor y se observaba los tiempos resultantes en el monitor serial del Arduino y se registraba el tiempo más frecuente que apareciera en la pantalla. En caso de haber ruido en la medición, lo cual era común, se obtenían 10 medidas en un momento al azar y se calculaba un promedio a partir de esas medidas y ese sería el valor registrado. Esto se repetía 3 veces removiendo y volviendo a colocar la superficie para obtener un valor promedio que sería agregado a la tabla de calibración presentada en la @table:calibration.

A partir de esta tabla se realizó una regresión lineal simple para modelar la distancia $L$ en función del tiempo $t$. En este análisis se consideró el tiempo en microsegundos como la variable independiente y la distancia la variable dependiente. Esta regresión y otros cálculos presentados en este informe se encuentran en el _Notebook#footnote[https://github.com/azapg/velocimetro-hc-sr04/blob/main/velocimetro-hc-sr04.ipynb]_ adjuntado a este informe.

#let calibration-data = csv("assets/DATA/calibration.csv");
#let _ = calibration-data.remove(0);

#figure(
  caption: [Tiempos promedio $t$ en microsegundos obtenidos a partir de las distancias $L$ en el proceso de calibración],
  table(
    ..pillar.cols("cc||cc||cc"),
    ..([$L$ (cm)], [$t$ ($mu "s"$)]) * 3,
    table.hline(),
    ..calibration-data.flatten()
  ),
) <table:calibration>

#let correlation_coef = num[0.9985]

La regresión lineal de la distancia sobre el tiempo resultó en la @eq:calibrated_regression. Esta regresión tiene un coeficiente de correlación de #correlation_coef.

$ lambda = 0.0183 t - 0.03639 $ <eq:calibrated_regression>

Con la @eq:calibrated_regression se volvieron a tomar medidas para calcular el error de esta calibración. Se utilizó el mismo procedimiento mencionado anteriormente y se obtuvieron los datos presentados en la @table:calibration_test

#let calibration-test-data = csv("assets/DATA/calibration_test.csv")
#let _ = calibration-test-data.remove(0);

#figure(
  caption: [Distancia real $L$ y distancia leída por el sensor $lambda$ después de la calibración],
  table(
    ..pillar.cols("cc||cc||cc"),
    ..([$L$ (cm)], [$lambda$ (cm)]) * 3,
    table.hline(),
    ..calibration-test-data.flatten()
  ),
) <table:calibration_test>

#let ecm = qty[0.37][cm^2]

Se puede observar en la @table:calibration_test que la calibración el sensor registra lecturas muy aproximadas a los valores reales. En el _Notebook_ adjunto se hace un pequeño análisis del error de esta calibración y los resultados muestran un EAM de #eam y un error cuadrático medio (ECM) de #ecm. Se puede observar en la @fig:graph_calibration_test que hay un mayor error al medir objetos muy próximos al sensor. Se hicieron análisis de error en distintas regiones y se obtuvo que para distancias menores a #qty[10][cm] el EAM es de #qty[0.69][cm] y para distancias mayores a #qty[20][cm] es de #qty[0.18][cm].

#figure(
  caption: [Gráfica mostrando los datos obtenidos en la prueba de la calibración. Se presentan las medidas del sensor y las medidas ideales en base a las medidas reales de las pruebas.],
  cetz.canvas({
    import cetz.draw: *
    import "@preview/cetz-plot:0.1.1": *

    plot.plot(
      name: "Prueba de calibración",
      size: (7, 7),
      legend: "north",
      x-label: [Distancia real $L$ (cm)],
      y-label: [Distancia medida $lambda$ (cm)],
      x-tick-step: 2,
      y-tick-step: 2,
      x-grid: "both",
      y-grid: "both",
      {
        plot.add(
          calibration-test-data.map(point => (float(point.at(0)), float(point.at(1)))),
          label: [Medidas del HC-SR04],
          style: (stroke: none),
          mark: "o",
        )
        plot.add(domain: (0, 30), x => x, label: [Medidas ideales $y=x$])
      },
    )
  }),
) <fig:graph_calibration_test>

Se intentó hacer una correción a la @eq:calibrated_regression a partir de la @table:calibration_test haciendo una regresión lineal para predecir la distancia real a partir de la medida del sensor, pero se obtuvieron peores resultados. Esta segunda prueba se realizó exclusivamente para distancias mayores a #qty[20][cm] y el EAM fue de #qty[0.40][cm], un #qty[118.7][%] más que el error sin la corrección. El procedimiento exacto de la corrección se encuentra en el _Notebook_ adjunto. Debido a que no se consiguió una mejor calibración que la expresada en la @eq:calibrated_regression, fue esta la que se utilizó en las mediciones de rapidez en el @fig:arduino_code.

== Medición de rapidez <sec:procedure_speed_test>
Con el sensor HC-SR04 ya calibrado, se utilizó el código presentado en el @fig:arduino_code para medir la distancia a la que se encontraba el auto de juguete a través del tiempo. En el @fig:arduino_code:12 se muestra como se utiliza una medida relativa de tiempo donde se define $t=0$ en el momento en el que se ejecuta la función ```cpp void setup()``` en el Arduino.

Utilizando Platformio se guardaban las salidas del monitor serial en un archivo `.log` para el análisis de los datos. Este archivo también agrega una marca de tiempo usando el tiempo real de la computadora.

El auto de juguete se colocaba de frente a #qty[3][cm] del sensor. Esto se debe a que el vehículo es más controlable cuando se conduce en reversa. De esta manera es un poco más lento y menos probable a cambiar su dirección inicial.

// Dependiendo de los resultados, podría mencionar lo de la prueba back and forth

= Resultados

Después de convertir los archivos `.log` obtenidos del procedimiento presentado en la @sec:procedure_speed_test en archivos `.csv` listos para análisis, se obtuvieron los datos de la @fig:noisy_speed_test_graph. Se ve claramente como estos datos tienen grandes cantidades de ruido en $#qty[1][s] < t < #qty[2][s]$. Por otro lado, se puede entender la información general al considerar que el auto a control remoto se encontraba en $x = #qty[3.5][cm]$ en el inicio del experimento y luego acelera hasta que el sensor deja de detectarlo, en $x > #qty[106][cm]$.

#figure(
  caption: [Gráfica que muestra la posición $lambda$ medida por el sensor en base al tiempo#footnote[Se tomó un fragmento de los datos de todos los intentos, realmente, el tiempo empezaría en $t=610$, pero se transformaron los datos para empezar a contar desde $t=0$.]. Solo se muestran los momentos finales del experimento.],
  speed-test-result,
) <fig:noisy_speed_test_graph>

Se aplicó un filtro Hampel para eliminar el ruido de medición del conjunto de datos. El filtro utiliza un enfoque de _ventana deslizante_ para identificar valores atípicos comparando cada punto con la mediana local en su vecindad. Los parámetros se establecieron con un tamaño de ventana de 13 puntos y un umbral de 0, lo que significa que cualquier punto que se desviara de su mediana local se consideró ruido y se reemplazó con el valor de la mediana. Se eligieron estos parámetros agresivos porque se espera que la señal física subyacente (distancia vs. tiempo) sea uniforme y monótona---como una función exponencial---, lo que hace que cualquier desviación pronunciada probablemente se deba a artefactos de medición en lugar de variaciones legítimas de la señal.
Los resultados de este filtro se presentan en la @fig:hampel_filter. El _script_ en Python del algoritmo se presenta en el _Notebook_ adjunto.
#subpar.grid(
  placement: bottom,
  scope: "parent",
  align: bottom,
  columns: (1.5fr, 1fr),
  label: <fig:hampel_filter>,
  caption: [Gráfica posición $lambda$ vs tiempo $t$ mostrando la limpieza del ruido utilizando el filtro de Hampel.],
  [#figure(
      hampel-comparison,
      caption: [Comparasión entre los datos sin filtrar y con filtrado de Hampel.],
    ) <fig:filtered_speed_test_comparison>],
  [#figure(speed-test-filtered, caption: [Movimiento del auto con filtro de Hampel]) <fig:clean_speed_test>],
)

Dadas estas posiciones sin ruido del sensor, se aplicó regresión polinomial de grado tres para obtener una función que describa el movmiento del auto y poder analizar su velocidad y aceleración. El procedimiento para obtener esta regresión se presenta en el _Notebook_ adjunto. La regresión dio como resultado el polinomio presentado en la @eq:polinomio_pos.#footnote[Para ${#qty[0.26][s] <= t <= #qty[1.45][s]}$] Esta regresión se aproxima bastante a los datos, a excepción de las zonas donde se presentaba mayor cantidad de ruido, donde es muy probable que se haya perdido la información original del movimiento del auto. Específicamente, la regresión tiene un EAM de #qty[1.68][cm] y un ECM de #qty[5.38][cm^2].  

$ x = -56.03t^3 + 176.89t^2 - 72.00t + 11.86 $ <eq:polinomio_pos>

En la @fig:analytical_results se presentan los resultados analíticos obtenidos a partir de la @eq:polinomio_pos, incluyendo sus derivadas.

#figure(
  placement: top,
  scope: "parent",
  caption: [Resultados analíticos del movimiento del auto.],
  analytical_results
) <fig:analytical_results>

= Discusión

Inicialmente, se esperaba del análisis que la aceleración del auto fuera positiva en la dirección contraria al sensor, pero la @fig:analytical_results muestra una aceleración negativa, lo cual no es muy intuitivo. Se esperaría que al mover la palanca del control remoto del auto hacia adelante, este empezaría a acelerar positivamente ganando rapidez hasta llegar a un valor constante. Hay varias hipótesis que podrían explicar  este resultado, algunas se mencionan a continuación.

*Limitaciones del Motor y Potencia.* El auto a control remoto utilizado es de bajo costo y posee un motor simple. Es probable que este motor genere un impulso inicial considerable (un pico de torque al arrancar), lo que explicaría el aumento inicial de la velocidad. Sin embargo, su potencia sostenida podría ser insuficiente para contrarrestar las fuerzas resistivas que aumentan con la velocidad, como la fricción del aire y la resistencia al rodamiento. Como resultado, el motor podría ser capaz de hacer que el auto alcance rápidamente su velocidad máxima para su potencia limitada bajo esas condiciones, y luego, la aceleración neta se vuelve negativa a medida que las fuerzas de resistencia superan la fuerza de propulsión del motor.

*Respuesta No Lineal del Sistema.* No se puede asumir que el auto, al ser un sistema físico real, responderá de forma perfectamente lineal y continua a la entrada del joystick. Un motor simple, especialmente con una batería económica, puede tener una entrega de potencia que decae o se estabiliza rápidamente, no permitiendo una aceleración positiva sostenida en el tiempo, a pesar de que el usuario mantenga el joystick hacia adelante.

= Conclusión

#bibliography("sources.bib")
