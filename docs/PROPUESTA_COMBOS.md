# Propuesta: combos por Pokémon (v2)

> Pedido del usuario (2026-10-24): "me gusta eso de los combos por personaje si es que pegan dos habilidades
> consecutivas. Pensemos un poco más eso para todos los Pokémon que tenemos hoy implementados."
> **Es una propuesta para discutir**: lo que hay hoy (v1) está en el plan de identidad ("Combate de arena").

## 1. Lo que hay hoy (v1)
- **Cadena de golpes**: golpes seguidos al mismo rival suman +5% cada uno (hasta +25%), "COMBO ×N".
- **Un combo con nombre por Pokémon**: ataque A y antes de 1,6 s ataque B → B pega ×1,3-1,6, empuja más y a veces
  aplica un estado. Ej.: Charmander Arañazo → Ascuas = Garra Ardiente.
- **El problema**: todos los combos hacen lo mismo (más daño + un estado). Se sienten iguales entre Pokémon, no hay
  forma de descubrirlos y la IA no los usa.

## 2. Qué propongo cambiar
1. **Dos o tres combos por Pokémon**, cada uno con un **rol** distinto:
   - **Básico** (abridor → remate): el que sale jugando normal, premia acertar dos golpes.
   - **De control** (prepara → castiga): primero un estado o una zona, después el golpe que lo aprovecha.
   - **De firma** (usa la mecánica propia): solo sale con la condición de su firma (Calor alto, Estática llena,
     Furia de Roca...). Es el "momento épico" de cada uno.
2. **Efectos distintos, no solo daño** (cada combo tiene uno):
   - **Lanzar**: el rival queda "en el aire" 0,4 s (no actúa, cae con polvo).
   - **Atraer**: lo trae hacia vos (para seguir pegando de cerca).
   - **Aturdir corto**: 0,5 s.
   - **Terreno**: deja fuego, charco, hielo o un cráter donde pegó.
   - **Recarga**: el ataque que usaste para abrir se recarga al instante (cancelación tipo Pokkén: podés repetir).
   - **Robo**: te curás una parte del daño.
   - **Extender**: alarga el estado que ya tenía el rival.
3. **Combos de 3 golpes** (A → B → C) para algunos, como "ultra combo" con un cartel más grande y cámara lenta.
4. **Descubrirlos**: la primera vez que te sale un combo aparece "¡Combo nuevo: X!" y queda anotado; en la ficha
   del Pokémon (y en la Pokédex) se ven los combos descubiertos y los que faltan como "???" con una pista.
5. **La IA los usa**: los entrenadores (no los salvajes) intentan sus combos según la dificultad (Fácil casi nunca,
   Difícil seguido). Brock con Onix buscando la Sepultura se siente jefe.
6. **Feedback**: cartel del nombre del combo grande al centro, mini cámara lenta (hitstop) y temblor según el rol.

## 3. Combos propuestos (A → B = efecto)

| Pokémon | Básico | De control | De firma |
|---|---|---|---|
| **Charmander** | Arañazo → Ascuas = *Garra Ardiente*: quema | Giro Fuego → Arañazo = *Encierro*: aturdir corto | Con Calor alto: Embestida Ígnea → Ascuas = *Erupción*: deja fuego en el piso |
| **Bulbasaur** | Látigo Cepa → Polvo Veneno = *Látigo Tóxico*: extiende veneno | Somnífero (dormido) → Látigo Cepa = *Despertador*: lanzar | Durante Síntesis: Látigo Cepa → Látigo Cepa = *Raíz*: atraer y robo |
| **Squirtle** | Placaje → Pistola Agua = *Chorro a Quemarropa*: empuje fuerte | Parry de Refugio → Placaje = *Contragolpe*: aturdir corto | Con Presión llena: Giro Rápido → Pistola Agua = *Torbellino*: charco + lanzar |
| **Pikachu** | Ataque Rápido → Impactrueno = *Descarga Relámpago*: paraliza | Onda Trueno → Ataque Rápido = *Rayo Fugaz*: recarga | Con 5 cargas: Impactrueno → Rayo = *Trueno Perfecto*: aturdir + cámara lenta |
| **Pidgey** | Tornado → Ataque Rápido = *Picada del Viento*: empuje | Ataque Arena → Remolino = *Tormenta de Arena*: desorienta + atraer | En vuelo: Ataque Rápido → Tornado = *Ala Cortante*: lanzar |
| **Rattata** | Ataque Rápido → Mordisco = *Mordida Veloz*: herido | Mordisco → Mordisco ×3 → Hipercolmillo = *Frenesí* (3 golpes): remate más fácil | Con presa (rival < 40%): Foco Energía → Hipercolmillo = *Golpe Final*: crítico seguro |
| **Vulpix** | Fuego Fatuo → Ascuas = *Llama Fatua*: extiende quemado | Rayo Confuso → Lanzallamas = *Llamarada Confusa*: desorienta | Con Rescoldo alto: Ascuas → Ascuas → Lanzallamas = *Infierno* (3): fuego en el piso |
| **Bellsprout** | Látigo Cepa → Polvo Veneno = *Látigo Tóxico* | Somnífero → Látigo Cepa = *Latigazo al Dormido*: lanzar | Con Arraigo: Látigo Cepa → Látigo Cepa = *Enredadera*: atraer |
| **Caterpie** | Disparo Demora → Placaje = *Placaje Enredado*: suma seda | Telaraña → Disparo Demora = *Red*: enraíza al instante | Fortaleza → Placaje = *Bola de Seda*: empuje + seda |
| **Weedle** | Disparo Demora → Doble Ataque = *Aguijón Doble* | Picotazo Veneno → Pin Misil = *Lluvia de Púas*: extiende veneno | Con rival envenenado ×3: Doble Ataque → Pin Misil = *Enjambre*: aturdir |
| **Metapod** | Disparo Demora → Derribo = *Embestida de Capullo* | Fortaleza → Placaje = *Coraza*: robo (vida) | Endurecido: Derribo → Derribo = *Bola de Acero*: lanzar |
| **Kakuna** | Picotazo Veneno → Derribo = *Púas Rodantes* | Disparo Demora → Picotazo Veneno = *Aguijón Fijo*: aturdir corto | Endurecido: Derribo → Picotazo = *Capullo Venenoso*: extiende veneno |
| **Spearow** | Gruñido → Persecución = *Caza*: lanzar | Picotazo ×2 → Ataque Furia = *Picoteo Furioso* (3): recarga | Con Furia ×5: Persecución → Ataque Furia = *Pico Taladro*: crítico |
| **Mankey** | Patada Baja → Golpe Kárate = *Golpe Bajo y Alto*: lanzar | Malicioso → Golpe Kárate = *Golpe Expuesto*: aturdir | Enfurecido: Arañazo → Patada Baja → Golpe Kárate = *Tormenta de Puños* (3): cámara lenta |
| **Sandshrew** | Ataque Arena → Arañazo = *Garra en la Tormenta* | Rizo Defensa → Arañazo = *Rodada*: empuje | Tras Velo Arena: Picotazo Veneno → Arañazo = *Emboscada*: crítico |
| **Poliwag** | Burbuja → Pistola Agua = *Burbuja Reventada*: empuje | Hipnosis → Pistola Agua = *Chapuzón*: lanzar | Sobre lo mojado: Danza Lluvia → Burbuja → Pistola Agua = *Maremoto* (3): charco grande |
| **Psyduck** | Confusión → Pistola Agua = *Chorro Mareado* | Anulación → Arañazo = *Bloqueo Total*: extiende la anulación | Con Jaqueca llena: Confusión → Confusión = *Migraña*: aturdir en área |
| **Growlithe** | Mordisco → Ascuas = *Colmillo Ígneo* | Rugido → Rueda Fuego = *Embestida Salvaje*: lanzar | Rival rastreado: Rueda Fuego → Mordisco = *Caza Ígnea*: recarga |
| **Eevee** | Ataque Arena → Placaje = *Placaje a Ciegas* | Ataque Rápido → Derribo = *Embestida Doble* | Con Adaptación activa: Placaje → Derribo = *Contraataque Adaptado*: robo |
| **Seel** | Viento Hielo → Golpe Cabeza = *Cabezazo Helado*: suma escarcha | Rayo Aurora → Golpe Cabeza = *Témpano*: aturdir | Con 3 de escarcha: Golpe Cabeza → Viento Hielo = *Congelación*: deja hielo |
| **Geodude** | Lanzarrocas → Rodar = *Avalancha* | Rizo Defensa → Rodar = *Rodada Blindada*: empuje fuerte | Impulso ×3: Rodar → Placaje = *Derrumbe*: cráter |
| **Oddish** | Absorber → Paralizador = *Polen Pegajoso* | Polvo Veneno → Absorber = *Savia Tóxica*: robo | Con 5 esporas: Absorber → Florecer = *Floración*: aturdir en área |
| **Paras** | Arañazo → Chupavidas = *Corte Vampiro*: robo | Paralizador → Arañazo = *Tajo Paralizante*: extiende parálisis | Espora (dormido) → Chupavidas = *Banquete*: robo grande |
| **Onix (jefe)** | Atadura → Tumba Rocas = *Sepultura* | Atadura → Excavar = *Derrumbe* | En Furia de Roca: Lanzarrocas → Excavar → Tumba Rocas = *Terremoto Viviente* (3): cráteres + cámara lenta |

## 4. Decisiones para el usuario
1. ¿Pasamos a **2-3 combos por Pokémon con roles** (básico / control / firma)? (rec. sí)
2. ¿**Efectos distintos** (lanzar, atraer, aturdir, terreno, recarga, robo, extender) en vez de solo más daño? (rec. sí)
3. ¿**Combos de 3 golpes** para algunos (Rattata, Vulpix, Spearow, Mankey, Poliwag, Onix)? (rec. sí, pocos)
4. ¿Se **descubren** jugando (cartel "¡Combo nuevo!" + lista en la ficha con "???")? (rec. sí)
5. ¿La **IA de los entrenadores** los usa según la dificultad? (rec. sí; los salvajes no)
6. ¿Algún combo de la tabla que quieras cambiar o sumar?
