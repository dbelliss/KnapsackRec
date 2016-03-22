
.global knapsack

knapsack:
	.equ wordsize, 4
	.equ cur_value, 6*wordsize
	.equ capacity, 5*wordsize
	.equ num_items, 4*wordsize
	.equ values, 3*wordsize
	.equ weights, 2*wordsize
	.equ i, -1*wordsize
	.equ best_value, -2*wordsize
	.equ ebx, -3 * wordsize
	.equ edi, -4 * wordsize
    .equ esi, -5 * wordsize
	pushl %ebp
	movl %esp, %ebp
	pushl $0 #push 0, move esp down. Adds i to the stack 
	pushl cur_value(%ebp) #push best_value to stack
	push %ebx #saves %ebx
	pushl %edi #saves %edi
	pushl %esi #saves %esi

	forloop:
		movl i(%ebp), %eax
		movl num_items(%ebp), %ebx
		cmp %eax, %ebx
			jle end


		movl weights(%ebp), %eax
		.rep 4
		addl i(%ebp), %eax
		.endr
	
		movl (%eax), %eax #weights[i]
		cmp %eax, capacity(%ebp)
		jl setup #if cannot fit in knapsack
		#contents of loop
		#get contents into registers
		
		movl weights(%ebp), %eax #move weights to eax
		.rept 4
		addl i(%ebp), %eax #create weights+i
		.endr
		addl $4, %eax #eax = weights + i + 1

		#values + i + 1
		movl values(%ebp), %ebx
		.rept 4
		addl i(%ebp), %ebx
		.endr
		addl $4, %ebx

		#num_items - i - 1
		movl num_items(%ebp), %ecx
			#numitems - i - 1
		
		subl i(%ebp), %ecx
		decl %ecx

		#capacity -weights[i]
		movl capacity(%ebp), %edx
		movl weights(%ebp), %edi
		
		.rept 4
		addl i(%ebp), %edi
		.endr

		movl (%edi), %edi
		subl %edi, %edx

		#curvalue + values[i]
		movl cur_value(%ebp), %edi
		movl values(%ebp), %esi
		
		.rept 4
		addl i(%ebp), %esi
		.endr

		movl (%esi), %esi
		addl %esi, %edi

		push %edi
		push %edx
		push %ecx
		push %ebx
		push %eax

		#done setting up for max and best value
		call knapsack
		#%eax holds answer, must compare to best_value
		#call max of %eax and best_value
		call max
		movl %eax, best_value(%ebp) #best_value = max(best_value,knapsack())

		



	setup:
		incl i(%ebp)
		jmp forloop

	end:
		movl best_value(%ebp), %eax
		jmp epq

	epq: #epilogue

		movl ebx(%ebp), %ebx
		movl edi(%ebp), %edi
		movl esi(%ebp), %esi
		## restores values

		movl %ebp, %esp #move esp back down
		popl %ebp
		ret

	max: #%eax will hold the max
		cmp %eax, best_value(%ebp)
			jl complete
		movl best_value(%ebp), %eax

	complete:
		
		ret
