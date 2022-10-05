.include "macros.asm"

.data
	
.text

main:
	print_str("Informe um numero para calcular fatorial")
	scan_int($s0)

	li $s1, 1
	
	negativo:
		sgt $t1, $s0, -1
		beq $t1, 0, erro
	zero_um:
		beq $s0, 0, pos_fat
		beq $s0, 1, pos_fat
	
	jal fatorial
	pos_fat: 
		print_str("\nResultado = ")
		print_int($s1)
		terminate
	erro:
		print_str("\nNão existe fatorial de número negativo, tente novamente")
		terminate 
		
	fatorial:	
		beq $s0, 1, fim_fat
		mul $s1, $s0, $s1
		sub $s0, $s0, 1 
		j fatorial
	
	fim_fat:
		jr $ra
	
