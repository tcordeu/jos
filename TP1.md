TP1: Memoria virtual en JOS
===========================

page2pa
-------

La función page2pa primero realiza una resta entre pp y pages. Lo que resulta de esto es el índice de pp en el array pages, porque la aritmética de punteros indica que al realizar la operación (pp - pages), el resultado en lugar de ser index * sizeof(struct PageInfo) es únicamente index.
Después de esta resta, se realiza un shift a izquierda por el log2(PGSIZE), que es lo mismo que multiplicar por PGSIZE en este caso.
Por lo tanto, la función devuelve el índice de la página por el tamaño de la página, es decir, su dirección.


boot_alloc_pos
--------------

a. El primer valor devuelto por boot_alloc corresponde al inicio de la primer página luego del final de la sección .bss. En este caso la sección .bss tiene la siguiente información: 

[Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
[ 6] .bss              NOBITS          f0113300 014300 000650 00  WA  0   0 32

Al ser de tipo NOBITS, no ocupa espacio en el archivo y hay que ignorar el campo size, por lo que el final de la sección es el inicio. El valor devuelto por boot alloc será el primer múltiplo del tamaño de la página (0x1000) que sea mayor a la dirección (0xf0113300), es decir: 0xf0114000.

b. GDB:

gdb -q -s obj/kern/kernel -ex 'target remote 127.0.0.1:26000' -n -x .gdbinit
Reading symbols from obj/kern/kernel...done.
Remote debugging using 127.0.0.1:26000
0x0000fff0 in ?? ()
(gdb) b boot_alloc 
Breakpoint 1 at 0xf0100a22: file kern/pmap.c, line 92.
(gdb) b kern/pmap.c:122
Breakpoint 2 at 0xf0100a5e: file kern/pmap.c, line 122.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0100a22 <boot_alloc>:	push   %ebp

Breakpoint 1, boot_alloc (n=<unknown type>) at kern/pmap.c:92
92	{
(gdb) p/x end
$1 = 0x40010
(gdb) p/x nextfree
$2 = 0x0
(gdb) c
Continuing.
=> 0xf0100a5e <boot_alloc+60>:	mov    %ebx,%eax

Breakpoint 2, boot_alloc (n=<unknown type>) at kern/pmap.c:123
123	}
(gdb) p/x end
$3 = 0x40010
(gdb) p/x nextfree
$4 = 0xf0118000
(gdb) 



page_alloc
----------

La diferencia entre page2pa y page2kva radica en que la primera devuelve la dirección de la página en memoria física, mientras que la segunda chequea que la página esté en el rango válido y luego le suma la posición base del kernel al physical address, devolviendo de esta manera el kernel virtual address de la dirección física recibida.


