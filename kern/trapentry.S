/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(_divide_idt, T_DIVIDE)		// divide error
TRAPHANDLER_NOEC(_debug_idt, T_DEBUG)		// debug exception
TRAPHANDLER_NOEC(_nmi_idt, T_NMI)		// non-maskable interrupt
TRAPHANDLER_NOEC(_breakpoint_idt, T_BRKPT)		// breakpoint
TRAPHANDLER_NOEC(_overflow_idt, T_OFLOW)		// overflow
TRAPHANDLER_NOEC(_bound_idt, T_BOUND)		// bounds check
TRAPHANDLER_NOEC(_illop_idt, T_ILLOP)		// illegal opcode
TRAPHANDLER_NOEC(_device_idt, T_DEVICE)		// device not available
TRAPHANDLER(_dblflt_idt, T_DBLFLT)		// double fault
TRAPHANDLER(_tss_idt, T_TSS)		// invalid task switch segment
TRAPHANDLER(_segnp_idt, T_SEGNP)		// segment not present
TRAPHANDLER(_stack_idt, T_STACK)		// stack exception
TRAPHANDLER(_gpflt_idt, T_GPFLT)		// general protection fault
TRAPHANDLER(_pgflt_idt, T_PGFLT)		// page fault
TRAPHANDLER_NOEC(_fperr_idt, T_FPERR)		// floating point error
TRAPHANDLER(_align_idt, T_ALIGN)		// aligment check
TRAPHANDLER_NOEC(_mchk_idt, T_MCHK)		// machine check
TRAPHANDLER_NOEC(_simd_idt, T_SIMDERR)		// SIMD floating point error
TRAPHANDLER_NOEC(_syscall_idt, T_SYSCALL)		// system call

/*
 * Lab 3: Your code here for _alltraps
 */

.globl _alltraps
_alltraps:
	push %ds
    push %es
    pusha
    mov $GD_KT, %ax
    mov %ax, %ds
    mov %ax, %es
	pushl %esp
	call trap
	