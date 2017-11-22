TP2: Procesos de usuario
========================

env_alloc
---------

1. Para los 5 primeros procesos, el numero generado para la variable generation es 4096 o 0x1000.
   Luego, faltaría realizar OR de 0x1000 con (e - envs), que resultaría en los siguientes resultados:
   -0x1000 (1)
   -0x1001 (2)
   -0x1002 (3)
   -0x1003 (4)
   -0x1004 (5)

2. Si se elimina envs[630] por primera vez, e->env_id seria: 0x1276. Entonces:
   -generation: 0x2000 y id: 0x2276. (1)
   -generation: 0x3000 y id: 0x3276. (2)
   -generation: 0x4000 y id: 0x4276. (3)
   -generation: 0x5000 y id: 0x5276. (4)
   -generation: 0x6000 y id: 0x6276. (5)


env_init_percpu
---------------

¿Cuántos bytes escribe la función lgdt, y dónde?

-Escribe 6 bytes en el registro GDTR.

¿Qué representan esos bytes?

- Los últimos 4 bytes representan la dirección de la tabla GDT y los últimos 2 bytes representan el limite de la tabla GDT, es decir, el ultimo valor posible de la misma.


env_pop_tf
----------

...


gdb_hello
---------

...
