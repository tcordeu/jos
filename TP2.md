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

1. En ESP esta la direccion al struct Trapframe tf, entonces en (%esp) esta el struct, mas precisamente ESP apunta al primer registro a desapilar que es EDI.

2. En (%esp) esta el registro EIP a desapilar, tambien puede pensarse como el return adress al programa, y en 8(%esp) esta el registro EFLAGS que tambien sera desapilado por la instruccion iret.

3. Para determinar si hay cambio de privilegio la CPU verifica el privilegio del CS recientemente cargado y lo compara con el privilegio actual.


gdb_hello
---------

1. (gdb) b env_pop_tf 
Breakpoint 1 at 0xf0102e9c: file kern/env.c, line 458.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0102e9c <env_pop_tf>:	push   %ebp

Breakpoint 1, env_pop_tf (tf=0xf01c1000) at kern/env.c:458
458	{

2. EAX=003bc000 EBX=f01c1000 ECX=f03bc000 EDX=000001f9
   ESI=00010094 EDI=00000000 EBP=f0118fd8 ESP=f0118fbc
   EIP=f0102e9c EFL=00000092 [--S-A--] CPL=0 II=0 A20=1 SMM=0 HLT=0
   ES =0010 00000000 ffffffff 00cf9300 DPL=0 DS   [-WA]
   CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]

3. (gdb) p tf
$1 = (struct Trapframe *) 0xf01c1000

4. (gdb) p sizeof(*tf) / sizeof(int)
$2 = 17
(gdb) x/17x tf
0xf01c1000:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c1010:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c1020:	0x00000023	0x00000023	0x00000000	0x00000000
0xf01c1030:	0x00800020	0x0000001b	0x00000000	0xeebfe000
0xf01c1040:	0x00000023

5. (gdb) disas
Dump of assembler code for function env_pop_tf:
=> 0xf0102e9c <+0>:	push   %ebp
   0xf0102e9d <+1>:	mov    %esp,%ebp
   0xf0102e9f <+3>:	sub    $0xc,%esp
   0xf0102ea2 <+6>:	mov    0x8(%ebp),%esp
   0xf0102ea5 <+9>:	popa   
   0xf0102ea6 <+10>:	pop    %es
   0xf0102ea7 <+11>:	pop    %ds
   0xf0102ea8 <+12>:	add    $0x8,%esp
   0xf0102eab <+15>:	iret   
   0xf0102eac <+16>:	push   $0xf010544e
   0xf0102eb1 <+21>:	push   $0x1d4
   0xf0102eb6 <+26>:	push   $0xf01053f6
   0xf0102ebb <+31>:	call   0xf01000a0 <_panic>
End of assembler dump.
(gdb) si 4
=> 0xf0102ea5 <env_pop_tf+9>:	popa   
0xf0102ea5	459		asm volatile("\tmovl %0,%%esp\n"

6 y 7. (gdb) x/17x $sp
0xf01c1000:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c1010:	0x00000000	0x00000000	0x00000000	0x00000000
0xf01c1020:	0x00000023	0x00000023	0x00000000	0x00000000
0xf01c1030:	0x00800020	0x0000001b	0x00000000	0xeebfe000
0xf01c1040:	0x00000023
(gdb) x/17x tf
0xf01c1000:	0x00000000[EDI]	0x00000000[ESI]	0x00000000[EBP]	0x00000000[ESP]
0xf01c1010:	0x00000000[EBX]	0x00000000[EDX]	0x00000000[ECX]	0x00000000[EAX]
0xf01c1020:	0x00000023[ES]	0x00000023[DS]	0x00000000[TPN]	0x00000000[ERR]
0xf01c1030:	0x00800020[EIP]	0x0000001b[CS]	0x00000000[EFL]	0xeebfe000[ESP]
0xf01c1040:	0x00000023[SS]

8. EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
   ESI=00000000 EDI=00000000 EBP=00000000 ESP=f01c1030
   EIP=f0102eab EFL=00000096 [--S-AP-] CPL=0 II=0 A20=1 SMM=0 HLT=0
   ES =0023 00000000 ffffffff 00cff300 DPL=3 DS   [-WA]
   CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]

9. (gdb) p $pc
$3 = (void (*)()) 0x800020
(gdb) symbol-file obj/user/hello
Load new symbol table from "obj/user/hello"? (y or n) y
Reading symbols from obj/user/hello...done.
Error in re-setting breakpoint 1: Function "env_pop_tf" not defined.
(gdb) p $pc
$4 = (void (*)()) 0x800020 <_start>

   EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
   ESI=00000000 EDI=00000000 EBP=00000000 ESP=eebfe000
   EIP=00800020 EFL=00000002 [-------] CPL=3 II=0 A20=1 SMM=0 HLT=0
   ES =0023 00000000 ffffffff 00cff300 DPL=3 DS   [-WA]
   CS =001b 00000000 ffffffff 00cffa00 DPL=3 CS32 [-R-]

En este punto, el context switch ya sucedio, por lo tanto se presentan los siguientes cambios:
-Los registros EAX, EBX... tienen valor 0 debido a que es la primera vez que el proceso corre.
-El privilegio actual pasa de 0 a 3(CPL).
-El registro ESP apunta direcciones mas bajas que antes(0xe... vs 0xf...).
-El registro EIP apunta a direcciones bajas y antes apuntaba a las direcciones mas altas, donde esta mapeado el kernel.

10. (gdb) tbreak syscall
Temporary breakpoint 2 at 0x8009ea: file lib/syscall.c, line 23.
(gdb) c
Continuing.
=> 0x8009ea <syscall+17>:	mov    0x8(%ebp),%ecx

Temporary breakpoint 2, syscall (num=0, check=-289415544, a1=4005551752, 
    a2=13, a3=0, a4=0, a5=0) at lib/syscall.c:23
23		asm volatile("int %1\n"
(gdb) disas
Dump of assembler code for function syscall:
   0x008009d9 <+0>:	push   %ebp
   0x008009da <+1>:	mov    %esp,%ebp
   0x008009dc <+3>:	push   %edi
   0x008009dd <+4>:	push   %esi
   0x008009de <+5>:	push   %ebx
   0x008009df <+6>:	sub    $0x1c,%esp
   0x008009e2 <+9>:	mov    %eax,-0x20(%ebp)
   0x008009e5 <+12>:	mov    %edx,-0x1c(%ebp)
   0x008009e8 <+15>:	mov    %ecx,%edx
=> 0x008009ea <+17>:	mov    0x8(%ebp),%ecx
   0x008009ed <+20>:	mov    0xc(%ebp),%ebx
   0x008009f0 <+23>:	mov    0x10(%ebp),%edi
   0x008009f3 <+26>:	mov    0x14(%ebp),%esi
   0x008009f6 <+29>:	int    $0x30
   0x008009f8 <+31>:	cmpl   $0x0,-0x1c(%ebp)
   0x008009fc <+35>:	je     0x800a02 <syscall+41>
   0x008009fe <+37>:	test   %eax,%eax
   0x00800a00 <+39>:	jg     0x800a0a <syscall+49>
   0x00800a02 <+41>:	lea    -0xc(%ebp),%esp
   0x00800a05 <+44>:	pop    %ebx
   0x00800a06 <+45>:	pop    %esi
   0x00800a07 <+46>:	pop    %edi
---Type <return> to continue, or q <return> to quit---disas
   0x00800a08 <+47>:	pop    %ebp
   0x00800a09 <+48>:	ret    
   0x00800a0a <+49>:	mov    -0x20(%ebp),%edx
   0x00800a0d <+52>:	sub    $0xc,%esp
   0x00800a10 <+55>:	push   %eax
   0x00800a11 <+56>:	push   %edx
   0x00800a12 <+57>:	push   $0x800f6c
   0x00800a17 <+62>:	push   $0x23
   0x00800a19 <+64>:	push   $0x800f89
   0x00800a1e <+69>:	call   0x800ab3 <_panic>
End of assembler dump.
(gdb) si 5
The target architecture is assumed to be i8086
[f000:e05b]    0xfe05b:	cmpw   $0x48,%cs:(%esi)
0x0000e05b in ?? ()

   EAX=00000000 EBX=00000000 ECX=00000000 EDX=0000066
   ESI=00000000 EDI=00000000 EBP=00000000 ESP=00000000
   EIP=0000e05b EFL=00000002 [-------] CPL=0 II=0 A20=1 SMM=0 HLT=0
   ES =0000 00000000 0000ffff 00009300
   CS =f000 000f0000 0000ffff 00009b00

Al haberse ejecutado la instruccion "int 0x30" se provoca una interrupcion, por lo tanto, la CPU invoca el procedimiento ubicado en IDT[48] para manejarla(con nivel de privilegio 0, ya que quien la maneja es el kernel).


kern_idt
--------

1. En la seccion 6.1 del manual de Intel x86 hay una tabla que indica si la interrupcion o excepcion produce un error code.
   La instruccion "iret" desapila dando por hecho que hay un error code en el stack, por lo tanto, si este no esta se desapilarian valores
   no deseados.

2. Si el parametro istrap es 1 entonces la gate sera del tipo Trap/Exception, en caso de ser 0 sera del tipo Interrupt.
   En el caso de que la gate sea del tipo Interrupt, la interrupcion no podra ser interrumpida por otras interrupciones. Mientras que si es
   del tipo Trap, puede ser interrupida por otras interrupciones.

3. Se genera una excepcion del tipo Page Fault.


user_evilhello
--------------

1. En que la direccion pasada a sys_cputs() apunta al stack del usuario, es decir, apunta a direcciones que pertenecen al usuario.

2. Cuando se ejecuta la nueva version de evilhello se produce una Page Fault cuando se intenta ejecutar "char first = *entry".
   Esto se debe a que "entry" es una direccion alta perteneciente a una pagina donde el usuario no tiene permisos, por lo tanto, se produce una Page Fault y se destruye el proceso.