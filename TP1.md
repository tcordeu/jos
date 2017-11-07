TP1: Memoria virtual en JOS
===========================

page2pa
-------

La función page2pa primero realiza una resta entre pp y pages. Lo que resulta de esto es el índice de pp en el array pages, porque la aritmética de punteros indica que al realizar la operación (pp - pages), el resultado en lugar de ser index * sizeof(struct PageInfo) es únicamente index.
Después de esta resta, se realiza un shift a izquierda por el log2(PGSIZE), que es lo mismo que multiplicar por PGSIZE en este caso.
Por lo tanto, la función devuelve el índice de la página por el tamaño de la página, es decir, su dirección.


boot_alloc_pos
--------------

...


page_alloc
----------

La diferencia entre page2pa y page2kva radica en que la primera devuelve la dirección de la página en memoria física, mientras que la segunda chequea que la página esté en el rango válido y luego le suma la posición base del kernel al physical address, devolviendo de esta manera el kernel virtual address de la dirección física recibida.


