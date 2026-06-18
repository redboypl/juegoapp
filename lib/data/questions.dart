// ============================================================
// questions.dart — Todas las preguntas de la trivia
// Equivalente a allQuestions en script.js
// ============================================================

class Pregunta {
  final String q;
  final List<String> opts;
  final int a;
  final String fact;
  final String dif;

  const Pregunta({
    required this.q,
    required this.opts,
    required this.a,
    required this.fact,
    required this.dif,
  });
}

class Categoria {
  final String id;
  final String name;
  final String icon;
  final double mult;
  final String desc;
  final List<Pregunta> questions;

  const Categoria({
    required this.id,
    required this.name,
    required this.icon,
    required this.mult,
    required this.desc,
    required this.questions,
  });
}

final List<Categoria> todasLasCategorias = [
  Categoria(
    id: 'lvbp',
    name: 'LVBP',
    icon: '🦁',
    mult: 1.5,
    desc: 'Todo sobre los equipos, estadios y rivalidades de la Liga Venezolana de Béisbol Profesional.',
    questions: [
      Pregunta(q: '¿Cuántos equipos conforman actualmente la LVBP?', opts: ['6','7','8','10'], a: 2, fact: 'La LVBP tiene 8 equipos: Cardenales, Leones, Tiburones, Magallanes, Caracas, Lara, Aragua y Margarita.', dif: 'facil'),
      Pregunta(q: '¿Qué equipo es conocido como "El Equipo del Pueblo"?', opts: ['Leones del Caracas','Navegantes del Magallanes','Cardenales de Lara','Tiburones de La Guaira'], a: 1, fact: 'Magallanes es el equipo con mayor número de seguidores en Venezuela, conocido como el Equipo del Pueblo.', dif: 'media'),
      Pregunta(q: '¿En qué ciudad juegan los Leones del Caracas?', opts: ['Maracaibo','Valencia','Caracas','Barquisimeto'], a: 2, fact: 'Los Leones del Caracas juegan en el Estadio Universitario de Caracas.', dif: 'facil'),
      Pregunta(q: '¿Qué equipo juega sus partidos en Maracaibo?', opts: ['Águilas del Zulia','Tigres de Aragua','Cardenales de Lara','Bravos de Margarita'], a: 0, fact: 'Las Águilas del Zulia tienen su sede en Maracaibo, en el Estadio Luis Aparicio El Grande.', dif: 'facil'),
      Pregunta(q: '¿Cuál es el color representativo de los Tiburones de La Guaira?', opts: ['Rojo y azul','Verde y blanco','Azul y blanco','Amarillo y negro'], a: 2, fact: 'Los Tiburones de La Guaira visten azul y blanco, representando al estado La Guaira.', dif: 'media'),
      Pregunta(q: '¿Qué equipo tiene como mascota un pájaro rojo?', opts: ['Leones del Caracas','Cardenales de Lara','Tigres de Aragua','Navegantes del Magallanes'], a: 1, fact: 'Los Cardenales de Lara tienen como símbolo al cardenal, pájaro rojo muy común en Venezuela.', dif: 'facil'),
      Pregunta(q: '¿Cuál es el estadio de los Navegantes del Magallanes?', opts: ['Estadio Monumental','Estadio Universitario','Estadio José Bernardo Pérez','Estadio Luis Aparicio'], a: 2, fact: 'El Estadio José Bernardo Pérez en Valencia es la casa de los Navegantes del Magallanes.', dif: 'dificil'),
      Pregunta(q: '¿Qué equipo representa al estado Aragua?', opts: ['Leones','Tiburones','Tigres','Cardenales'], a: 2, fact: 'Los Tigres de Aragua representan ese estado, con sede en Maracay.', dif: 'facil'),
    ],
  ),
  Categoria(
    id: 'grandesligas',
    name: 'Grandes Ligas',
    icon: '🌟',
    mult: 1.5,
    desc: 'Peloteros venezolanos que triunfaron en la MLB: sus logros, equipos y récords históricos.',
    questions: [
      Pregunta(q: '¿En qué posición jugó Omar Vizquel durante casi toda su carrera?', opts: ['Segunda base','Tercera base','Campo corto','Centro del jardín'], a: 2, fact: 'Omar Vizquel es considerado uno de los mejores campocortos defensivos de la historia.', dif: 'facil'),
      Pregunta(q: '¿De qué estado venezolano es originario Miguel Cabrera?', opts: ['Aragua','Zulia','Miranda','Carabobo'], a: 0, fact: 'Miguel Cabrera nació en Maracay, estado Aragua, el 18 de abril de 1983.', dif: 'media'),
      Pregunta(q: '¿Qué pitcher venezolano ganó dos veces el Cy Young Award?', opts: ['Félix Hernández','Johan Santana','Carlos Zambrano','Wilson Ramos'], a: 1, fact: 'Johan Santana ganó el Cy Young en 2004 y 2006, ambas veces con los Minnesota Twins.', dif: 'media'),
      Pregunta(q: '¿Qué venezolano fue elegido al Salón de la Fama de Baseball en 2024?', opts: ['Omar Vizquel','Bobby Abreu','Johan Santana','Carlos Guillén'], a: 1, fact: 'Bobby Abreu fue elegido al Salón de la Fama de Baseball en 2024.', dif: 'dificil'),
      Pregunta(q: '¿Con qué equipo debutó en MLB el lanzador Félix Hernández?', opts: ['Los Angeles Dodgers','Seattle Mariners','New York Yankees','Boston Red Sox'], a: 1, fact: 'Félix "King" Hernández debutó con Seattle Mariners en 2005 y pasó toda su carrera allí.', dif: 'media'),
      Pregunta(q: '¿Cuántos Golden Glove ganó Omar Vizquel en su carrera?', opts: ['7','9','11','13'], a: 2, fact: 'Omar Vizquel ganó 11 Guantes de Oro, todos como campocorto, récord en esa posición.', dif: 'dificil'),
      Pregunta(q: '¿Qué logro histórico consiguió Miguel Cabrera en 2012?', opts: ['MVP de la Serie Mundial','Triple Corona','Cy Young Award','Récord de jonrones'], a: 1, fact: 'Miguel Cabrera ganó la Triple Corona en 2012, siendo el primero en lograrlo desde 1967.', dif: 'media'),
      Pregunta(q: '¿Cuántos jonrones conectó Andrés Galarraga en su mejor temporada?', opts: ['42','47','44','39'], a: 2, fact: 'El "Gato Grande" Andrés Galarraga conectó 44 jonrones en 1996 con los Colorado Rockies.', dif: 'dificil'),
    ],
  ),
  Categoria(
    id: 'historia',
    name: 'Historia',
    icon: '📖',
    mult: 2.0,
    desc: 'Los orígenes del béisbol en Venezuela, sus pioneros y los momentos que marcaron la historia del deporte criollo.',
    questions: [
      Pregunta(q: '¿En qué año se fundó la Liga Venezolana de Béisbol?', opts: ['1922','1945','1951','1960'], a: 1, fact: 'La LVBP fue fundada en 1945, siendo una de las ligas más antiguas de América Latina.', dif: 'media'),
      Pregunta(q: '¿Quién fue el primer venezolano en jugar en las Grandes Ligas?', opts: ['Chico Carrasquel','Luis Aparicio','Pompeyo Davalillo','Alex Carrasquel'], a: 0, fact: 'Chico Carrasquel fue el primer venezolano en las Grandes Ligas, debutando con los Chicago White Sox en 1950.', dif: 'media'),
      Pregunta(q: '¿Cuándo Venezuela ganó por primera vez el Clásico Mundial de Béisbol?', opts: ['No lo ha ganado','2009','2013','2017'], a: 0, fact: 'Venezuela aún no ha ganado el Clásico Mundial, aunque ha llegado a rondas avanzadas varias veces.', dif: 'facil'),
      Pregunta(q: '¿Qué ciudad venezolana tiene el estadio "Luis Aparicio El Grande"?', opts: ['Caracas','Valencia','Maracaibo','Barcelona'], a: 2, fact: 'El Estadio Luis Aparicio El Grande está en Maracaibo, estado Zulia, en honor al gran pelotero.', dif: 'facil'),
      Pregunta(q: '¿A qué edad debutó Luis Aparicio en las Grandes Ligas?', opts: ['17 años','19 años','22 años','25 años'], a: 2, fact: 'Luis Aparicio debutó con los Chicago White Sox en 1956 a los 22 años.', dif: 'dificil'),
      Pregunta(q: '¿En qué año fue inaugurado el Estadio Universitario de Caracas?', opts: ['1948','1951','1955','1962'], a: 1, fact: 'El Estadio Universitario de Caracas fue inaugurado en 1951, siendo el más icónico del béisbol venezolano.', dif: 'dificil'),
      Pregunta(q: '¿Qué jugador fue el primer venezolano en llegar al Salón de la Fama de Cooperstown?', opts: ['Omar Vizquel','Andrés Galarraga','Luis Aparicio','Chico Carrasquel'], a: 2, fact: 'Luis Aparicio fue inducido al Salón de la Fama de Cooperstown en 1984, el primero de Venezuela.', dif: 'media'),
      Pregunta(q: '¿En qué país se originó el béisbol antes de llegar a Venezuela?', opts: ['Cuba','Estados Unidos','República Dominicana','Puerto Rico'], a: 1, fact: 'El béisbol llegó a Venezuela desde Estados Unidos a finales del siglo XIX, traído por trabajadores petroleros.', dif: 'facil'),
    ],
  ),
  Categoria(
    id: 'cultura',
    name: 'Cultura',
    icon: '🇻🇪',
    mult: 1.0,
    desc: 'La relación entre el béisbol y la identidad venezolana: tradiciones, términos criollos y curiosidades del fanático.',
    questions: [
      Pregunta(q: '¿Cuál es el deporte nacional de Venezuela según la ley?', opts: ['Fútbol','Béisbol','Boxeo','Ciclismo'], a: 1, fact: 'El béisbol es el deporte nacional de Venezuela, declarado así oficialmente.', dif: 'facil'),
      Pregunta(q: '¿Cómo se le llama popularmente al béisbol en Venezuela?', opts: ['La pelota fría','El pasatiempo nacional','La pelota caliente','El juego del pueblo'], a: 2, fact: 'En Venezuela al béisbol se le llama "la pelota caliente", diferenciándolo del fútbol que es "pelota fría".', dif: 'media'),
      Pregunta(q: '¿Cuál es el rival clásico más famoso de la LVBP?', opts: ['Leones vs Magallanes','Tiburones vs Caracas','Lara vs Aragua','Zulia vs Margarita'], a: 0, fact: 'El clásico Leones del Caracas vs Navegantes del Magallanes es el derbi más apasionante del béisbol venezolano.', dif: 'facil'),
      Pregunta(q: '¿Cuántos venezolanos han ganado el premio Cy Young en MLB?', opts: ['1','2','3','4'], a: 1, fact: 'Dos venezolanos han ganado el Cy Young: Johan Santana (2 veces) y Félix Hernández (1 vez).', dif: 'media'),
      Pregunta(q: '¿Cuál de estos términos NO es del béisbol?', opts: ['Jonrón','Ponche','Tubey','Offside'], a: 3, fact: 'El offside es del fútbol. En béisbol se usan jonrón, ponche, tubey, triplete, entre otros.', dif: 'facil'),
      Pregunta(q: '¿Cómo se le llama al "home run" en Venezuela?', opts: ['Cuadrangular','Jonrón','Cuadro completo','Las dos anteriores son correctas'], a: 3, fact: 'En Venezuela se usa tanto "jonrón" como "cuadrangular" para referirse al home run.', dif: 'media'),
      Pregunta(q: '¿Qué estado venezolano es más famoso por producir peloteros de MLB?', opts: ['Carabobo','Miranda','Zulia','Aragua'], a: 2, fact: 'Zulia es históricamente el estado venezolano que más peloteros ha aportado a las Grandes Ligas.', dif: 'dificil'),
      Pregunta(q: '¿Cómo se llama la posición "shortstop" en Venezuela?', opts: ['Receptor','Campocorto','Inicialista','Jardinero'], a: 1, fact: 'El campocorto es una de las posiciones más valoradas. Venezuela ha producido muchos de los mejores del mundo.', dif: 'facil'),
    ],
  ),
];
