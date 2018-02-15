;;; ----------------------------------------------------------------------------------------
;;; Computes the largest (92nd) 64 bit Fibonacci number and prints it using calls
;;; to the C library. (After that, we get integer overflow.)
;;; To assemble and run:
;;;     nasm -felf64 fib.asm && gcc fib.o -o fib && ./fib
;;; ----------------------------------------------------------------------------------------
;;; PIC/PIE used in newer linux distributions. requires some changes
;;; https://stackoverflow.com/questions/48071280/nasm-symbol-printf-causes-overflow-in-r-x86-64-pc32-relocation?rq=1
;;; https://www.tortall.net/projects/yasm/manual/html/objfmt-elf64.html
;;; got -> Global Offset Table
	
	default	  rel
	extern	  printf
	extern	  puts

	SECTION   .data		  
loopCount:
	dq	  92	                 ; number of times to loop
message:
	db        "Computing Fibonacci number", 0 ; zero terminated for C
format:
	db	  "%llu", 10, 0              ; long-long-unsigned note the newline (10) at the end
	
	SECTION	  .text
        global    main
main:
	mov	  rdi, message 		 ; First integer (or pointer) argument in rdi
        call      [puts wrt ..got]	 ; puts(message)

	mov	  r9, 0			 ; f_{n-1}
	mov	  r10, 1		 ; f_{n}
	xor	  r11, r11		 ; zero out temp (strictly un-nesc.)
	
	mov	  rcx, [loopCount]	 ; set up loop counter
computationLoop:
	add	  r9, r10 		 ; add f_{n-1} and f_{n}, store in r9 as f_{n+1}
	
	mov	  r11, r10		 ; shuffle: r11 (temp) = f_n,
	mov	  r10, r9		 ; shuffle: r10 = f_{n+1}
	mov	  r9, r11		 ; shuffle: r9 = f_n
	
	loop	  computationLoop

	;; print the computed value
	push	  rax
	push	  rcx
	push	  rbp		         ; setup stack frame

	mov	  rdi, format
	mov	  rsi, r10
	mov	  rax, 0
	call 	  [printf wrt ..got]

	pop	  rbp
	pop	  rcx
	pop	  rax
	
	mov	  rdi, 0		 ; move 0 to exit code (rdi)
        mov       rax, 60       	 ; system call for exit
        syscall                 	 ; invoke operating system to exit	
	ret
	
	
