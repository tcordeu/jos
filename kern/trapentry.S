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

TRAPHANDLER_NOEC(_divide_idt, 0)		// divide error
TRAPHANDLER_NOEC(_debug_idt, 1)		// debug exception
TRAPHANDLER_NOEC(_nmi_idt, 2)		// non-maskable interrupt
TRAPHANDLER_NOEC(_breakpoint_idt, 3)		// breakpoint
TRAPHANDLER_NOEC(_overflow_idt, 4)		// overflow
TRAPHANDLER_NOEC(_bound_idt, 5)		// bounds check
TRAPHANDLER_NOEC(_illop_idt, 6)		// illegal opcode
TRAPHANDLER_NOEC(_device_idt, 7)		// device not available
TRAPHANDLER(_dblflt_idt, 8)		// double fault
TRAPHANDLER(_tss_idt, 10)		// invalid task switch segment
TRAPHANDLER(_segnp_idt, 11)		// segment not present
TRAPHANDLER(_stack_idt, 12)		// stack exception
TRAPHANDLER(_gpflt_idt, 13)		// general protection fault
TRAPHANDLER(_pgflt_idt, 14)		// page fault
TRAPHANDLER_NOEC(_fperr_idt, 16)		// floating point error
TRAPHANDLER(_align_idt, 17)		// aligment check
TRAPHANDLER_NOEC(_mchk_idt, 18)		// machine check
TRAPHANDLER_NOEC(_simd_idt, 19)		// SIMD floating point error
TRAPHANDLER_NOEC(_syscall_idt, 48)		// system call

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
	
